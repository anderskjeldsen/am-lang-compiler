#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#if defined(__GNUC__) || defined(__clang__)
#define NOINLINE __attribute__((noinline))
#else
#define NOINLINE
#endif

typedef struct {
    long long x;
    long long y;
} Point;

static long long now_ms(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (long long)ts.tv_sec * 1000LL + (long long)ts.tv_nsec / 1000000LL;
}

static volatile uint64_t sinkX = 0;
static volatile uint64_t sinkY = 0;

static NOINLINE void handlePoints(long long iterations, long long count, long long modulo) {
    long long start = now_ms();
    uint64_t sumX = 0;
    uint64_t sumY = 0;

    for (long long j = 0; j < iterations; j++) {
        Point* points = (Point*)malloc((size_t)count * sizeof(Point));
        if (points == NULL) {
            fprintf(stderr, "Allocation failed\n");
            exit(1);
        }

        for (long long i = 0; i < count; i++) {
            points[i].x = i;
            points[i].y = i * 2;
        }

        for (long long i = 0; i < count; i++) {
            if (i % modulo == 0) {
                continue;
            }
            sumX += (uint64_t)points[i].x;
            sumY += (uint64_t)points[i].y;
        }

        free(points);
    }

    long long elapsed = now_ms() - start;

    sinkX = sumX;
    sinkY = sumY;

    printf("Time taken to create and sum %lld points: %lld ms\n",
           (long long)count * iterations,
           elapsed);
    printf("Sum of X: %llu, Sum of Y: %llu\n",
           (unsigned long long)sumX,
           (unsigned long long)sumY);
}

static NOINLINE void handlePoints2(long long iterations, long long count, long long modulo) {
    long long start = now_ms();
    uint64_t sumX = 0;
    uint64_t sumY = 0;

    for (long long j = 0; j < iterations; j++) {
        for (long long i = 0; i < count; i++) {
            if (i % modulo == 0) {
                continue;
            }
            Point point;
            point.x = i;
            point.y = i * 2;
            sumX += (uint64_t)point.x;
            sumY += (uint64_t)point.y;
        }
    }

    long long elapsed = now_ms() - start;

    sinkX = sumX;
    sinkY = sumY;

    printf("Time taken to create and sum without array %lld points: %lld ms\n",
           (long long)count * iterations,
           elapsed);
    printf("Sum of X: %llu, Sum of Y: %llu\n",
           (unsigned long long)sumX,
           (unsigned long long)sumY);
}

int main(int argc, char** argv) {
    long long iterations = 1000;
    long long count = 100000;
    long long modulo = 7;

    if (argc > 1) {
        iterations = atoll(argv[1]);
    }
    if (argc > 2) {
        count = atoll(argv[2]);
    }
    if (argc > 3) {
        modulo = atoll(argv[3]);
    }

    if (iterations <= 0 || count <= 0 || modulo <= 0) {
        fprintf(stderr, "Usage: %s [iterations>0] [count>0] [modulo>0]\n", argv[0]);
        return 1;
    }

    puts("Welcome to performance_test!");
    handlePoints(iterations, count, modulo);
    handlePoints2(iterations, count, modulo);
    return 0;
}
