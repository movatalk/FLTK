# Streaming Implementation Guide for FLTK Chat Client

## Overview

This guide provides a step-by-step implementation plan for enhancing the FLTK chat client with multi-protocol audio/video device streaming capabilities. Each audio and video device can be assigned to specific protocols (RTSP, WebRTC, HLS, podcast) with dedicated ports and parameters.

## Table of Contents

1. [Implementation Plan](#implementation-plan)
2. [Required Dependencies](#required-dependencies)
3. [Testing Instructions](#testing-instructions)
4. [Current Chat Client Testing](#current-chat-client-testing)
5. [Common Issues and Solutions](#common-issues-and-solutions)

## Implementation Plan

### Phase 1: RTSP Streaming Implementation (Recommended First Step)

RTSP (Real Time Streaming Protocol) is the recommended starting point due to its relative simplicity and widespread support.

1. **Install Required Dependencies**
   ```bash
   sudo apt-get update
   sudo apt-get install -y gstreamer1.0-tools gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
     gstreamer1.0-plugins-ugly gstreamer1.0-rtsp libgstrtspserver-1.0-dev \
     python3-gst-1.0 python3-pip pulseaudio v4l-utils
   pip3 install pyyaml numpy matplotlib
   ```

2. **Set Up RTSP Server**
   - We recommend using `rtsp-simple-server` for its simplicity
   ```bash
   # Download and install rtsp-simple-server
   wget https://github.com/aler9/rtsp-simple-server/releases/download/v0.21.6/rtsp-simple-server_v0.21.6_linux_amd64.tar.gz
   tar -xzf rtsp-simple-server_v0.21.6_linux_amd64.tar.gz
   sudo mv rtsp-simple-server /usr/local/bin/
   ```

3. **Integrate RTSP Client/Server into Chat Client**
   - Add GStreamer-based media pipeline to capture and stream microphone audio
   - Implement RTSP server to handle streaming requests
   - Add configuration loader to read device_streams.yaml

4. **Create Basic UI Controls**
   - Add device selection dropdown
   - Add protocol selection for each device
   - Add stream start/stop buttons

### Phase 2: WebRTC Implementation

WebRTC offers the lowest latency and is ideal for real-time communication.

1. **Install Additional Dependencies**
   ```bash
   sudo apt-get install -y libwebrtc-audio-processing-dev
   ```

2. **Implement WebRTC Signaling Server**
   - Use a lightweight WebSocket server (recommended libraries: libwebsockets or Boost.Beast)
   - Create ICE candidate exchange mechanism
   - Set up STUN server connectivity

3. **Implement WebRTC Media Handling**
   - Create peer connection setup
   - Implement audio/video track handling
   - Add NAT traversal and connection management

### Phase 3: HLS Streaming Implementation

HLS works well for one-way broadcasting and has better compatibility with browsers and mobile devices.

1. **Install HLS Dependencies**
   ```bash
   sudo apt-get install -y ffmpeg nginx
   ```

2. **Set Up HLS Segmenter**
   - Configure FFmpeg to create HLS segments
   - Set up a basic HTTP server for delivering segments
   - Create M3U8 playlist generators

3. **Implement Segment Management**
   - Add segment cleanup mechanism
   - Implement adaptive bitrate options
   - Create playlist update mechanism

### Phase 4: Podcast Streaming

Podcast streaming is ideal for audio-only recorded content.

1. **Implement Recording Mechanism**
   - Add audio recording functionality
   - Create podcast XML feed generator
   - Implement episode management

## Required Dependencies

### Core Libraries
- **GStreamer**: Media handling framework
  - `gstreamer1.0-*` packages provide pipeline elements for audio/video capture and processing
- **RTSP Server**: `gst-rtsp-server` or `rtsp-simple-server`
- **WebRTC**: `libwebrtc-audio-processing-dev`
- **HLS**: `ffmpeg` for segmenting and `nginx` for serving
- **Configuration**: `libyaml-cpp-dev` or Python's `pyyaml`

### Recommended C++ Libraries
1. **GStreamer C++ Bindings**: `gstreamermm-1.0`
2. **WebRTC C++ API**: Use Google's WebRTC native code
3. **YAML Parser**: `yaml-cpp`
4. **Network Communication**: `libcurl`, `Boost.Asio`, or `libwebsockets`

## Testing Instructions

### Testing RTSP Streaming

The provided `rtsp_stream_tester.py` script can test RTSP streaming:

```bash
# Make script executable
chmod +x scripts/rtsp_stream_tester.py

# Start RTSP server
./scripts/rtsp_stream_tester.py --config config/device_streams.yaml --start-server

# In another terminal, test streaming from default microphone
./scripts/rtsp_stream_tester.py --config config/device_streams.yaml --stream-device default_mic --device-type audio --monitor

# Test connection to specific RTSP URL
./scripts/rtsp_stream_tester.py --test-url rtsp://localhost:8554/mic/default
```

### Testing Audio Levels

The RTSP tester includes an audio level monitor that displays real-time meter:

```bash
# Monitor audio levels from RTSP stream for 60 seconds
./scripts/rtsp_stream_tester.py --config config/device_streams.yaml --stream-device default_mic --monitor --duration 60
```

## Current Chat Client Testing

To test the current chat client for audio functionality:

1. **RTSP Testing (Recommended for Current Client)**:
   ```bash
   # Start RTSP server
   ./scripts/rtsp_stream_tester.py --start-server
   
   # Run chat client with microphone output directed to RTSP
   ./ChatClient-1.0.0-x86_64.AppImage --audio-output rtsp://localhost:8554/mic/default
   
   # In another terminal, monitor the audio stream
   ./scripts/rtsp_stream_tester.py --test-url rtsp://localhost:8554/mic/default --monitor
   ```

2. **Direct PulseAudio Testing**:
   ```bash
   # Check microphone devices
   pactl list sources
   
   # Listen to microphone
   pacat --record -d alsa_input.pci-0000_00_1f.3.analog-stereo | pacat --playback
   ```

## Common Issues and Solutions

1. **Missing GStreamer Plugins**
   - Error: "Missing element" or "No such element" errors
   - Solution: Install additional GStreamer plugins packages

2. **RTSP Connection Failures**
   - Error: Cannot connect to RTSP URL
   - Solution: Check that ports are not blocked by firewall 
     ```bash
     sudo ufw allow 8554:8654/tcp
     ```

3. **Audio Device Access Issues**
   - Error: Cannot open audio device
   - Solution: Ensure user has audio group permissions
     ```bash
     sudo usermod -a -G audio $USER
     ```

4. **WebRTC NAT Traversal**
   - Error: Cannot establish WebRTC connection
   - Solution: Configure proper STUN/TURN servers in device_streams.yaml

5. **HLS Latency Issues**
   - Issue: High latency in HLS streaming
   - Solution: Reduce segment duration (2-4 seconds) and playlist size
