#!/bin/bash
#
# Test Chat Client AppImage in Docker with audio support
# Author: Tom Saplett
# License: Apache-2.0
# Copyright 2025 Tom Saplett

# Stop on errors
set -e

echo "Creating Docker container to test AppImage with audio support..."

# Find the AppImage and AppDir
APPIMAGE_PATH="/home/tom/github/movatalk/FLTK/chat_client/ChatClient-1.0.0-x86_64.AppImage"
APPDIR_PATH="/home/tom/github/movatalk/FLTK/chat_client/ChatClient.AppDir"

if [ ! -f "$APPIMAGE_PATH" ]; then
    echo "Error: AppImage file not found at $APPIMAGE_PATH"
    echo "Please make sure you have built the AppImage first."
    exit 1
fi

if [ ! -d "$APPDIR_PATH" ]; then
    echo "Error: AppDir directory not found at $APPDIR_PATH"
    echo "Please make sure you have built the AppImage first."
    exit 1
fi

# Create a temporary directory to copy the files
TEMP_DIR=$(mktemp -d)
cp "$APPIMAGE_PATH" $TEMP_DIR/
mkdir -p $TEMP_DIR/ChatClient.AppDir
cp -r $APPDIR_PATH/* $TEMP_DIR/ChatClient.AppDir/
chmod +x $TEMP_DIR/ChatClient-1.0.0-x86_64.AppImage
chmod +x $TEMP_DIR/ChatClient.AppDir/AppRun
chmod +x $TEMP_DIR/ChatClient.AppDir/usr/bin/chat_client

echo "Files copied to temporary directory: $TEMP_DIR"
echo "Testing audio functionality inside Docker container..."

# Run Docker without requiring a TTY
docker run --rm \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -v $HOME/.Xauthority:/root/.Xauthority:rw \
  -v /run/user/1000/pulse:/run/user/1000/pulse:rw \
  -v $TEMP_DIR:/app \
  --device /dev/snd:/dev/snd \
  --network host \
  -e DISPLAY=$DISPLAY \
  -e XDG_RUNTIME_DIR=/tmp \
  -e PULSE_SERVER=unix:/run/user/1000/pulse/native \
  -e FLTK_BACKEND=hybrid \
  ubuntu:22.04 bash -c "
    apt-get update && 
    apt-get install -y libfuse2 alsa-utils pulseaudio-utils libgl1 && 
    echo '=== Testing audio hardware ===' &&
    echo 'Available audio devices:' &&
    aplay -l &&
    echo 'PulseAudio status:' &&
    (pactl info || echo 'PulseAudio not connected') &&
    echo '=== Testing AppDir execution directly ===' &&
    /app/ChatClient.AppDir/AppRun &&
    echo '=== Starting AppImage ===' &&
    /app/ChatClient-1.0.0-x86_64.AppImage
  "

# Clean up
rm -rf $TEMP_DIR
echo "Test completed."
