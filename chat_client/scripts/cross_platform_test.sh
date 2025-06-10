#!/bin/bash
set -euo pipefail

echo "================================================================"
echo "Cross-Platform Build and Test Script for Audio-Visual Chat Client"
echo "================================================================"

# Define supported platforms
PLATFORMS=("x86_64" "arm64")

# Create build directories
echo "Creating build directories..."
mkdir -p build-x86_64
mkdir -p build-arm64

# Build for x86_64
echo "Building for x86_64..."
cmake -B build-x86_64 \
      -DCMAKE_TOOLCHAIN_FILE=toolchains/x86_64-linux.cmake \
      -DCMAKE_BUILD_TYPE=Release
cmake --build build-x86_64 --parallel $(nproc)

# Run x86_64 tests if on x86_64 platform
if [[ $(uname -m) == "x86_64" ]]; then
    echo "Running x86_64 tests..."
    cd build-x86_64 && ctest --output-on-failure
    cd ..
    echo "x86_64 tests completed successfully"
else
    echo "Skipping x86_64 tests (not running on x86_64 platform)"
fi

# Build for ARM64
echo "Building for ARM64..."
if ! command -v aarch64-linux-gnu-gcc &> /dev/null; then
    echo "ARM64 cross-compiler not found, trying to install..."
    sudo apt-get update && sudo apt-get install -y gcc-aarch64-linux-gnu g++-aarch64-linux-gnu
fi

cmake -B build-arm64 \
      -DCMAKE_TOOLCHAIN_FILE=toolchains/arm64-linux.cmake \
      -DCMAKE_BUILD_TYPE=Release
cmake --build build-arm64 --parallel $(nproc)

# Run ARM64 tests if on ARM64 platform
if [[ $(uname -m) == "aarch64" ]]; then
    echo "Running ARM64 tests..."
    cd build-arm64 && ctest --output-on-failure
    cd ..
    echo "ARM64 tests completed successfully"
else
    echo "Skipping ARM64 tests (not running on ARM64 platform)"
fi

# Docker multi-platform build
echo "Building Docker multi-platform images..."
if command -v docker buildx &> /dev/null; then
    # Create builder instance if it doesn't exist
    if ! docker buildx inspect mybuilder &> /dev/null; then
        docker buildx create --name mybuilder --use
    else
        docker buildx use mybuilder
    fi
    
    # Build and push images
    docker buildx build \
        --platform linux/amd64,linux/arm64 \
        --tag chat-client:latest \
        --load .
        
    echo "Docker multi-platform images built successfully"
else
    echo "Docker buildx not available, skipping multi-platform Docker build"
fi

echo "Cross-platform build and tests completed"
echo "You can now run the application with:"
echo "  - x86_64: ./build-x86_64/chat_client"
echo "  - ARM64: ./build-arm64/chat_client (on ARM64 hardware)"
echo "  - Docker: docker run --rm -it chat-client:latest"
