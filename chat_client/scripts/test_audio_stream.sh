#!/bin/bash
# Audio Stream Test Wrapper
# Author: Tom Sapletta
# License: Apache-2.0
# Version: 1.0.0

# Set default values
CONFIG_FILE="../config/device_streams.yaml"
PROTOCOL="rtsp"
DEVICE_ID="default_mic"
DEVICE_TYPE="audio"
ACTION="monitor"
DURATION=30
RTSP_PORT=8554

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --config)
      CONFIG_FILE="$2"
      shift 2
      ;;
    --protocol)
      PROTOCOL="$2"
      shift 2
      ;;
    --device)
      DEVICE_ID="$2"
      shift 2
      ;;
    --type)
      DEVICE_TYPE="$2"
      shift 2
      ;;
    --action)
      ACTION="$2"
      shift 2
      ;;
    --duration)
      DURATION="$2"
      shift 2
      ;;
    --port)
      RTSP_PORT="$2"
      shift 2
      ;;
    --help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  --config FILE     Path to config file (default: ../config/device_streams.yaml)"
      echo "  --protocol PROTO  Protocol to use: rtsp, webrtc, hls (default: rtsp)"
      echo "  --device ID       Device ID to stream (default: default_mic)"
      echo "  --type TYPE       Device type: audio or video (default: audio)"
      echo "  --action ACTION   Action: server, stream, monitor, test (default: monitor)"
      echo "  --duration SECS   Duration in seconds for monitoring (default: 30)"
      echo "  --port PORT       Port number for RTSP server (default: 8554)"
      echo "  --help            Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Make sure Python script is executable
chmod +x "$(dirname "$0")/rtsp_stream_tester.py"

# Function to check for required dependencies
check_dependencies() {
  echo "Checking for required dependencies..."
  
  # Check for GStreamer
  if ! command -v gst-launch-1.0 &> /dev/null; then
    echo "GStreamer not found. Installing required packages..."
    sudo apt-get update
    sudo apt-get install -y gstreamer1.0-tools gstreamer1.0-plugins-good \
      gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly python3-gst-1.0 \
      python3-pip
    pip3 install pyyaml numpy
  else
    echo "GStreamer found."
  fi
  
  # Check for rtsp-simple-server if action is server
  if [ "$ACTION" = "server" ] && ! command -v rtsp-simple-server &> /dev/null; then
    echo "rtsp-simple-server not found. Using GStreamer's RTSP server instead."
  fi
}

# Function to start the RTSP server
start_server() {
  echo "Starting $PROTOCOL server on port $RTSP_PORT..."
  
  case $PROTOCOL in
    rtsp)
      # Try to use rtsp-simple-server if available, otherwise fall back to GStreamer
      if command -v rtsp-simple-server &> /dev/null; then
        echo "Using rtsp-simple-server..."
        # Create a simple config file
        TMP_CONFIG=$(mktemp)
        cat > "$TMP_CONFIG" << EOF
paths:
  all:
    readUser: ""
    readPass: ""
EOF
        rtsp-simple-server "$TMP_CONFIG" &
        SERVER_PID=$!
        sleep 2
        rm "$TMP_CONFIG"
      else
        echo "Using GStreamer RTSP server..."
        # Check if gst-rtsp-server-launch exists
        if command -v gst-rtsp-server-launch-1.0 &> /dev/null; then
          gst-rtsp-server-launch-1.0 --port=$RTSP_PORT \
            "( audiotestsrc is-live=true wave=sine frequency=440 ! audioconvert ! audioresample ! opusenc ! rtpopuspay name=pay0 )" &
          SERVER_PID=$!
          sleep 2
        else
          echo "Error: No RTSP server available. Please install rtsp-simple-server or GStreamer RTSP server."
          exit 1
        fi
      fi
      ;;
    *)
      echo "Server for protocol $PROTOCOL not implemented yet."
      exit 1
      ;;
  esac
  
  echo "Server started with PID $SERVER_PID"
}

