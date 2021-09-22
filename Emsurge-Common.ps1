$ErrorActionPreference = "Stop"
Write-Host "Loading PowerShell Functions used for all Emsurge deployments..."

$EmsurgeSubscriptionIDs = @{
    DevTest = "13b5b0f9-a677-4bd4-847d-21fa21f3cb97"
    Internal = "0f4356ba-826a-4900-9740-9ad73116a744"
    CustomerFacing = "c028990c-1dfe-4bd4-8e4a-444c7554894b"
}

$EmsurgeTenantId = "2afa7fb2-54f1-49b6-bd91-de23ca508619"

$GloballyUniquePrefix = "ems" # Stands for Emsurge. This is an attempt to make ALL resource names globally unique
$EnvironmentNameMaxLength = 4 # This needs to match the ValidateLength attribute of the EnvironmentName parameter in all the functions below!
$ApplicationInstanceNameMaxLength = 4 # This needs to match the ValidateLength attribute of the ApplicationInstanceName parameter in all the functions below!

# List of all resources and their limits can be found here: https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules
$ResourceTypeMap = @{
    'ResourceGroup' = @{ # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftresources
        EntityType = 'Microsoft.Resources/resourcegroups'
        Suffix = "-rg"
        MaxNameLength = 90
    }
    'StorageAccount' = @{ # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftstorage
        EntityType = 'Microsoft.Storage/storageAccounts'
        Suffix = "stg"
        MaxNameLength = 28
    }
    'CdnProfile' = @{ # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftcdn
        EntityType = 'Microsoft.Cdn/profiles'
        Suffix = 'cdnprofile'
        MaxNameLength = 260
    }
    'CdnEndpoint' = @{ # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftcdn
        EntityType = 'Microsoft.Cdn/profiles/endpoints'
        Suffix = 'cdnendpoint'
        MaxNameLength = 50
    }
    'AppServicePlan' = @{ # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftweb
        EntityType = 'Microsoft.Web/serverfarms'
        Suffix = 'appserviceplan'
        MaxNameLength = 40
    }
    'AppService' = @{ # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftweb
        EntityType = 'Microsoft.Web/sites'
        Suffix = 'appservice'
        MaxNameLength = 60
    }
    'PostgreSQLDatabase' = @{ #https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftdbforpostgresql
        EntityType = 'Microsoft.DBforPostgreSQL/servers/databases'
        Suffix = 'db'
        MaxNameLength = 63
    }
    'PostgreSQLFlexibleServer' = @{ #https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftdbforpostgresql
        EntityType = 'Microsoft.DBforPostgreSQL/servers'
        Suffix = 'psql'
        MaxNameLength = 63
    }
    'LogAnalyticsWorkspace' = @{ #https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftoperationalinsights
        EntityType = 'Microsoft.OperationalInsights/workspaces'
        Suffix = 'loganalyticsws'
        MaxNameLength = 63
    }
    'AppInsights' = @{ # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftinsights
        EntityType = 'Microsoft.Insights/components'
        Suffix = 'appinsights'
        MaxNameLength = 260
    }
    KeyVault = @{ # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftkeyvault
        EntityType = 'Microsoft.KeyVault'
        Suffix = 'kv'
        MaxNameLength = 24
    }
}

