#!/bin/bash
# Simple script to create a chat client icon

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "ImageMagick is required to create the icon."
    echo "Please install it with: sudo apt-get install imagemagick"
    exit 1
fi

# Create the icon
convert -size 256x256 xc:SkyBlue \
        -fill white -draw "circle 128,128 128,28" \
        -fill "#303030" -draw "circle 128,128 100,100" \
        -fill white -font DejaVu-Sans-Bold -pointsize 100 -gravity center -annotate 0 "C" \
        chat_client.png

echo "Icon created at: chat_client.png"
