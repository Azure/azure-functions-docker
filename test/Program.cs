using System;
using System.IO;

namespace Test
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length != 1)
            {
                Console.Error.WriteLine("image name required");
                Environment.Exit(1);
            }

            try
            {
                TestRunner.Run(args[0]);
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                Environment.Exit(-1);
            }
        }
    }
}
