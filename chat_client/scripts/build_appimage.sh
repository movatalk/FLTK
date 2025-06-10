#!/bin/bash
# Build AppImage package for chat client

set -ex

# Define variables
APP_NAME="ChatClient"
PKG_VERSION="1.0.0"
ARCH="$(uname -m)"
APP_DIR="$APP_NAME.AppDir"
LINUXDEPLOY="linuxdeploy-x86_64.AppImage"
WORKSPACE=$(pwd)

# Clean up any previous build
rm -rf "$APP_DIR" || true
rm -f "./$APP_NAME-$PKG_VERSION-$ARCH.AppImage" || true

# Create AppDir structure
mkdir -p "$APP_DIR/usr/bin"
mkdir -p "$APP_DIR/usr/lib"
mkdir -p "$APP_DIR/usr/share/applications"
mkdir -p "$APP_DIR/usr/share/icons/hicolor/256x256/apps"
mkdir -p "$APP_DIR/usr/share/metainfo"
mkdir -p "$APP_DIR/data/config"

# Build the application in release mode
echo "Building application..."
mkdir -p build-appimage
cd build-appimage
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr ..
make -j$(nproc)
make install DESTDIR="../$APP_DIR"
cd ..

# Copy data files
cp -r data/* "$APP_DIR/data/"

# Create desktop file
cat > "$APP_DIR/usr/share/applications/$APP_NAME.desktop" << EOF
[Desktop Entry]
Name=Audio-Visual Chat Client
Comment=Cross-platform audio-visual chat client
Exec=chat_client
Icon=chat_client
Type=Application
Categories=Network;Chat;AudioVideo;
Terminal=false
StartupNotify=true
EOF

# Create simple icon if it doesn't exist
if [ ! -f "data/icons/chat_client.png" ]; then
    # Generate a simple color icon if no custom icon available
    convert -size 256x256 xc:SkyBlue \
            -draw "fill white circle 128,128 100,100" \
            -draw "fill black circle 128,128 80,80" \
            -draw "fill SkyBlue circle 128,128 50,50" \
            "$APP_DIR/usr/share/icons/hicolor/256x256/apps/chat_client.png"
else
    cp "data/icons/chat_client.png" "$APP_DIR/usr/share/icons/hicolor/256x256/apps/chat_client.png"
fi

# Create AppStream metadata
cat > "$APP_DIR/usr/share/metainfo/$APP_NAME.appdata.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<component type="desktop-application">
  <id>com.movatalk.chat_client</id>
  <name>Audio-Visual Chat Client</name>
  <summary>Cross-platform audio-visual chat client</summary>
  <description>
    <p>
      A cross-platform audio-visual chat client built with C++ and FLTK.
      The application provides audio capture and playback capabilities along with
      a text-based chat interface, designed for both ARM64 and x86_64 platforms.
    </p>
  </description>
  <launchable type="desktop-id">ChatClient.desktop</launchable>
  <url type="homepage">https://github.com/movatalk/FLTK</url>
  <provides>
    <binary>chat_client</binary>
  </provides>
  <releases>
    <release version="1.0.0" date="2025-06-10"/>
  </releases>
</component>
EOF

# Create AppRun script
cat > "$APP_DIR/AppRun" << 'EOF'
#!/bin/bash
HERE="$(dirname "$(readlink -f "${0}")")"
export LD_LIBRARY_PATH="$HERE/usr/lib:$HERE/usr/lib/x86_64-linux-gnu:$HERE/usr/lib/i386-linux-gnu:$HERE/usr/lib32:$HERE/usr/lib64:$HERE/lib:$HERE/lib/x86_64-linux-gnu:$HERE/lib/i386-linux-gnu:$HERE/lib32:$HERE/lib64:$LD_LIBRARY_PATH"
export PATH="$HERE/usr/bin:$PATH"
export XDG_DATA_DIRS="$HERE/usr/share:$XDG_DATA_DIRS"
export FLTK_BACKEND="hybrid"

# Check if we need to handle audio configuration
if command -v pulseaudio >/dev/null 2>&1; then
    export PULSE_SERVER="unix:${XDG_RUNTIME_DIR}/pulse/native"
fi

# Run the application
"$HERE/usr/bin/chat_client" "$@"
EOF

chmod +x "$APP_DIR/AppRun"

# Download linuxdeploy if not present
if [ ! -f "$LINUXDEPLOY" ]; then
    echo "Downloading linuxdeploy..."
    wget -c "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
    chmod +x "$LINUXDEPLOY"
fi

# Build AppImage
echo "Creating AppImage..."
./"$LINUXDEPLOY" --appdir="$APP_DIR" --output appimage

echo "AppImage created successfully: $APP_NAME-$PKG_VERSION-$ARCH.AppImage"
