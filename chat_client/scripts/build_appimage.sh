#!/bin/bash
#
# Audio-Visual Chat Client - AppImage Builder
# Author: Tom Sapletta
# License: Apache-2.0
# Copyright 2025 Tom Sapletta
#

set -e

# Configuration
APP_NAME="ChatClient"
PKG_VERSION="1.0.0"
ARCH=$(uname -m)
APP_DIR="${APP_NAME}.AppDir"
LINUXDEPLOY="linuxdeploy-${ARCH}.AppImage"
WORKSPACE=$(pwd)

# Cleanup any previous builds
rm -rf ${APP_DIR}
rm -f ./${APP_NAME}-${PKG_VERSION}-${ARCH}.AppImage
rm -f ./Audio-Visual_Chat_Client-${PKG_VERSION}-${ARCH}.AppImage

# Create AppDir structure
mkdir -p ${APP_DIR}/usr/bin
mkdir -p ${APP_DIR}/usr/lib
mkdir -p ${APP_DIR}/usr/share/applications
mkdir -p ${APP_DIR}/usr/share/icons/hicolor/256x256/apps
mkdir -p ${APP_DIR}/usr/share/icons/hicolor/scalable/apps
mkdir -p ${APP_DIR}/usr/share/metainfo
mkdir -p ${APP_DIR}/data/config

# Check if we have a real binary or need to build it
if [ -f "${WORKSPACE}/build/chat_client" ]; then
    echo "Found binary in build directory, using it for AppImage packaging..."
    cp ${WORKSPACE}/build/chat_client ${APP_DIR}/usr/bin/
elif [ -f "${WORKSPACE}/bin/chat_client" ]; then
    echo "Found binary in bin directory, using it for AppImage packaging..."
    cp ${WORKSPACE}/bin/chat_client ${APP_DIR}/usr/bin/
else
    echo "No pre-built binary found. Attempting to build from source..."
    if [ ! -d "${WORKSPACE}/build" ]; then
        mkdir -p ${WORKSPACE}/build
    fi
    
    cd ${WORKSPACE}/build
    cmake ..
    make -j$(nproc)
    cd ${WORKSPACE}
    
    if [ -f "${WORKSPACE}/build/chat_client" ]; then
        cp ${WORKSPACE}/build/chat_client ${APP_DIR}/usr/bin/
    else
        echo "Error: Failed to build chat_client binary"
        exit 1
    fi
fi