$EnvironmentBaseDataMap = @{
    "cheap" = @{
        Name = "cheap"
        Description = "The cheapest possible set of resources."
        TenantId = $EmsurgeTenantId
        SubscriptionId = $EmsurgeSubscriptionIDs.DevTest
        Specs = @{
            PostgreSQLServer = 'development'
            AppServicePlan = 'free'
            Performance = "minimum"
            Availability = "minimum"
            Monitoring = "minimum"
            Security = "minimum"
        }
        Usage = @{
            CanBeSharedWithCustomers = $false
        }
    }
    "sbox" = @{
        Name = "sbox"
        Description = "A space for experimentation. Ability to manually configure resources. Lax security. Relatively cheap resources. DO NOT use for demos. DO NOT share with clients. DO NOT use any sensitive data."
        TenantId = $EmsurgeTenantId
        SubscriptionId = $EmsurgeSubscriptionIDs.DevTest
        Specs = @{
            PostgreSQLServer = 'development'
            AppServicePlan = 'development'
            Performance = "minimum"
            Availability = "minimum"
            Monitoring = "minimum"
            Security = "minimum"
        }
        Usage = @{
            CanBeSharedWithCustomers = $false
        }
    }
    "dev" = @{
        Name = "dev"
        Description = "Deploy and test your local changes using the deployment scripts. No manual configuration of resources. Lax security. Relatively cheap resources (as long as they are fast enough to support efficient development). DO NOT use any sensitive data in this environment."
        TenantId = $EmsurgeTenantId
        SubscriptionId = $EmsurgeSubscriptionIDs.DevTest
        Specs = @{
            PostgreSQLServer = 'development'
            AppServicePlan = 'development'
            Performance = "minimum"
            Availability = "minimum"
            Monitoring = "minimum"
            Security = "minimum"
        }
        Usage = @{
            CanBeSharedWithCustomers = $false
        }
    }
    "demo" = @{
        Name = "demo"
        TenantId = $EmsurgeTenantId
        SubscriptionId = $EmsurgeSubscriptionIDs.CustomerFacing
        Specs = @{
            PostgreSQLServer = 'demo'
            AppServicePlan = 'demo'
            Performance = "high"
            Availability = "high"
            Monitoring = "high"
            Security = "high"
        }
        Usage = @{
            CanBeSharedWithCustomers = $true
        }
    }
    "pre" = @{
        Name = "pre"
        TenantId = $EmsurgeTenantId
        SubscriptionId = $EmsurgeSubscriptionIDs.Internal
        Specs = @{
            PostgreSQLServer = 'production'
            AppServicePlan = 'production'
            Performance = "high"
            Availability = "minimum"
            Monitoring = "minimum"
            Security = "minimum"
        }
        Usage = @{
            CanBeSharedWithCustomers = $false
        }
    }
    "prod" = @{
        Name = "prod"
        TenantId = $EmsurgeTenantId
        SubscriptionId = $EmsurgeSubscriptionIDs.CustomerFacing
        Specs = @{
            PostgreSQLServer = 'production'
            AppServicePlan = 'production'
            Performance = "critical"
            Availability = "critical"
            Monitoring = "critical"
            Security = "critical"
        }
        Usage = @{
            CanBeSharedWithCustomers = $true
        }
    }
}

Function GetPrefixesForSharingScope($ApplicationName, $EnvironmentName, $ApplicationInstanceName) {
     # The maximum length of a valid environment name.
     # This is required in order to validate that a resource can be deployed to ALL environments, not just some
     # which happen to have a shorter-than-max name, e.g. dev has a length of 3 but prod has a length of 4

    $GlobalPrefixPrefix = "${GloballyUniquePrefix}"
    $GlobalPrefixSuffix = "global"

    $ApplicationEnvironmentPrefixPrefix = "${GloballyUniquePrefix}"
    $ApplicationEnvironmentPrefixSuffix = "${ApplicationName}shared"

    $ApplicationInstancePrivatePrefixPrefix = "${GloballyUniquePrefix}"
    $ApplicationInstancePrivatePrefixSuffix = "${ApplicationName}${ApplicationInstanceName}"

    $Result = @{
        'GlobalEnvironment' = @{
            Value = "${GlobalPrefixPrefix}${EnvironmentName}${GlobalPrefixSuffix}"
            MaxNameLength = $GlobalPrefixPrefix.Length + $EnvironmentNameMaxLength + $GlobalPrefixSuffix.Length
        }
        'ApplicationEnvironment' = @{ 
            Value = "${ApplicationEnvironmentPrefixPrefix}${EnvironmentName}${ApplicationEnvironmentPrefixSuffix}"
            MaxNameLength = $ApplicationEnvironmentPrefixPrefix.Length + $EnvironmentNameMaxLength + $ApplicationEnvironmentPrefixSuffix.Length
        }
        'ApplicationInstance' = @{
            Value = "${ApplicationInstancePrivatePrefixPrefix}${EnvironmentName}${ApplicationInstancePrivatePrefixSuffix}"
            MaxNameLength = $ApplicationEnvironmentPrefixPrefix.Length + $EnvironmentNameMaxLength + $ApplicationEnvironmentPrefixSuffix.Length
        }
    }
    return $Result
}

