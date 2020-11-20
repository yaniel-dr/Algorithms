using System;
namespace Algorithms.Implementation
{
    /*
    Write a function that, given two integers A and B, returns
    the number of integers from the range [A..B] (ends are included) wihn
    can be expressed as the product of two consecutive integers, X * (X + 1).

    Examples:

    1. Given A = 6 and B : 20 the function should return 3. These integers
    are: 6=2*3. 12=3*4 and 2O=4*5.

    2. Given A = 21 and B = 29. the tunction should return 0. There are no
    integers on the farm X * (X + 1) in this interval.

    Asume that: 
     - A and B are integers within the range [1..1,000,000,000]
     - A <= B  
    */
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