# Function to stream from a device
stream_device() {
  echo "Setting up $PROTOCOL stream for $DEVICE_TYPE device $DEVICE_ID..."
  
  case $PROTOCOL in
    rtsp)
      if [ "$DEVICE_TYPE" = "audio" ]; then
        echo "Streaming microphone audio to RTSP server..."
        # Get the default source device
        SOURCE=$(pactl info | grep "Default Source" | cut -d: -f2 | xargs)
        echo "Using audio source: $SOURCE"
        
        # Stream using GStreamer
        gst-launch-1.0 pulsesrc device="$SOURCE" ! audioconvert ! audioresample ! \
          opusenc ! rtpopuspay ! udpsink host=localhost port=$RTSP_PORT &
        STREAM_PID=$!
        echo "Streaming started with PID $STREAM_PID"
        
        # Build the RTSP URL
        RTSP_URL="rtsp://localhost:$RTSP_PORT/$DEVICE_ID"
        echo "Stream available at: $RTSP_URL"
        
        # Store the URL for monitoring
        echo "$RTSP_URL" > /tmp/last_rtsp_url
      elif [ "$DEVICE_TYPE" = "video" ]; then
        echo "Streaming camera to RTSP server..."
        # Try to get the default video device
        if [ -e /dev/video0 ]; then
          echo "Using video device: /dev/video0"
          
          # Stream using GStreamer
          gst-launch-1.0 v4l2src device=/dev/video0 ! videoconvert ! x264enc tune=zerolatency ! \
            rtph264pay ! udpsink host=localhost port=$RTSP_PORT &
          STREAM_PID=$!
          echo "Streaming started with PID $STREAM_PID"
          
          # Build the RTSP URL
          RTSP_URL="rtsp://localhost:$RTSP_PORT/$DEVICE_ID"
          echo "Stream available at: $RTSP_URL"
          
          # Store the URL for monitoring
          echo "$RTSP_URL" > /tmp/last_rtsp_url
        else
          echo "Error: No video device found at /dev/video0"
          exit 1
        fi
      fi
      ;;
    *)
      echo "Streaming for protocol $PROTOCOL not implemented yet."
      exit 1
      ;;
  esac
}

# Function to monitor audio levels
monitor_stream() {
  echo "Monitoring $PROTOCOL stream for $DEVICE_TYPE device $DEVICE_ID..."
  
  # If we have a saved URL, use it, otherwise construct a default
  if [ -f /tmp/last_rtsp_url ]; then
    RTSP_URL=$(cat /tmp/last_rtsp_url)
  else
    RTSP_URL="rtsp://localhost:$RTSP_PORT/$DEVICE_ID"
  fi
  
  echo "Monitoring stream: $RTSP_URL"
  
  # Use Python script for advanced monitoring
  "$(dirname "$0")/rtsp_stream_tester.py" --test-url "$RTSP_URL" --monitor --duration "$DURATION"
}

# Function to test a connection
test_connection() {
  echo "Testing $PROTOCOL connection..."
  
  # If we have a saved URL, use it, otherwise construct a default
  if [ -f /tmp/last_rtsp_url ]; then
    RTSP_URL=$(cat /tmp/last_rtsp_url)
  else
    RTSP_URL="rtsp://localhost:$RTSP_PORT/$DEVICE_ID"
  fi
  
  echo "Testing connection to: $RTSP_URL"
  
  # Use Python script for connection testing
  "$(dirname "$0")/rtsp_stream_tester.py" --test-url "$RTSP_URL"
}

# Check for required dependencies
check_dependencies

# Perform the requested action
case $ACTION in
  server)
    start_server
    echo "Press Ctrl+C to stop the server"
    wait $SERVER_PID
    ;;
  stream)
    stream_device
    echo "Press Ctrl+C to stop streaming"
    wait $STREAM_PID
    ;;
  monitor)
    monitor_stream
    ;;
  test)
    test_connection
    ;;
  *)
    echo "Unknown action: $ACTION"
    exit 1
    ;;
esac

echo "Done."
exit 0
