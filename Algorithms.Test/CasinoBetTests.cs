using Algorithms.Implementation;
using FluentAssertions;
using Xunit;

namespace Algorithms.Test
{
    public class CasinoBetTests
    {
        CasinoBet sut = new CasinoBet();

        [Theory]
        [InlineData(8, 0, 7)]
        [InlineData(10, 10, 4)]
        [InlineData(1, 10, 0)]
        [InlineData(2, 10, 1)]
        [InlineData(4, 10, 2)]
        public void Should_Shuffle( int totalEarned, int maximunAllIn, int solution)
        {
            sut.Solution(totalEarned, maximunAllIn).Should().Be(solution);
        }
    }
}
