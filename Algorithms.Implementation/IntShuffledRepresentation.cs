using System;

namespace Algorithms.Implementation
{
    /*
    Problem:
    
    Shuffle the digits of a number in the following way: write one digit from
    the front of the number and one digit from the back, then the second
    digit from the front and the second from the back, and so on until the
    length of the shuffled number is the same as that of the original.
    
    For example given 123456 the function should return 162534.
    
    Assume that the number is an integer within the range [0 .. 1 000 000 000 ]
    */
    public class IntShuffledRepresentation
    {
        public int Solution(int value)
        {
            int numberOfDigits = Convert.ToInt32(Math.Floor(Math.Log10(value))) + 1;
            if(numberOfDigits == 1 || numberOfDigits == 2) return value;
            
            int result = 0;
            var numberOfIterations = numberOfDigits / 2;
            for (int i = 0; i < numberOfIterations; i++)
            {
                var firstDigitPosition = numberOfDigits - i;
                var secondDigitPosition = i + 1;
                var newFirstDigitPosition = numberOfDigits - 2*i;
                var newSecondDigitPosition = numberOfDigits - 2*i - 1;
                result += 
                    GetNumberForPosition(GetDigitInPosition(value, firstDigitPosition), newFirstDigitPosition ) + 
                    GetNumberForPosition(GetDigitInPosition(value, secondDigitPosition), newSecondDigitPosition);
            } 

            var isEvenNumber = numberOfDigits % 2 == 0;
            if(isEvenNumber) return result;

            var middleDigitPosition = numberOfIterations + 1;
            result += GetNumberForPosition(GetDigitInPosition(value, middleDigitPosition), 1);

            return result;   
        }

        private int GetDigitInPosition(int number, int position)
        {
            return (number / (int)Math.Pow(10, position - 1)) % 10;
        }
        private int GetNumberForPosition(int number, int position)
        {
            return number * (int)Math.Pow(10, position - 1);
        }
 
        public int RecursiveSolution(int value)
        {
            int numberOfDigits = (int)Math.Floor(Math.Log10(value)) + 1;
            if(numberOfDigits == 1 || numberOfDigits == 2) return value;
            var powerOf10 = (int)Math.Pow(10, numberOfDigits - 1);
            var numberWithoutOneDigit =  (value % powerOf10);
            return value  - numberWithoutOneDigit +
                  (value % 10 * powerOf10 / 10) +
                  RecursiveSolution(numberWithoutOneDigit / 10);
        }
    }
}