Function Get-ApplicationInstanceScopeNamePattern {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string]$ApplicationName,
        [Parameter(Mandatory)][ValidateSet([ValidEnvironmentNames])][ValidateLength(1, 4)][string]$EnvironmentName
    )
    $SharingScopePrefixes = GetPrefixesForSharingScope $ApplicationName $EnvironmentName "*" # Use * as the ApplicationInstanceName, which will return a pattern instead of a name. This is a 'clever' trick so be careful if you modify this code!
    $Result = $SharingScopePrefixes.ApplicationInstanceScope
    return $Result
}

Function Get-ApplicationEnvironmentScopeNamePattern {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string]$ApplicationName,
        [Parameter(Mandatory)][ValidateSet([ValidEnvironmentNames])][ValidateLength(1, 4)][string]$EnvironmentName
    )
    $SharingScopePrefixes = GetPrefixesForSharingScope $ApplicationName $EnvironmentName * # Use * as the ApplicationInstanceName, which will return a pattern instead of a name. This is a 'clever' trick so be careful if you modify this code!
    $Result = $SharingScopePrefixes.ApplicationEnvironmentScope
    return $Result
}

class ValidEnvironmentNames : System.Management.Automation.IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        return [string[]]@('cheap', 'sbox', 'dev', 'demo', 'pre', 'prod')
    }
}

Function Get-EnvironmentBaseData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string]$ApplicationName,
        [Parameter(Mandatory)][ValidateSet([ValidEnvironmentNames])][ValidateLength(1, 4)][string]$EnvironmentName
    )
    $Result = $EnvironmentBaseDataMap[$EnvironmentName]
    if (-not $Result) {
        throw "Cannot find Base Data for EnvironmentName '$EnvironmentName'. Make sure there is an entry in the EnvironmentBaseDataMap."
    }

    # Add properties that depend on the ApplicationName
    $Result["ResourceGroupsNamePattern"] = "${GloballyUniquePrefix}${ApplicationName}*"
    return $Result
}

