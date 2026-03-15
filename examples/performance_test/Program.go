package main

import (
	"fmt"
	"os"
	"strconv"
	"time"
)

type Point struct {
	x int64
	y int64
}

func handlePoints(iterations int64, count int64, modulo int64) {
	start := time.Now()
	var sumX int64 = 0
	var sumY int64 = 0

	for j := int64(0); j < iterations; j++ {
		points := make([]Point, count)
		for i := int64(0); i < count; i++ {
			points[i] = Point{x: i, y: i * 2}
		}

		for i := int64(0); i < count; i++ {
			if i%modulo == 0 {
				continue
			}
			sumX += points[i].x
			sumY += points[i].y
		}
	}

	elapsed := time.Since(start).Milliseconds()
	fmt.Printf("Time taken to create and sum %d points: %d ms\n", count*iterations, elapsed)
	fmt.Printf("Sum of X: %d, Sum of Y: %d\n", sumX, sumY)
}

func handlePoints2(iterations int64, count int64, modulo int64) {
	start := time.Now()
	var sumX int64 = 0
	var sumY int64 = 0

	for j := int64(0); j < iterations; j++ {
		for i := int64(0); i < count; i++ {
			if i%modulo == 0 {
				continue
			}
			point := Point{x: i, y: i * 2}
			sumX += point.x
			sumY += point.y
		}
	}

	elapsed := time.Since(start).Milliseconds()
	fmt.Printf("Time taken to create and sum without array %d points: %d ms\n", count*iterations, elapsed)
	fmt.Printf("Sum of X: %d, Sum of Y: %d\n", sumX, sumY)
}

func main() {
	iterations := int64(1000)
	count := int64(100000)
	modulo := int64(7)

	if len(os.Args) >= 2 {
		if parsed, err := strconv.ParseInt(os.Args[1], 10, 64); err == nil {
			iterations = parsed
		}
	}
	if len(os.Args) >= 3 {
		if parsed, err := strconv.ParseInt(os.Args[2], 10, 64); err == nil {
			count = parsed
		}
	}
	if len(os.Args) >= 4 {
		if parsed, err := strconv.ParseInt(os.Args[3], 10, 64); err == nil {
			modulo = parsed
		}
	}

	if iterations <= 0 || count <= 0 || modulo <= 0 {
		fmt.Fprintln(os.Stderr, "Usage: Program [iterations>0] [count>0] [modulo>0]")
		os.Exit(1)
	}

	fmt.Println("Welcome to performance_test!")
	handlePoints(iterations, count, modulo)
	handlePoints2(iterations, count, modulo)
}
