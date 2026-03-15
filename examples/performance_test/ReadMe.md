# Performance Test Results

Workload used for all runs:
- Iterations: `1000`
- Count per iteration: `100000`
- Modulo: `7` (skip when `i % modulo == 0`)
- Total points processed: `100000000`

## Results

| Language | `handlePoints` (array) | `handlePoints2` (no array) |
|---|---:|---:|
| Rust (`rustc -C opt-level=2`) | 476 ms | 331 ms |
| C (pure, gcc -O3) | 986 ms | 846 ms |
| AmLang | 986 ms | 819 ms |
| Go | 1290 ms | 867 ms |
| Java | 1632 ms | 881 ms |
| C# (`struct Point`) | 1946 ms | 826 ms |
| Python | 52151 ms | 34041 ms |

## Notes

- `handlePoints`: create all points in an array, then sum in a second pass.
- `handlePoints2`: create point and sum immediately (no array).
- Python results are kept as-is from the earlier baseline run.
- C# uses `Point` as a `readonly struct`.
- Rust results shown are using `-C opt-level=2`.