Function Get-ResourceStandardName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ApplicationName,
        [Parameter(Mandatory)][ValidateSet([ValidEnvironmentNames])][ValidateLength(1, 4)][string]$EnvironmentName,
        [Parameter(Mandatory)][ValidateLength(1, 4)][string]$ApplicationInstanceName,
        [Parameter(Mandatory)][ValidateSet('ResourceGroup', 'StorageAccount', 'CdnProfile', 'CdnEndpoint', 'AppServicePlan', 'AppService', 'PostgreSQLDatabase', 'PostgreSQLFlexibleServer', 'LogAnalyticsWorkspace', 'AppInsights', 'KeyVault')]
        [string]$ResourceType,
        [Parameter(Mandatory)][ValidateSet('GlobalEnvironment', 'ApplicationEnvironment', 'ApplicationInstance')]
        [string]$SharingScope,
        [Parameter()][ValidateScript({
            # Check the maximum length for each resource name in order to fail fast. It does mean we are duplicating validation that the deployment is going to do anyways,
            # but the reason we try to do it here is that the limits are well documented (https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)
            # and a deployment usually takes a considerable time, so it's best to fail before even attempting the action.
            Write-Verbose "Validating parameter FunctionalLabel with value $_. ResourceType='$ResourceType'. SharingScope='$SharingScope'."
            if ($_) {
                if ($ResourceType -eq 'ResourceGroup') {
                    throw "Do not use a FunctionalLabel for a Resource Group's name."
                }
                else {
                    # FunctionalLabel can be null or empty, so we just perform the checks below if it's not null or empty
                    $ResourceTypeData = $ResourceTypeMap[$ResourceType]
                    Write-Debug "ResourceTypeData=$(Format-Hashtable $ResourceTypeData)"
                    if ($ResourceTypeData) {
                        $SharingScopeMap = GetPrefixesForSharingScope $ApplicationName $EnvironmentName $ApplicationInstanceName
                        $SharingScopeData = $SharingScopeMap[$SharingScope]
                        Write-Debug "SharingScopeData=$(Format-Hashtable $SharingScopeData)"

                        if ($SharingScopeData) {
                            $MaxFunctionalLabelLength = $ResourceTypeData.MaxNameLength - $SharingScopeData.MaxNameLength - $ApplicationInstanceName.Length
                            if ($MaxFunctionalLabelLength -lt $_.Length) {
                                throw "The FunctionalLabel '$_' is too long ($($_.Length) characters) and it would make the name of the resource longer than the maximum allowed by Azure ($($ResourceTypeData.MaxNameLength) characters) when including the standard prefix and suffixes. For this type of resource ($ResourceType) in this sharing scope ($SharingScope), the max length for the Functional Label is $MaxFunctionalLabelLength."
                            }
                        }
                        else {
                            throw "Cannot find data for SharingScope '${SharingScope}'. This means there is a mismatch between the ValidateSet attribute for the 'SharingScope' parameter of this function and the SharingScopeMap dictionary. Valid values are $($SharingScopeMap.Keys)"
                        }

                        Write-Verbose "OK: The maximum length of the FunctionalLabel for this Resource Type ('$ResourceType') in this Sharing Scope ('$SharingScope') is $MaxFunctionalLabelLength. The length of the provided FunctionalLabel is $($_.Length)."
                        return $true
                    }
                    else {
                        throw "Cannot find data for ResourceType '${ResourceType}'. This means there is a mismatch between the ValidateSet attribute for the 'ResourceType' parameter of this function and the ResourceTypeMap dictionary."
                    }
                }
            }
            else {
                return $true
            }
        })]
        [string]$FunctionalLabel
    )
    Write-FunctionStart $PSCmdlet.MyInvocation

    $SharingScopePrefixes = GetPrefixesForSharingScope $ApplicationName $EnvironmentName $ApplicationInstanceName
    Write-Debug "SharingScopeMap=$(Format-Hashtable $SharingScopeMap)"
    $SharingScopePrefix = $SharingScopePrefixes[$SharingScope]
    Write-Debug "SharingScopeData=$(Format-Hashtable $SharingScopePrefix)"

    $ResourceTypeData = $ResourceTypeMap[$ResourceType]
    Write-Debug "ResourceTypeData=$(Format-Hashtable $ResourceTypeData)"

    $Result = "$($SharingScopePrefix.Value)${FunctionalLabel}$($ResourceTypeData.Suffix)"
    if ($Result.Length -gt $ResourceTypeData.MaxNameLength) {
        throw "The resulting name '$Result' has $($Result.Length) characters, which is more than the maximum allowed by Azure ($($ResourceTypeData.MaxNameLength)) for this type of resource ($($ResourceTypeData.EntityType))"
    }
    Write-Verbose "The Resource Standard Name is '$Result' which has $($Result.Length) characters."
    return $Result
}

Function Get-EmsurgeResource {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string]$ApplicationName,
        [Parameter(Mandatory)][ValidateSet([ValidEnvironmentNames])][ValidateLength(1, 4)][string]$EnvironmentName,
        [Parameter(Mandatory)][ValidateLength(1, 4)][string]$ApplicationInstanceName,
        [Parameter(Mandatory)][ValidateSet('ResourceGroup', 'StorageAccount', 'CdnProfile', 'CdnEndpoint', 'AppServicePlan', 'AppService', 'PostgreSQLFlexibleServer', 'AppInsights', 'KeyVault')]
        [string]$ResourceType,
        [Parameter(Mandatory)][ValidateSet('GlobalEnvironment', 'ApplicationEnvironment', 'ApplicationInstance')]
        [string]$SharingScope,
        [Parameter()][string]$FunctionalLabel
    )
    Write-FunctionStart $PSCmdlet.MyInvocation
    $GetResourceStandardNameParams = @{
        ApplicationName = $ApplicationName
        EnvironmentName = $EnvironmentName
        ApplicationInstanceName = $ApplicationInstanceName
        SharingScope = $SharingScope
        Verbose = $VerbosePreference
        Debug = $DebugPreference
    }

    Write-PreCallInvocation Get-ResourceStandardName $GetResourceStandardNameParams

    if ($ResourceType -eq 'ResourceGroup') {
        $ResourceGroupName = Get-ResourceStandardName @GetResourceStandardNameParams -ResourceType $ResourceType
        $Result = Get-AzResourceGroup -Name $ResourceName -Verbose:$VerbosePreference -Debug:$DebugPreference
    }
    else {
        $ResourceGroupName = Get-ResourceStandardName @GetResourceStandardNameParams -ResourceType ResourceGroup
        $ResourceName = Get-ResourceStandardName @GetResourceStandardNameParams -ResourceType $ResourceType -FunctionalLabel $FunctionalLabel
        $GetAzXParams = @{
            ResourceGroupName = $ResourceGroupName
            Verbose = $VerbosePreference
            Debug = $DebugPreference
        }
        switch ($ResourceType) {
            'StorageAccount' { $Result = Get-AzStorageAccount @GetAzXParams -Name $ResourceName }
            'CdnProfile' { $Result = Get-AzCdnProfile @GetAzXParams -ProfileName $ResourceName }
            'CdnEndpoint' {
                # Find the CdnProfile with the same properties as the CdnEndpoint
                $CdnProfile = Get-EmsurgeResource @GetResourceStandardNameParams -ResourceType CdnProfile -FunctionalLabel $FunctionalLabel
                $Result = Get-AzCdnEndpoint @GetAzXParams -ProfileName $CdnProfile.Name -EndpointName $ResourceName
            }
            'AppServicePlan' { $Result = Get-AzAppServicePlan @GetAzXParams -Name $ResourceName }
            'AppService' { $Result = Get-AzWebApp @GetAzXParams -Name $ResourceName }
            'PostgreSQLFlexibleServer' { $Result = Get-AzPostgreSQLFlexibleServer @GetAzXParams -Name $ResourceName }
            'AppInsights' { $Result = Get-AzApplicationInsights @GetAzXParams -Name $ResourceName }
            'KeyVault' { $Result = Get-AzKeyVault @GetAzXParams -VaultName $ResourceName }
            Default { throw "Unknown Resource Type $ResourceType" }
        }
    }
    return $Result
}

