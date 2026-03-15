use std::env;
use std::time::Instant;

#[derive(Copy, Clone)]
struct Point {
    x: i64,
    y: i64,
}

fn handle_points(iterations: i64, count: i64, modulo: i64) {
    let start = Instant::now();
    let mut sum_x: i64 = 0;
    let mut sum_y: i64 = 0;

    for _ in 0..iterations {
        let mut points: Vec<Point> = Vec::with_capacity(count as usize);
        for i in 0..count {
            points.push(Point { x: i, y: i * 2 });
        }

        for i in 0..count {
            if i % modulo == 0 {
                continue;
            }
            sum_x += points[i as usize].x;
            sum_y += points[i as usize].y;
        }
    }

    let elapsed_ms = start.elapsed().as_millis();
    println!(
        "Time taken to create and sum {} points: {} ms",
        count * iterations,
        elapsed_ms
    );
    println!("Sum of X: {}, Sum of Y: {}", sum_x, sum_y);
}

fn handle_points2(iterations: i64, count: i64, modulo: i64) {
    let start = Instant::now();
    let mut sum_x: i64 = 0;
    let mut sum_y: i64 = 0;

    for _ in 0..iterations {
        for i in 0..count {
            if i % modulo == 0 {
                continue;
            }
            let point = Point { x: i, y: i * 2 };
            sum_x += point.x;
            sum_y += point.y;
        }
    }

    let elapsed_ms = start.elapsed().as_millis();
    println!(
        "Time taken to create and sum without array {} points: {} ms",
        count * iterations,
        elapsed_ms
    );
    println!("Sum of X: {}, Sum of Y: {}", sum_x, sum_y);
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let iterations = args
        .get(1)
        .and_then(|s| s.parse::<i64>().ok())
        .unwrap_or(1000);
    let count = args
        .get(2)
        .and_then(|s| s.parse::<i64>().ok())
        .unwrap_or(100000);
    let modulo = args
        .get(3)
        .and_then(|s| s.parse::<i64>().ok())
        .unwrap_or(7);

    if iterations <= 0 || count <= 0 || modulo <= 0 {
        eprintln!("Usage: {} [iterations>0] [count>0] [modulo>0]", args[0]);
        std::process::exit(1);
    }

    println!("Welcome to performance_test!");
    handle_points(iterations, count, modulo);
    handle_points2(iterations, count, modulo);
}
