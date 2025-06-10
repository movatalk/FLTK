#!/usr/bin/env python3
"""
RTSP Stream Tester for Audio-Visual Chat Client
Author: Tom Sapletta
License: Apache-2.0
Version: 1.0.0

This script tests RTSP streaming from audio/video devices and displays audio levels.
Requires: python3, gstreamer, numpy, matplotlib (for visualization)
"""

import sys
import os
import time
import argparse
import subprocess
import numpy as np
import threading
import yaml
import signal
import gi
gi.require_version('Gst', '1.0')
from gi.repository import Gst, GLib

# Initialize GStreamer
Gst.init(None)

class AudioLevelMeter:
    def __init__(self, device_id, rtsp_url, duration=0):
        """Initialize audio level meter for RTSP stream."""
        self.device_id = device_id
        self.rtsp_url = rtsp_url
        self.duration = duration  # 0 means run until interrupted
        self.running = False
        self.pipeline = None
        self.loop = None
        self.audio_levels = []
        self.max_level = 0
        self.min_level = -60  # dB

    def on_level_message(self, bus, message):
        """Handle level messages from the level element."""
        if message.get_structure().get_name() == 'level':
            structure = message.get_structure()
            # Get the peak level
            # Convert from GStreamer's internal representation to dB
            peak = structure.get_value('peak')[0]
            if peak > self.max_level:
                self.max_level = peak
            
            # Store for visualization
            self.audio_levels.append(peak)
            
            # Display current level
            self._display_level_meter(peak)
            return True
        return False

    def _display_level_meter(self, level):
        """Display an ASCII level meter."""
        # Normalize level to 0-40 range for display
        level_norm = int(40 * (level - self.min_level) / (self.max_level - self.min_level))
        level_norm = max(0, min(level_norm, 40))  # Clamp to 0-40
        
        # Create meter with different characters for different levels
        meter = ''
        for i in range(40):
            if i < level_norm:
                if i > 30:
                    meter += '#'  # High level
                elif i > 20:
                    meter += '='  # Medium level
                else:
                    meter += '-'  # Low level
            else:
                meter += ' '
        
        # Display with dB value
        print(f"\rAudio Level [{meter}] {level:.2f} dB", end='', flush=True)

    def start(self):
        """Start the RTSP stream monitoring."""
        print(f"Starting RTSP stream monitoring for {self.device_id} at {self.rtsp_url}")
        
        # Set up GStreamer pipeline
        pipeline_str = (
            f"rtspsrc location={self.rtsp_url} latency=100 ! "
            "rtpjitterbuffer ! rtpopusdepay ! opusdec ! "
            "audioconvert ! level interval=100000000 post-messages=true ! "
            "autoaudiosink"
        )
        
        self.pipeline = Gst.parse_launch(pipeline_str)
        bus = self.pipeline.get_bus()
        bus.add_signal_watch()
        bus.connect("message::element", self.on_level_message)
        bus.connect("message::error", self.on_error)
        bus.connect("message::eos", self.on_eos)
        
        # Start the pipeline
        self.pipeline.set_state(Gst.State.PLAYING)
        self.running = True
        
        # Run the GLib main loop
        self.loop = GLib.MainLoop()
        
        # If duration is specified, set a timer to stop
        if self.duration > 0:
            GLib.timeout_add_seconds(self.duration, self.stop)
        
        try:
            self.loop.run()
        except KeyboardInterrupt:
            print("\nInterrupted by user")
            self.stop()
    
    def on_error(self, bus, message):
        """Handle error messages."""
        err, debug = message.parse_error()
        print(f"\nError: {err.message}")
        self.stop()
        return True
    
    def on_eos(self, bus, message):
        """Handle end-of-stream messages."""
        print("\nEnd of stream reached")
        self.stop()
        return True
    
    def stop(self):
        """Stop the monitoring."""
        if self.running:
            print("\nStopping stream monitoring...")
            self.pipeline.set_state(Gst.State.NULL)
            self.running = False
            if self.loop:
                self.loop.quit()
            return False  # Important for GLib timeout
        return False