Function Get-CdnDataObject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string]$CdnProfileName,
        [Parameter(Mandatory)][string]$CdnEndpointPartialName
    )
    Write-FunctionStart $PSCmdlet.MyInvocation
    $Result = @{
        Profile = @{
            Name = $CdnProfileName
        }
        Endpoint = @{
            PartialName = $CdnEndpointPartialName
            Name = "${CdnProfileName}/${CdnEndpointPartialName}"
        }
    }
    return $Result
}

Function Get-AzContextPrincipal {
    [CmdletBinding()]
    param(
        [Parameter()]$AzContext = $null
    )
    Write-FunctionStart $PSCmdlet.MyInvocation
    if (!($AzContext)) {
        $AzContext = Get-AzContext -Verbose:$VerbosePreference -Debug:$DebugPreference
    }
    $Result = @{
        AccountId = $AzContext.Account.Id
        AccountType = $AzContext.Account.Type
    }
    if ($Result.AccountType -eq 'User') {
        $User = Get-AzADUser -UserPrincipalName $Result.AccountId -Verbose:$VerbosePreference -Debug:$DebugPreference
        $Result["PrincipalId"] = $User.Id
    }
    return $Result
}

Function Ensure-AzContext {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$DeploymentContext
    )
    Write-FunctionStart $PSCmdlet.MyInvocation
    $AzContext = Get-AzContext
    if ($null -eq $AzContext) {
        Write-Host "No AzContext found. Creating one now..."
        $AzContext = New-AzContext -DeploymentContext $DeploymentContext -Verbose:$VerbosePreference -Debug:$DebugPreference
    }
    elseif ($AzContext.Subscription.Id -ne $DeploymentContext.EnvironmentData.BaseData.SubscriptionId) {
        Write-Host "AzContext found but does not match the required TenantId='$($DeploymentContext.EnvironmentData.BaseData.TenantId)' and SubscriptionId='$($DeploymentContext.EnvironmentData.BaseData.SubscriptionId)'. Found TenantId='$($AzContext.Tenant.Id)' and SubscriptionId='$($AzContext.Subscription.Id)'."
        $AzContext = New-AzContext -DeploymentContext $DeploymentContext -Verbose:$VerbosePreference -Debug:$DebugPreference
    }
    else {
        if ($DeploymentContext.IsInteractive) {
            Write-Host "Interactive AzContext validated [TenantId='$($AzContext.Tenant.Id)'; SubscriptionId='$($AzContext.Subscription.Id)'; PrincipalType='$($CurrentAzContextPrincipal.PrincipalType)'; PrincipalId='$($CurrentAzContextPrincipal.PrincipalId)']. No need to sign in again."
        }
        else {
            $CurrentAzContextPrincipal = Get-AzContextPrincipal $AzContext
            if ($CurrentAzContextPrincipal.PrincipalId -ne $DeploymentContext.ServicePrincipalApplicationId) {
                Write-Host "AzContext found for the required TenantId='$($DeploymentContext.EnvironmentData.BaseData.TenantId)' and SubscriptionId='$($DeploymentContext.EnvironmentData.BaseData.SubscriptionId)', but the Principal '$($CurrentAzContextPrincipal.PrincipalId)' does not match the required Service Principal '$($DeploymentContext.ServicePrincipalApplicationId)'. Found TenantId=$($AzContext.Tenant.Id) and Subscription=$($AzContext.Subscription.Id)"
                $AzContext = New-AzContext -DeploymentContext $DeploymentContext -Verbose:$VerbosePreference -Debug:$DebugPreference
            }
            else {
                Write-Host "Unattended AzContext validated [TenantId='$($AzContext.Tenant.Id)'; SubscriptionId='$($AzContext.Subscription.Id)'; PrincipalType='$($CurrentAzContextPrincipal.PrincipalType); PrincipalId='$($CurrentAzContextPrincipal.PrincipalId)']. No need to sign in again."
            }
        }
    }
    return $AzContext
}

