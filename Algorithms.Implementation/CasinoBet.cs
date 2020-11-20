using System;

namespace Algorithms.Implementation
{
    /*
    Problem:

    John gambles at the casino in two ways in each game:

    - betting exactly one chip
    - betting all—in (he bets everyming he has).

    Wins in me casino are paid equal to the bet.

    It was a very lucky day yesterday and John won every game he
    played, starting with one chip and leaving the casino with N chips.
    We also know that he played all—in no more man K times. 
    Calculate the smallest possible number of rounds he
    could have played.

    Note: betting just one chip is never considered playing all—in.

    Write a function that, given an integer N and an integer K, 
    returns me minimum number of rounds that are necessary for
    Jonn to leave thee casino with N chips, having played all—in 
    no more man K times.

    Given N : 8 and K : 0, the answer is 7. 
    Given N : 10 and K : 10, the answer is 4. 
    */
    
    public class CasinoBet
    {
        public int Solution(int totalEarned, int maximunAllIn)
        {
            if(totalEarned == 1) return 0;
            return GetMinimunBet(totalEarned, maximunAllIn);
        }

        private int GetMinimunBet(int totalEarned, int maximunAllIn)
        {
            if (totalEarned == 2 || maximunAllIn == 0) return totalEarned - 1;
            var hasWinWithAllIn = totalEarned % 2 == 0;
            if(hasWinWithAllIn) return 1 + GetMinimunBet( totalEarned / 2, maximunAllIn -1);
            return 1 + GetMinimunBet(totalEarned - 1, maximunAllIn);
        }
    }
}
