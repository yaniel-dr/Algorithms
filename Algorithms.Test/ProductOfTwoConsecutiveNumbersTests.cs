using Algorithms.Implementation;
using FluentAssertions;
using Xunit;

namespace Algorithms.Test
{
    public class ProductOfTwoConsecutiveNumbersTests
    {
        ProductOfTwoConsecutiveNumbers sut = new ProductOfTwoConsecutiveNumbers();

        [Theory]
        [InlineData(6, 20, 3)]
        [InlineData(21, 29, 0)]
        public void ShouldFindAllConsecutivePairs( int leftInterval, int rightInterval, int solution)
        {
            sut.Solution(leftInterval, rightInterval).Should().Be(solution);
        }
    }
}