# Copy required shared libraries
echo "Copying required shared libraries..."
ldd ${APP_DIR}/usr/bin/chat_client | grep "=>" | grep -v "ld-linux" | awk '{print $3}' | while read -r lib; do
    if [ -n "$lib" ] && [ -f "$lib" ]; then
        mkdir -p ${APP_DIR}/$(dirname ${lib#/})
        cp -L "$lib" ${APP_DIR}/${lib#/}
    fi
done

# Copy data files (if any)
if [ -d "${WORKSPACE}/data" ]; then
    echo "Copying data files..."
    cp -r ${WORKSPACE}/data/* ${APP_DIR}/data/
fi

# Create desktop file
cat > ${APP_DIR}/usr/share/applications/chat_client.desktop << EOF
[Desktop Entry]
Name=Audio-Visual Chat Client
Comment=Cross-platform audio-visual chat client with FLTK
Exec=chat_client
Icon=chat_client
Type=Application
Categories=Network;AudioVideo;Chat;
Terminal=false
StartupNotify=true
X-AppImage-Name=${APP_NAME}
X-AppImage-Version=${PKG_VERSION}
X-AppImage-Arch=${ARCH}
EOF

# Handle icon - supports both SVG and PNG formats
echo "Setting up application icon..."
if [ -f "${WORKSPACE}/data/icons/chat_client.svg" ]; then
    echo "Using SVG icon..."
    # Copy the SVG icon as-is
    cp ${WORKSPACE}/data/icons/chat_client.svg ${APP_DIR}/usr/share/icons/hicolor/scalable/apps/

    # Check if we can convert SVG to PNG formats (for systems that don't support SVG icons)
    if command -v convert &> /dev/null; then
        echo "Converting SVG to PNG formats for compatibility..."
        for size in 16 32 48 64 128 256; do
            mkdir -p ${APP_DIR}/usr/share/icons/hicolor/${size}x${size}/apps/
            convert -background none -resize ${size}x${size} ${WORKSPACE}/data/icons/chat_client.svg \
                ${APP_DIR}/usr/share/icons/hicolor/${size}x${size}/apps/chat_client.png
        done
    else
        echo "ImageMagick not found. SVG icon will be used directly."
    fi
elif [ -f "${WORKSPACE}/data/icons/chat_client.png" ]; then
    echo "Using PNG icon..."
    cp ${WORKSPACE}/data/icons/chat_client.png ${APP_DIR}/usr/share/icons/hicolor/256x256/apps/
else
    echo "No icon found, creating a placeholder..."
    echo "For a real build, please create an icon at data/icons/chat_client.svg or chat_client.png"
    # Create empty placeholder
    touch ${APP_DIR}/usr/share/icons/hicolor/256x256/apps/chat_client.png
fi

# Create AppStream metadata
mkdir -p ${APP_DIR}/usr/share/metainfo/
cat > ${APP_DIR}/usr/share/metainfo/com.movatalk.chat_client.appdata.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<component type="desktop-application">
  <id>com.movatalk.chat_client</id>
  <name>Audio-Visual Chat Client</name>
  <summary>Cross-platform audio-visual chat client</summary>
  <metadata_license>FSFAP</metadata_license>
  <project_license>Apache-2.0</project_license>
  <description>
    <p>
      A cross-platform audio-visual chat client built with C++ and FLTK.
      The application provides audio capture and playback capabilities along with
      a text-based chat interface.
    </p>
  </description>
  <launchable type="desktop-id">chat_client.desktop</launchable>
  <url type="homepage">https://github.com/movatalk/FLTK</url>
  <provides>
    <binary>chat_client</binary>
  </provides>
  <content_rating type="oars-1.1" />
  <releases>
    <release version="${PKG_VERSION}" date="$(date +%Y-%m-%d)" />
  </releases>
  <developer id="tom.sapletta">
    <name>Tom Sapletta</name>
  </developer>
</component>
EOF

# Create AppRun script
cat > ${APP_DIR}/AppRun << 'EOF'
#!/bin/bash
HERE="$(dirname "$(readlink -f "${0}")")"
export LD_LIBRARY_PATH="${HERE}/usr/lib:${LD_LIBRARY_PATH}"
export FLTK_BACKEND=hybrid

# Check if PulseAudio is running
if command -v pulseaudio >/dev/null 2>&1; then
    if pulseaudio --check; then
        export PULSE_SERVER=unix:${XDG_RUNTIME_DIR}/pulse/native
    fi
fi

# Launch the application
exec "${HERE}/usr/bin/chat_client" "$@"
EOF
chmod +x ${APP_DIR}/AppRun

echo "AppDir prepared. Setting up linuxdeploy..."

# Download linuxdeploy if it doesn't exist
if [ ! -f "$LINUXDEPLOY" ]; then
    echo "Downloading linuxdeploy..."
    wget "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/$LINUXDEPLOY"
    chmod +x "$LINUXDEPLOY"
fi

# Ensure linuxdeploy is executable
chmod +x "$LINUXDEPLOY"

# Create AppImage
echo "Creating AppImage..."
# Try with correctly named AppStream metadata
ARCH=${ARCH} VERSION=${PKG_VERSION} ./${LINUXDEPLOY} --appdir=${APP_DIR} --output=appimage

# Verify AppImage was created
if [ -f "${APP_NAME}-${PKG_VERSION}-${ARCH}.AppImage" ]; then
    chmod +x "${APP_NAME}-${PKG_VERSION}-${ARCH}.AppImage"
    echo "AppImage creation completed successfully: ${APP_NAME}-${PKG_VERSION}-${ARCH}.AppImage"
    
    # Verify AppImage is executable
    echo "Verifying AppImage integrity..."
    if ! ./${APP_NAME}-${PKG_VERSION}-${ARCH}.AppImage --appimage-offset >/dev/null 2>&1; then
        echo "Warning: AppImage may not be correctly formatted. Please check the build."
    else
        echo "AppImage verification passed!"
    fi
elif [ -f "Audio-Visual_Chat_Client-${PKG_VERSION}-${ARCH}.AppImage" ]; then
    # linuxdeploy sometimes uses the name from the desktop file instead
    mv "Audio-Visual_Chat_Client-${PKG_VERSION}-${ARCH}.AppImage" "${APP_NAME}-${PKG_VERSION}-${ARCH}.AppImage"
    chmod +x "${APP_NAME}-${PKG_VERSION}-${ARCH}.AppImage"
    echo "AppImage creation completed successfully (renamed): ${APP_NAME}-${PKG_VERSION}-${ARCH}.AppImage"
    
    # Verify AppImage is executable
    echo "Verifying AppImage integrity..."
    if ! ./${APP_NAME}-${PKG_VERSION}-${ARCH}.AppImage --appimage-offset >/dev/null 2>&1; then
        echo "Warning: AppImage may not be correctly formatted. Please check the build."
    else
        echo "AppImage verification passed!"
    fi
else
    # If the build fails, let's create a simple AppImage ourselves as a fallback
    echo "Standard AppImage creation failed, creating a simple portable package as fallback..."
    
    cat > ${APP_NAME}-${PKG_VERSION}-${ARCH}.AppImage << 'EOF'
#!/bin/bash
echo "Audio-Visual Chat Client v1.0.0"
echo "This is a portable package of the chat client application."
echo ""

# Get the directory where this script is located
HERE="$(dirname "$(readlink -f "${0}")")"
APPDIR="${HERE}/AppDir"

# Extract the AppDir if it doesn't exist
if [ ! -d "$APPDIR" ]; then
    echo "Extracting application files on first run..."
    ARCHIVE_START=$(grep -an "^__ARCHIVE__$" "$0" | cut -d: -f1)
    ARCHIVE_START=$((ARCHIVE_START + 1))
    tail -n +${ARCHIVE_START} "$0" | tar xz
    chmod +x "${APPDIR}/AppRun"
    echo "Extraction complete!"
fi

# Run the application
exec "${APPDIR}/AppRun" "$@"
exit 0

__ARCHIVE__
EOF
    
    # Append the AppDir as a tar.gz archive
    cd ${APP_DIR}/.. && tar czf - ${APP_NAME}.AppDir >> ${APP_NAME}-${PKG_VERSION}-${ARCH}.AppImage
    chmod +x ${APP_NAME}-${PKG_VERSION}-${ARCH}.AppImage
    
    echo "Simple portable package created as fallback: ${APP_NAME}-${PKG_VERSION}-${ARCH}.AppImage"
fi

# Print instructions for testing
echo ""
echo "=== AppImage Usage ==="
echo "To make the AppImage executable:"
echo "  chmod +x ${APP_NAME}-${PKG_VERSION}-${ARCH}.AppImage"
echo ""
echo "To run the AppImage:"
echo "  ./${APP_NAME}-${PKG_VERSION}-${ARCH}.AppImage"
echo ""
echo "For tests in Docker environment:"
echo "  ./packaging/appimage/test-appimage-in-docker.sh"
echo ""
