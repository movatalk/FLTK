#!/bin/bash
#
# Audio-Visual Chat Client - Dependencies Installation Script
# Author: Tom Sapletta
# License: Apache-2.0
# Copyright 2025 Tom Sapletta
#

# Installation script for chat client dependencies
# Supports Ubuntu/Debian, Fedora, and Arch Linux

set -e

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}    FLTK Chat Client Dependency Installer         ${NC}"
echo -e "${BLUE}==================================================${NC}"

# Check if script has root privileges
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}This script requires root privileges.${NC}"
        echo -e "Please run with: ${YELLOW}sudo $0${NC}"
        exit 1
    fi
}

# Detect Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
        echo -e "${GREEN}Detected distribution: $NAME $VERSION_ID${NC}"
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$DISTRIB_ID
        VERSION=$DISTRIB_RELEASE
        echo -e "${GREEN}Detected distribution: $DISTRIB_ID $DISTRIB_RELEASE${NC}"
    elif [ -f /etc/fedora-release ]; then
        OS="fedora"
        echo -e "${GREEN}Detected distribution: Fedora${NC}"
    elif [ -f /etc/arch-release ]; then
        OS="arch"
        echo -e "${GREEN}Detected distribution: Arch Linux${NC}"
    else
        echo -e "${RED}Unsupported Linux distribution.${NC}"
        echo -e "This script supports: ${YELLOW}Ubuntu, Debian, Fedora, and Arch Linux${NC}"
        exit 1
    fi
}

# Install dependencies for Ubuntu/Debian
install_ubuntu_debian() {
    echo -e "${BLUE}Installing dependencies for Ubuntu/Debian...${NC}"
    apt-get update
    apt-get install -y \
        build-essential \
        cmake \
        git \
        libfltk1.3-dev \
        libportaudio2 \
        libportaudiocpp0 \
        portaudio19-dev \
        libssl-dev \
        libcurl4-openssl-dev \
        libasound2-dev \
        libpulse-dev \
        libespeak-ng-dev \
        pkg-config
    echo -e "${GREEN}Dependencies installed successfully!${NC}"
}

# Install dependencies for Fedora
install_fedora() {
    echo -e "${BLUE}Installing dependencies for Fedora...${NC}"
    dnf update -y
    dnf install -y \
        gcc-c++ \
        make \
        cmake \
        git \
        fltk-devel \
        portaudio-devel \
        openssl-devel \
        libcurl-devel \
        alsa-lib-devel \
        pulseaudio-libs-devel \
        espeak-ng-devel \
        pkg-config
    echo -e "${GREEN}Dependencies installed successfully!${NC}"
}

# Install dependencies for Arch Linux
install_arch() {
    echo -e "${BLUE}Installing dependencies for Arch Linux...${NC}"
    pacman -Syu --noconfirm
    pacman -S --needed --noconfirm \
        base-devel \
        cmake \
        git \
        fltk \
        portaudio \
        openssl \
        curl \
        alsa-lib \
        pulseaudio \
        espeak-ng \
        pkg-config
    echo -e "${GREEN}Dependencies installed successfully!${NC}"
}

# Main installation logic
main() {
    check_root
    detect_distro
    
    case $OS in
        ubuntu|debian|linuxmint|pop)
            install_ubuntu_debian
            ;;
        fedora)
            install_fedora
            ;;
        arch|manjaro)
            install_arch
            ;;
        *)
            echo -e "${RED}Unsupported distribution: $OS${NC}"
            echo -e "This script supports: ${YELLOW}Ubuntu, Debian, Fedora, and Arch Linux${NC}"
            exit 1
            ;;
    esac
    
    echo -e "${BLUE}==================================================${NC}"
    echo -e "${GREEN}All dependencies installed successfully!${NC}"
    echo -e "${YELLOW}You can now build the chat client with:${NC}"
    echo -e "  cd $(dirname $(dirname $(readlink -f $0)))"
    echo -e "  make -j$(nproc)"
    echo -e "${BLUE}==================================================${NC}"
}

# Run the main function
main
