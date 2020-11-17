using System;

namespace Algorithms.Implementation
{
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