Function New-AzContext {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]$DeploymentContext
    )
    Write-FunctionStart $PSCmdlet.MyInvocation
    if ($DeploymentContext.IsInteractive) {
        Write-Host "No Service Principal details provided. Starting interactive log in..."
        Connect-AzAccount -Tenant $DeploymentContext.EnvironmentData.BaseData.TenantId -Subscription $DeploymentContext.EnvironmentData.BaseData.SubscriptionId -UseDeviceAuthentication -Verbose:$VerbosePreference -Debug:$DebugPreference | Out-Null
    }
    else {
        Write-Host "Service Principal details were provided. Starting Service Principal log in..."
        [PSCredential]$ServicePrincipalCredentials = New-Object System.Management.Automation.PSCredential ($DeploymentContext.ServicePrincipalApplicationId, $DeploymentContext.ServicePrincipalClientSecret)
        Connect-AzAccount -Tenant $DeploymentContext.EnvironmentData.BaseData.TenantId -Subscription $DeploymentContext.EnvironmentData.BaseData.SubscriptionId -ServicePrincipal -Credential $ServicePrincipalCredentials -Verbose:$VerbosePreference -Debug:$DebugPreference | Out-Null
    }
    $Result = Get-AzContext
    return $Result
}

Function Set-ResourceGroup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Location,
        [Parameter(Mandatory)][string]$Description
    )
    $ResourceGroup = Get-AzResourceGroup -Name $Name -ErrorAction SilentlyContinue -Verbose:$VerbosePreference
    if ($null -eq $ResourceGroup) {
        Write-Host "$Description Resource Group '$Name' not found. Creating it now with Location '$Location'..."
        $ResourceGroup = New-AzResourceGroup -Name $Name -Location $Location -Verbose:$VerbosePreference -Debug:$DebugPreference
    }
    else {
        Write-Host "$Description Resource Group $Name) found. No need to create it."
        if ($ResourceGroup.Location -ne $Location) {
            throw "The location '$($ResourceGroup.Location)' of the existing Resource Group '$Name' does not match the location specified in this script '$Location'"
        }
    }
}

Function Write-PreCallInvocation([string]$FunctionName, [Hashtable]$Params) {
    Write-Verbose "++++++++++++ Calling '$FunctionName' with Params=[$(Format-Hashtable $Params)]"
}

Function Write-FunctionStart($MyInvocationObject) {
    Write-Verbose "******************************************************** Entering '$($MyInvocationObject.InvocationName)' with Params=[$(Format-Hashtable $MyInvocationObject.BoundParameters)] ***"
}

Function Format-Hashtable($Params) {
    $Result = $Params | Out-String
    foreach ($key in $Params.Keys) {
        $value = $Params[$key]
        if ($Value -and $Value.GetType().Name -eq "Hashtable") {
            $Result += "$key (Expanding the Hashtable)={$($Value | Out-String)}"
            $Result += Format-Hashtable $value
        }
    }
    return $Result
}

