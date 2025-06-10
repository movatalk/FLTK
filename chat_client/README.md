# Audio-Visual Chat Client

## Overview
This is a cross-platform audio-visual chat client built with C++ and FLTK. The application provides audio capture and playback capabilities along with a text-based chat interface, designed to work seamlessly on both ARM64 and x86_64 Linux platforms.

## Features
- Real-time audio input/output with level monitoring
- Text-based chat interface with multi-protocol support
- Audio controls (volume, gain, mute options)
- Cross-platform compatibility using FLTK and PortAudio
- ARM64 NEON and x86_64 SSE2/AVX optimizations
- Docker containerization with multi-architecture support
- Comprehensive testing across different hardware platforms

## Requirements
- C++17 compatible compiler
- CMake 3.16 or later
- FLTK 1.3 or later
- PortAudio v19
- For cross-compilation: ARM64 toolchain (optional)
- For Docker: Docker with buildx support (optional)

## Building the Application

### Dependencies on Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install build-essential cmake libfltk1.3-dev libportaudio2 libportaudiocpp0 portaudio19-dev
```

### Building with CMake
```bash
# From the project root directory
mkdir -p build
cd build
cmake ..
make -j$(nproc)
```

### Building with Traditional Makefile
```bash
# From the project root directory
make -j$(nproc)
```

### Building with Build Script
```bash
# From the project root directory
./scripts/build.sh [Release|Debug]
```

### Cross-Platform Building
To build for multiple architectures and run hardware-specific tests:
```bash
./scripts/cross_platform_test.sh
```

This script will:
1. Build for x86_64 architecture
2. Build for ARM64 architecture (using cross-compilation if on x86_64)
3. Run appropriate tests for the current hardware
4. Build multi-architecture Docker images if Docker is available

## Docker Support

### Building Docker Image
```bash
docker build -t chat-client:latest .
```

### Building Multi-Architecture Docker Images
```bash
docker buildx create --name mybuilder --use
docker buildx build --platform linux/amd64,linux/arm64 --tag chat-client:latest .
```

### Running with Docker Compose
```bash
docker-compose up -d
```

This will start the chat client with proper access to X11 display and audio devices.

## Running the Application
```bash
# Standard build
./build/chat_client

# Traditional Makefile build
./bin/chat_client

# Architecture-specific builds
./build-x86_64/chat_client
./build-arm64/chat_client  # When on ARM64 hardware

# Docker
docker run --rm -it \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /run/user/1000/pulse:/run/user/1000/pulse \
  --device /dev/snd \
  chat-client:latest
```

## Configuration
The application can be configured by editing the JSON file in `data/config/default.json`. The configuration includes settings for:
- Audio devices and parameters
- Chat protocol settings
- GUI preferences
- Debug options

## Project Structure
- `src/` - Source code
  - `core/` - Core application components
  - `audio/` - Audio processing functionality
  - `gui/` - FLTK-based user interface
  - `network/` - Chat protocol implementations
  - `utils/` - Utility functions and helpers
- `include/` - Header files
- `data/` - Configuration and resources
- `tests/` - Unit, integration, and hardware-specific tests
  - `unit/` - Basic component tests
  - `integration/` - Full system tests
  - `hardware/` - Architecture-specific tests (ARM64/x86_64)
- `scripts/` - Build and utility scripts
- `toolchains/` - CMake toolchain files for cross-compilation

## Testing
```bash
# Build and run all tests
cd build && ctest

# Run specific test suite
cd build && ctest -R AudioTest

# Run hardware-specific tests
cd build && ctest -R ARM64Test  # On ARM64 hardware
cd build && ctest -R X86_64Test # On x86_64 hardware
```

## Hardware-Specific Optimizations

### ARM64 (AArch64)
- NEON SIMD instructions for audio processing
- Tuned for Cortex-A72 and newer ARM processors
- Optimized memory access patterns for ARM architecture

### x86_64
- SSE2 and AVX instructions for audio processing
- Generic tuning compatible with most x86_64 processors
- Optimized for modern desktop/server CPUs

## Deployment

### Standard Installation
```bash
sudo make install
```

### Systemd Service Installation
```bash
# Copy service file
sudo cp scripts/chat-client.service /etc/systemd/user/
systemctl --user daemon-reload
systemctl --user enable chat-client.service
systemctl --user start chat-client
```

### Docker Deployment
```bash
# Using docker-compose
docker-compose up -d
```

## License
This project is released under the MIT License.
