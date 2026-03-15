using System;
using System.Diagnostics;

public static class Program
{
    private readonly struct Point
    {
        public readonly long X;
        public readonly long Y;

        public Point(long x, long y)
        {
            X = x;
            Y = y;
        }
    }

    public static void Main(string[] args)
    {
        long iterations = 1000;
        long count = 100000;
        long modulo = 7;

        if (args.Length >= 1)
        {
            iterations = long.Parse(args[0]);
        }
        if (args.Length >= 2)
        {
            count = long.Parse(args[1]);
        }
        if (args.Length >= 3)
        {
            modulo = long.Parse(args[2]);
        }

        if (iterations <= 0 || count <= 0 || modulo <= 0)
        {
            Console.Error.WriteLine("Usage: Program [iterations>0] [count>0] [modulo>0]");
            Environment.Exit(1);
        }

        if (count > int.MaxValue)
        {
            Console.Error.WriteLine($"count must be <= {int.MaxValue} for C# arrays");
            Environment.Exit(1);
        }

        Console.WriteLine("Welcome to performance_test!");
        HandlePoints(iterations, count, modulo);
        HandlePoints2(iterations, count, modulo);
    }

    private static void HandlePoints(long iterations, long count, long modulo)
    {
        var sw = Stopwatch.StartNew();
        long sumX = 0;
        long sumY = 0;
        var countInt = (int)count;

        for (long j = 0; j < iterations; j++)
        {
            var points = new Point[countInt];
            for (int i = 0; i < countInt; i++)
            {
                points[i] = new Point(i, i * 2);
            }

            for (int i = 0; i < countInt; i++)
            {
                if (i % modulo == 0)
                {
                    continue;
                }
                sumX += points[i].X;
                sumY += points[i].Y;
            }
        }

        sw.Stop();

        Console.WriteLine($"Time taken to create and sum {count * iterations} points: {sw.ElapsedMilliseconds} ms");
        Console.WriteLine($"Sum of X: {sumX}, Sum of Y: {sumY}");
    }

    private static void HandlePoints2(long iterations, long count, long modulo)
    {
        var sw = Stopwatch.StartNew();
        long sumX = 0;
        long sumY = 0;

        for (long j = 0; j < iterations; j++)
        {
            for (long i = 0; i < count; i++)
            {
                if (i % modulo == 0)
                {
                    continue;
                }
                var point = new Point(i, i * 2);
                sumX += point.X;
                sumY += point.Y;
            }
        }

        sw.Stop();

        Console.WriteLine($"Time taken to create and sum without array {count * iterations} points: {sw.ElapsedMilliseconds} ms");
        Console.WriteLine($"Sum of X: {sumX}, Sum of Y: {sumY}");
    }
}
