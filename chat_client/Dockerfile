FROM ubuntu:22.04 as builder

ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETPLATFORM

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    libfltk1.3-dev \
    libportaudio2 \
    libportaudiocpp0 \
    portaudio19-dev \
    libx11-dev \
    libxft-dev \
    libxext-dev \
    && rm -rf /var/lib/apt/lists/*

# Setup cross-compilation for ARM64 if needed
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
    apt-get update && apt-get install -y \
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    && rm -rf /var/lib/apt/lists/*; \
    fi

# Create working directory
WORKDIR /app

# Copy source code
COPY . .

# Build using CMake
RUN mkdir -p build && cd build \
    && if [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
       cmake -DCMAKE_TOOLCHAIN_FILE=toolchains/arm64-linux.cmake ..; \
    else \
       cmake ..; \
    fi \
    && cmake --build . --parallel $(nproc)

# Runtime stage
FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies only
RUN apt-get update && apt-get install -y \
    libfltk1.3 \
    libportaudio2 \
    libx11-6 \
    libxft2 \
    libxext6 \
    && rm -rf /var/lib/apt/lists/*

# Create app directories
WORKDIR /app

# Copy binary and data from builder
COPY --from=builder /app/build/chat_client /app/
COPY --from=builder /app/data /app/data/

# Set environment for X11 forwarding
ENV DISPLAY=:0

# Set entrypoint
ENTRYPOINT ["/app/chat_client"]
