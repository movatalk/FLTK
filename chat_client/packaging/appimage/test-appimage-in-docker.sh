#!/bin/bash
#
# Test Chat Client AppImage in Docker with audio support
# Author: Tom Sapletta
# License: Apache-2.0
# Copyright 2025 Tom Sapletta

# Stop on errors
set -e

echo "=== Testing Chat Client AppImage in Docker with Audio Support ==="

# Find the AppImage
WORKSPACE=$(pwd)
APPIMAGE_PATH="${WORKSPACE}/ChatClient-1.0.0-x86_64.AppImage"

if [ ! -f "$APPIMAGE_PATH" ]; then
    echo "Error: AppImage file not found at $APPIMAGE_PATH"
    echo "Please build the AppImage first with: ./scripts/build_appimage.sh"
    exit 1
fi

# Create a temporary directory for extracted content
EXTRACT_DIR=$(mktemp -d)
echo "Extracting AppImage to temporary directory: $EXTRACT_DIR"

# Try using the --appimage-extract option first
"$APPIMAGE_PATH" --appimage-extract --dest "$EXTRACT_DIR" >/dev/null 2>&1 || {
    echo "FUSE extraction failed, using fallback manual extraction..."
    
    # If AppDir exists, use it directly
    if [ -d "${WORKSPACE}/ChatClient.AppDir" ]; then
        echo "Using existing AppDir"
        mkdir -p "$EXTRACT_DIR/squashfs-root"
        cp -r "${WORKSPACE}/ChatClient.AppDir/"* "$EXTRACT_DIR/squashfs-root/"
    else
        echo "Error: Cannot extract AppImage and no AppDir found"
        rm -rf "$EXTRACT_DIR"
        exit 1
    fi
}

# Make sure the AppRun script is executable
chmod +x "$EXTRACT_DIR/squashfs-root/AppRun" 2>/dev/null || true
chmod +x "$EXTRACT_DIR/squashfs-root/usr/bin/chat_client" 2>/dev/null || true

echo "Setting up Docker container with audio support..."

# Run Docker with X11 and PulseAudio support
docker run --rm \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    -v $HOME/.Xauthority:/root/.Xauthority:ro \
    -v /run/user/1000/pulse:/run/user/1000/pulse:ro \
    -v "$EXTRACT_DIR/squashfs-root":/app \
    --device /dev/snd:/dev/snd \
    -e DISPLAY=$DISPLAY \
    -e PULSE_SERVER=unix:/run/user/1000/pulse/native \
    -e FLTK_BACKEND=hybrid \
    ubuntu:22.04 bash -c "
        apt-get update -qq
        apt-get install -y alsa-utils pulseaudio-utils libgl1 xterm --no-install-recommends
        
        echo '=== Testing Audio Hardware ==='
        echo 'Available audio devices:'
        aplay -l
        
        echo 'PulseAudio status:'
        pactl info || echo 'PulseAudio connection failed'
        
        echo '=== Testing AppDir Execution ==='
        cd /app
        chmod +x AppRun usr/bin/chat_client || true
        ./AppRun
    "

# Clean up
echo "Cleaning up..."
rm -rf "$EXTRACT_DIR"

echo "=== Test Complete ==="
echo "The AppImage was successfully tested in Docker with audio support."
