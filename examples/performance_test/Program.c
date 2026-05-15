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

typedef struct {
    int* keys;
    char* used;
    int capacity;
    int size;
} IntHashSet;

static void hashset_init(IntHashSet* s, int cap) {
    s->capacity = cap;
    s->keys = (int*)calloc((size_t)cap, sizeof(int));
    s->used = (char*)calloc((size_t)cap, sizeof(char));
    s->size = 0;
}

static void hashset_free(IntHashSet* s) {
    free(s->keys);
    free(s->used);
}

static void hashset_add(IntHashSet* s, int value);

static void hashset_grow(IntHashSet* s) {
    int old_cap = s->capacity;
    int* old_keys = s->keys;
    char* old_used = s->used;
    s->capacity = old_cap * 2;
    s->keys = (int*)calloc((size_t)s->capacity, sizeof(int));
    s->used = (char*)calloc((size_t)s->capacity, sizeof(char));
    s->size = 0;
    for (int i = 0; i < old_cap; i++) {
        if (old_used[i]) hashset_add(s, old_keys[i]);
    }
    free(old_keys);
    free(old_used);
}

static void hashset_add(IntHashSet* s, int value) {
    if (s->size * 2 >= s->capacity) hashset_grow(s);
    unsigned int h = (unsigned int)value;
    h ^= h >> 16; h *= 0x45d9f3bU; h ^= h >> 16;
    int idx = (int)(h % (unsigned int)s->capacity);
    while (s->used[idx]) {
        if (s->keys[idx] == value) return;
        idx = (idx + 1) % s->capacity;
    }
    s->keys[idx] = value;
    s->used[idx] = 1;
    s->size++;
}

static long long now_ms(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (long long)ts.tv_sec * 1000LL + (long long)ts.tv_nsec / 1000000LL;
}

static volatile long long sinkX = 0;
static volatile long long sinkY = 0;

static NOINLINE void handlePoints(long long iterations, long long count, long long modulo) {
    long long start = now_ms();
    long long sumX = 0;
    long long sumY = 0;

    for (long long j = 0; j < iterations; j++) {
        Point* points = (Point*)malloc((size_t)count * sizeof(Point));

        for (long long i = 0; i < count; i++) {
            points[i].x = i;
            points[i].y = i * 2;
        }

        for (long long i = 0; i < count; i++) {
            if (i % modulo == 0) {
                continue;
            }
            sumX += points[i].x;
            sumY += points[i].y;
        }

        free(points);
    }

    long long elapsed = now_ms() - start;

    sinkX = sumX;
    sinkY = sumY;

    printf("Time taken to create and sum %lld points: %lld ms\n",
           (long long)count * iterations,
           elapsed);
    printf("Sum of X: %lld, Sum of Y: %lld\n", sumX, sumY);
}

static NOINLINE void handlePoints2(long long iterations, long long count, long long modulo) {
    long long start = now_ms();
    long long sumX = 0;
    long long sumY = 0;

    for (long long j = 0; j < iterations; j++) {
        for (long long i = 0; i < count; i++) {
            if (i % modulo == 0) {
                continue;
            }
            Point point;
            point.x = i;
            point.y = i * 2;
            sumX += point.x;
            sumY += point.y;
        }
    }

    long long elapsed = now_ms() - start;

    sinkX = sumX;
    sinkY = sumY;

    printf("Time taken to create and sum without array %lld points: %lld ms\n",
           (long long)count * iterations,
           elapsed);
    printf("Sum of X: %lld, Sum of Y: %lld\n", sumX, sumY);
}

static NOINLINE void handleHashSet(long long iterations, long long count, long long modulo) {
    long long start = now_ms();
    long long totalSize = 0;

    for (long long j = 0; j < iterations; j++) {
        IntHashSet set;
        hashset_init(&set, 256);
        for (long long i = 0; i < count; i++) {
            if (i % modulo == 0) continue;
            hashset_add(&set, (int)i);
        }
        totalSize += set.size;
        hashset_free(&set);
    }

    long long elapsed = now_ms() - start;
    printf("Time taken to populate HashSet<Int> %lld x %lld values: %lld ms\n",
           iterations, count, elapsed);
    printf("Total accumulated size: %lld\n", totalSize);
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
    handleHashSet(iterations, count, modulo);
    return 0;
}
