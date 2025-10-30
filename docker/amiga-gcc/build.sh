#!/bin/bash

# Build the complete Amiga GCC toolchain with AmiSSL support
echo "Building Amiga GCC toolchain with AmiSSL support..."

cd ../..
docker build -f docker/amiga-gcc/Dockerfile -t amiga-gcc --progress=plain .

echo ""
echo "Build complete! Use the image with:"
echo "  docker run -it amiga-gcc"
echo ""
echo "Or mount your project directory:"
echo "  docker run -it -v \$(pwd):/workspace amiga-gcc"
