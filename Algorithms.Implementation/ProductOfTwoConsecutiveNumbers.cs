using System;
namespace Algorithms.Implementation
{
    public class ProductOfTwoConsecutiveNumbers
    {
        public int Solution(int leftInterval, int rightInterval)
        {
            var firtConsecutiveFactorCloseToLeftInterval = (int)Math.Floor(Math.Sqrt( leftInterval));
            var secondConsecutiveFactorCloseToLeftInterval = (int)Math.Ceiling(Math.Sqrt( leftInterval));
            var firstConsecutiveNumber = firtConsecutiveFactorCloseToLeftInterval;
            if(firtConsecutiveFactorCloseToLeftInterval * secondConsecutiveFactorCloseToLeftInterval < leftInterval)
            {
               firstConsecutiveNumber = secondConsecutiveFactorCloseToLeftInterval;     
            } 
            var firtConsecutiveFactorCloseToRightInterval = (int)Math.Floor(Math.Sqrt( rightInterval));
            var secondConsecutiveFactorCloseToRightInterval = (int)Math.Ceiling(Math.Sqrt( rightInterval));
            var secondConsecutiveNumber = firtConsecutiveFactorCloseToRightInterval;
            if(firtConsecutiveFactorCloseToRightInterval * secondConsecutiveFactorCloseToRightInterval > rightInterval)
            {
               secondConsecutiveNumber = firtConsecutiveFactorCloseToRightInterval - 1;     
            } 
            return secondConsecutiveNumber - firstConsecutiveNumber + 1;
        }
    }
}
