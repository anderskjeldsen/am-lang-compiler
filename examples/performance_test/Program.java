public class Program {
    private static final class Point {
        final long x;
        final long y;

        Point(long x, long y) {
            this.x = x;
            this.y = y;
        }
    }

    public static void main(String[] args) {
        long iterations = 1000;
        long count = 100000;
        long modulo = 7;

        if (args.length >= 1) {
            iterations = Long.parseLong(args[0]);
        }
        if (args.length >= 2) {
            count = Long.parseLong(args[1]);
        }
        if (args.length >= 3) {
            modulo = Long.parseLong(args[2]);
        }

        if (iterations <= 0 || count <= 0 || modulo <= 0) {
            System.err.println("Usage: Program [iterations>0] [count>0] [modulo>0]");
            System.exit(1);
        }

        if (count > Integer.MAX_VALUE) {
            System.err.println("count must be <= " + Integer.MAX_VALUE + " for Java arrays");
            System.exit(1);
        }

        System.out.println("Welcome to performance_test!");
        handlePoints(iterations, count, modulo);
        handlePoints2(iterations, count, modulo);
    }

    static void handlePoints(long iterations, long count, long modulo) {
        long startTime = System.currentTimeMillis();
        long sumX = 0;
        long sumY = 0;
        int countInt = (int) count;

        for (long j = 0; j < iterations; j++) {
            Point[] points = new Point[countInt];
            for (int i = 0; i < countInt; i++) {
                points[i] = new Point(i, i * 2);
            }

            for (int i = 0; i < countInt; i++) {
                if (i % modulo == 0) {
                    continue;
                }
                sumX += points[i].x;
                sumY += points[i].y;
            }
        }

        long endTime = System.currentTimeMillis();
        long deltaTime = endTime - startTime;

        System.out.println("Time taken to create and sum " + (count * iterations) + " points: " + deltaTime + " ms");
        System.out.println("Sum of X: " + sumX + ", Sum of Y: " + sumY);
    }

    static void handlePoints2(long iterations, long count, long modulo) {
        long startTime = System.currentTimeMillis();
        long sumX = 0;
        long sumY = 0;

        for (long j = 0; j < iterations; j++) {
            for (long i = 0; i < count; i++) {
                if (i % modulo == 0) {
                    continue;
                }
                Point point = new Point(i, i * 2);
                sumX += point.x;
                sumY += point.y;
            }
        }

        long endTime = System.currentTimeMillis();
        long deltaTime = endTime - startTime;

        System.out.println("Time taken to create and sum without array " + (count * iterations) + " points: " + deltaTime + " ms");
        System.out.println("Sum of X: " + sumX + ", Sum of Y: " + sumY);
    }
}
