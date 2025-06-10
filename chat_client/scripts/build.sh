#!/bin/bash
set -euo pipefail

BUILD_TYPE=${1:-Release}

echo "Building Audio-Visual Chat Client (${BUILD_TYPE})"

# Create build directory
mkdir -p build

# Configure with CMake
cmake -B build -DCMAKE_BUILD_TYPE=${BUILD_TYPE}

# Build
cmake --build build --parallel $(nproc)

echo "Build completed successfully"
echo "You can run the application with: ./build/chat_client"