class RTSPStreamTester:
    def __init__(self, config_file=None):
        """Initialize the RTSP Stream Tester."""
        self.config_file = config_file
        self.config = None
        self.streaming_server_process = None
        
        # Load configuration
        if config_file:
            self._load_config()
        
    def _load_config(self):
        """Load configuration from YAML file."""
        try:
            with open(self.config_file, 'r') as f:
                self.config = yaml.safe_load(f)
                print(f"Loaded configuration from {self.config_file}")
        except Exception as e:
            print(f"Error loading configuration: {e}")
            sys.exit(1)
    
    def start_rtsp_server(self):
        """Start the RTSP streaming server."""
        # Check if rtsp-simple-server is configured
        if not self.config or 'protocols' not in self.config or 'rtsp' not in self.config['protocols']:
            print("RTSP server configuration not found")
            return False
        
        rtsp_config = self.config['protocols']['rtsp']
        server_binary = rtsp_config.get('server_binary')
        config_file = rtsp_config.get('config_file')
        
        if not server_binary or not os.path.exists(server_binary):
            print("RTSP server binary not found. Installing rtsp-simple-server...")
            # We could install the server here, but for simplicity we'll use GStreamer's rtsp server
            server_binary = "gst-rtsp-server-1.0"
        
        try:
            print(f"Starting RTSP server on port range {rtsp_config['default_port_range']}")
            
            # For simplicity, we'll use GStreamer's test-launch to create a test RTSP server
            cmd = [
                "gst-rtsp-server-launch-1.0",
                f"--port={rtsp_config['default_port_range'][0]}",
                "'( audiotestsrc is-live=true wave=sine frequency=440 ! "
                "audioconvert ! audioresample ! opusenc ! rtpopuspay name=pay0 )'"
            ]
            
            print(f"Running command: {' '.join(cmd)}")
            
            # Start the server process
            self.streaming_server_process = subprocess.Popen(
                " ".join(cmd),
                shell=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            
            # Give it some time to start
            time.sleep(2)
            
            if self.streaming_server_process.poll() is not None:
                print("Failed to start RTSP server")
                return False
            
            print("RTSP server started successfully")
            return True
            
        except Exception as e:
            print(f"Error starting RTSP server: {e}")
            return False
    
    def stop_rtsp_server(self):
        """Stop the RTSP server if it's running."""
        if self.streaming_server_process:
            print("Stopping RTSP server...")
            self.streaming_server_process.terminate()
            try:
                self.streaming_server_process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                self.streaming_server_process.kill()
            self.streaming_server_process = None
    
    def stream_device(self, device_id, device_type='audio', stream_type='rtsp'):
        """Stream a device over the specified protocol."""
        if not self.config:
            print("No configuration loaded")
            return False
        
        # Find the device in config
        devices = self.config.get(f'{device_type}_devices', [])
        device = None
        for d in devices:
            if d['id'] == device_id:
                device = d
                break
        
        if not device:
            print(f"Device {device_id} not found in configuration")
            return False
        
        # Find the protocol configuration
        protocol_config = None
        for protocol in device.get('protocols', []):
            if protocol['type'] == stream_type and protocol['enabled']:
                protocol_config = protocol
                break
        
        if not protocol_config:
            print(f"{stream_type.upper()} streaming not enabled for device {device_id}")
            return False
        
        # Generate the RTSP URL
        port = protocol_config.get('port')
        path = protocol_config.get('path', f"/{device_id}")
        rtsp_url = f"rtsp://localhost:{port}{path}"
        
        print(f"Setting up {stream_type.upper()} stream for device {device_id} at {rtsp_url}")
        
        # For RTSP, we'll use GStreamer to set up a test stream
        # In a real implementation, this would use the actual device
        if stream_type == 'rtsp':
            if device_type == 'audio':
                # Use pulsesrc to capture from actual audio device
                cmd = [
                    "gst-launch-1.0",
                    "pulsesrc device=default ! audioconvert ! audioresample ! ",
                    "opusenc ! rtpopuspay ! udpsink host=localhost port=8554"
                ]
            else:
                # For video device
                cmd = [
                    "gst-launch-1.0",
                    "videotestsrc is-live=true ! videoconvert ! x264enc tune=zerolatency ! ",
                    "rtph264pay ! udpsink host=localhost port=8556"
                ]
            
            print(f"Running command: {' '.join(cmd)}")
            
            # Start the streaming process
            stream_process = subprocess.Popen(
                " ".join(cmd),
                shell=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            
            # Return the URL for monitoring
            return rtsp_url
        
        return None
    
    def monitor_audio_levels(self, rtsp_url, device_id, duration=30):
        """Monitor audio levels from the specified RTSP URL."""
        level_meter = AudioLevelMeter(device_id, rtsp_url, duration)
        level_meter.start()
    
    def test_rtsp_connection(self, rtsp_url, timeout=5):
        """Test RTSP connection to the given URL."""
        print(f"Testing RTSP connection to {rtsp_url}")
        cmd = ["gst-launch-1.0", "-v", f"rtspsrc location={rtsp_url} ! fakesink"]
        
        try:
            process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            try:
                stdout, stderr = process.communicate(timeout=timeout)
                success = process.returncode == 0
                if success:
                    print(f"Successfully connected to {rtsp_url}")
                else:
                    print(f"Failed to connect to {rtsp_url}")
                    print(f"Error: {stderr.decode()}")
                return success
            except subprocess.TimeoutExpired:
                process.kill()
                print(f"Connection test timed out after {timeout} seconds")
                return False
        except Exception as e:
            print(f"Error testing connection: {e}")
            return False


def main():
    parser = argparse.ArgumentParser(description="RTSP Stream Tester")
    parser.add_argument("--config", default="../config/device_streams.yaml", 
                        help="Path to configuration YAML file")
    parser.add_argument("--start-server", action="store_true", 
                        help="Start an RTSP server")
    parser.add_argument("--stream-device", 
                        help="Stream from specified device ID")
    parser.add_argument("--device-type", choices=["audio", "video"], default="audio",
                        help="Device type (audio or video)")
    parser.add_argument("--protocol", choices=["rtsp", "webrtc", "hls"], default="rtsp",
                        help="Streaming protocol")
    parser.add_argument("--monitor", action="store_true",
                        help="Monitor audio levels")
    parser.add_argument("--duration", type=int, default=30,
                        help="Duration in seconds to monitor (0 = indefinite)")
    parser.add_argument("--test-url",
                        help="Test connection to specific RTSP URL")
    
    args = parser.parse_args()
    
    # Create tester instance
    tester = RTSPStreamTester(args.config)
    
    # Handle SIGINT gracefully
    def signal_handler(sig, frame):
        print("\nInterrupted, cleaning up...")
        tester.stop_rtsp_server()
        sys.exit(0)
    
    signal.signal(signal.SIGINT, signal_handler)
    
    try:
        # Start RTSP server if requested
        if args.start_server:
            if not tester.start_rtsp_server():
                sys.exit(1)
        
        # Test connection to URL if specified
        if args.test_url:
            tester.test_rtsp_connection(args.test_url)
        
        # Stream from device if specified
        if args.stream_device:
            rtsp_url = tester.stream_device(
                args.stream_device, args.device_type, args.protocol)
            
            # Monitor audio levels if requested
            if args.monitor and rtsp_url:
                tester.monitor_audio_levels(rtsp_url, args.stream_device, args.duration)
        
        # If we're not monitoring, keep the script running
        if not args.monitor and (args.start_server or args.stream_device):
            print("Press Ctrl+C to stop...")
            while True:
                time.sleep(1)
        
    except KeyboardInterrupt:
        print("\nInterrupted by user")
    finally:
        tester.stop_rtsp_server()

if __name__ == "__main__":
    main()