Function Get-DeploymentOutputValue {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0)]$ObjectThatCouldBeJValue
    )
    Write-Verbose "Trying to get value from object of type $($ObjectThatCouldBeJValue.GetType()). .Value = $($ObjectThatCouldBeJValue.Value)"
    $Result = $ObjectThatCouldBeJValue.Value
    if ($null -eq $Result) {
        Write-Verbose ".Value was `$null. Returning the original object"
        $Result = $ObjectThatCouldBeJValue
    }
    Write-Verbose "Result is $Result"
    return $Result
}

Function GetPostgreSQLServer($EnvironmentData) {
    $Result = Get-AzResource -ResourceGroupName $EnvironmentData.GlobalEnvironmentScope.ResourceGroup.Name -ResourceType "Microsoft.DBForPOstgreSQL/flexibleServers" -Verbose:$VerbosePreference -Debug:$DebugPreference
    return $Result
}

Function Start-AzCopySync([string]$source, [string]$target, [bool]$useCopyInsteadOfSync = $false) {
    $SourceFullPath = Resolve-Path $source

    if ($useCopyInsteadOfSync) {
        $Command = "azcopy copy $SourceFullPath $target --put-md5 --recursive=true"
        Write-Verbose "Executing $Command"
        azcopy copy $SourceFullPath $target --put-md5 --recursive=true
    }
    else {
        $Command = "azcopy sync $SourceFullPath $target --put-md5 --delete-destination=true --recursive=true"
        Write-Verbose "Executing $Command"
        azcopy sync $SourceFullPath $target --put-md5 --delete-destination=true --recursive=true
    }
    $AzCopyExitCode = $LastExitCode
    if ($AzCopyExitCode -ne 0) {
        throw "$Command failed with error code $AzCopyExitCode. See messages above for more details."
    }
}

Function Run-Psql {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)][string]$Hostname,
        [Parameter(Mandatory)][string]$User,
        [Parameter(Mandatory)][SecureString]$Password,
        [Parameter(Mandatory)][string]$SQL,
        [Parameter()][AllowNull()][string]$Database = $null
    )
    $Command = "psql -t -h $Hostname -U $User -c `"$SQL`""
    if ($Database) {
        $Command += " -d $Database"
    }
    else {
        $Command += " -d postgres"
    }

    $ClearTextPassword = ConvertFrom-SecureString $Password -AsPlainText
    Write-Verbose "password=$ClearTextPassword; Executing $Command"

    # See https://dba.stackexchange.com/a/14741 for details about passing a password to psql
    $Env:PGPASSWORD = $ClearTextPassword
    if ($Database) {
        $Result = psql -t -h $Hostname -d $Database -U $User -c `"$SQL`"
    }
    else {
        $Result = psql -t -h $Hostname -d postgres -U $User -c `"$SQL`"
    }
    $PsqlExitCode = $LastExitCode
    if ($PsqlExitCode -ne 0) {
        throw "$Command failed with error code $PsqlExitCode. See messages above for more details."
    }

    return $Result
}

# Example from https://www.codeguru.com/csharp/csharp/cs_misc/security/article.php/c14557/Cryptographically-Random-Password-Generator.htm
Function New-RandomPassword {
    # This is not completely random but should be good enough for our purposes
    $Characters = @('A','a','B','b','C','c','D','d','E','e','F','f','G','g','H','h','I','i','J','j','K','k','L','l','M','m','N','n','O','o','P','p','Q','q','R','r','S','s','T','t','U','u','V','v','W','w','X','x','Y','y','Z','z','_','-','.')
    $RandomBytes = New-Object byte[] 4
    $crypto = [System.Security.Cryptography.RNGCryptoServiceProvider]::Create()
    $crypto.GetBytes($RandomBytes)
    [int]$RandomInt = [System.BitConverter]::ToInt32($RandomBytes)
    $Random = New-Object System.Random $RandomInt
    $Password = ''
    for ($i=0; $i -lt 20; $i++) {
        $Password += $Characters[$Random.Next($Characters.Length)]
    }
    [SecureString]$Result = ConvertTo-SecureString $Password -AsPlainText
    return $Result
}

Function Get-SafeValue($Value) {
    if ($Value) {
        return $Value
    }
    else {
        throw "The value is null!"
    }
}

Write-Host -ForegroundColor Green "Emsurge Common functions loaded."