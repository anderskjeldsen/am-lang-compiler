import time
import sys


class Point:
    __slots__ = ("x", "y")

    def __init__(self, x: int, y: int) -> None:
        self.x = x
        self.y = y


def handle_points(iterations: int, count: int, modulo: int) -> None:
    start = time.perf_counter()
    sum_x = 0
    sum_y = 0

    for _ in range(iterations):
        points = [None] * count
        for i in range(count):
            points[i] = Point(i, i * 2)

        for i in range(count):
            if i % modulo == 0:
                continue
            p = points[i]
            sum_x += p.x
            sum_y += p.y

    elapsed_ms = int((time.perf_counter() - start) * 1000)
    print(f"Time taken to create and sum {count * iterations} points: {elapsed_ms} ms")
    print(f"Sum of X: {sum_x}, Sum of Y: {sum_y}")


def handle_points2(iterations: int, count: int, modulo: int) -> None:
    start = time.perf_counter()
    sum_x = 0
    sum_y = 0

    for _ in range(iterations):
        for i in range(count):
            if i % modulo == 0:
                continue
            p = Point(i, i * 2)
            sum_x += p.x
            sum_y += p.y

    elapsed_ms = int((time.perf_counter() - start) * 1000)
    print(
        f"Time taken to create and sum without array {count * iterations} points: {elapsed_ms} ms"
    )
    print(f"Sum of X: {sum_x}, Sum of Y: {sum_y}")


def main() -> None:
    iterations = 1000
    count = 100000
    modulo = 7

    if len(sys.argv) >= 2:
        iterations = int(sys.argv[1])
    if len(sys.argv) >= 3:
        count = int(sys.argv[2])
    if len(sys.argv) >= 4:
        modulo = int(sys.argv[3])

    if iterations <= 0 or count <= 0 or modulo <= 0:
        print("Usage: Program.py [iterations>0] [count>0] [modulo>0]", file=sys.stderr)
        raise SystemExit(1)

    print("Welcome to performance_test!")
    handle_points(iterations, count, modulo)
    handle_points2(iterations, count, modulo)


if __name__ == "__main__":
    main()
