# Audio-Visual Chat Client - AppImage Packaging

This document explains how to build and distribute the chat client as an AppImage package, which enables users to run the application on virtually any modern Linux distribution without installing dependencies.

## What is AppImage?

AppImage is a format for distributing portable software on Linux without requiring system-wide installation. Benefits include:
- No need for root permissions
- No dependency installation required by users
- Works on most Linux distributions
- Runs in a self-contained environment

## Building the AppImage

### Prerequisites

To build the AppImage, you need:

1. Basic build tools (g++, make, cmake)
2. linuxdeploy tool (automatically downloaded by the build script)
3. ImageMagick (for icon generation)

### Building Steps

#### 1. Using the Makefile target:
```bash
# From the project root
make appimage
```

#### 2. Using the build script directly:
```bash
# From the project root
./scripts/build_appimage.sh
```

#### 3. Building with CMake options:
```bash
mkdir -p build-appimage
cd build-appimage
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_APPIMAGE=ON ..
make
cd ..
./scripts/build_appimage.sh
```

## Application Structure in AppImage

The AppImage packages the application with the following structure:

```
ChatClient.AppDir/
├── AppRun                # Startup script
├── usr/
│   ├── bin/              # Binary executable
│   │   └── chat_client
│   ├── lib/              # Libraries
│   │   └── ...
│   └── share/
│       ├── applications/ # Desktop entry
│       ├── icons/        # Application icon
│       └── metainfo/     # AppStream metadata
└── data/                 # Application data files
```

## Distributing the AppImage

After building, you'll find a file named `ChatClient-1.0.0-x86_64.AppImage` (or similar with ARM64). This file is:

1. Completely self-contained
2. Executable (just make it executable with `chmod +x`)
3. Portable (can be run from anywhere, including USB drives)

Users can run the application by simply:
```bash
# Make executable (first time only)
chmod +x ChatClient-*.AppImage

# Run the application
./ChatClient-*.AppImage
```

## Integration with Desktop Environment

When the AppImage is executed for the first time, it can optionally be integrated with the desktop environment. The user will be asked if they want to:

- Create a desktop entry
- Add an entry to the applications menu
- Register the application with MIME types
- Extract the AppImage (not recommended for regular users)

## Multi-Platform Support

The AppImage can be built for both x86_64 and ARM64 architectures:

```bash
# For x86_64
./scripts/build_appimage.sh

# For ARM64 (cross-compilation)
ARCH=arm64 ./scripts/build_appimage.sh
```

## Troubleshooting

If the AppImage fails to run, check the following:

1. **Executable permission**: Make sure the AppImage is executable (`chmod +x *.AppImage`)
2. **FUSE**: AppImage requires FUSE to run. On some systems, you may need to install it:
   ```bash
   sudo apt-get install fuse   # Debian/Ubuntu
   sudo dnf install fuse       # Fedora
   sudo pacman -S fuse2        # Arch Linux
   ```
3. **Extraction**: If FUSE is not available, extract the AppImage with:
   ```bash
   ./ChatClient-*.AppImage --appimage-extract
   cd squashfs-root
   ./AppRun
   ```
