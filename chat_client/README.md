# Audio-Visual Chat Client

## Overview
This is a cross-platform audio-visual chat client built with C++ and FLTK. The application provides audio capture and playback capabilities along with a text-based chat interface.

## Features
- Real-time audio input/output with level monitoring
- Text-based chat interface
- Audio controls (volume, gain, mute options)
- Support for multiple chat protocols (placeholder implementation)
- Cross-platform compatibility using FLTK and PortAudio

## Requirements
- C++17 compatible compiler
- CMake 3.16 or later
- FLTK 1.3 or later
- PortAudio v19

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

Alternatively, you can use the provided build script:
```bash
./scripts/build.sh
```

## Running the Application
```bash
./build/chat_client
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
- `tests/` - Unit and integration tests
- `scripts/` - Build and utility scripts

## Testing
```bash
cd build
ctest
```

## License
This project is released under the MIT License.
