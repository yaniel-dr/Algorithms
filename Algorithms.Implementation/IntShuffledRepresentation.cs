using System;

namespace Algorithms.Implementation
{
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
    }
}
