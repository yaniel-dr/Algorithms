using Algorithms.Implementation;
using FluentAssertions;
using Xunit;

namespace Algorithms.Test
{
    public class IntShuffledRepresentationTests
    {
        IntShuffledRepresentation sut = new IntShuffledRepresentation();

        [Theory]
        [InlineData(1, 1)]
        [InlineData(13, 13)]
        [InlineData(130, 103)]
        [InlineData(123456, 162534)]
        public void Should_Shuffle( int value, int solution)
        {
            sut.Solution(value).Should().Be(solution);
            sut.RecursiveSolution(value).Should().Be(solution);
        }
    }
}
