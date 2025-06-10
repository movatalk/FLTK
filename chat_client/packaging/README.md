# Chat Client Packaging

This directory contains configuration files for packaging the FLTK Chat Client for various distribution channels.

## Directory Structure

- **appimage/**
  - AppImage packaging support (already implemented in `/scripts/build_appimage.sh`)
  - AppImageHub submission guidelines
  
- **flatpak/**
  - Flatpak manifest file for building and publishing to Flathub
  - To test locally: `flatpak-builder --user --install build-dir flatpak/com.movatalk.ChatClient.json`
  - To submit to Flathub: [Follow these instructions](https://github.com/flathub/flathub/wiki/App-Submission)
  
- **snap/**
  - Snapcraft configuration for the Ubuntu Snap Store
  - To build: `cd snap && snapcraft`
  - To publish: `snap login && snapcraft upload --release=stable chat-client_1.0.0_amd64.snap`
  
- **debian/**
  - Debian/Ubuntu packaging files
  - To build: `dpkg-buildpackage -us -uc -b`
  - PPA publishing instructions included
  
- **rpm/**
  - RPM spec file for Fedora/RHEL/openSUSE
  - To build: `rpmbuild -ba rpm/chat-client.spec`
  - COPR publishing instructions included
  
- **aur/**
  - Arch Linux PKGBUILD file
  - To build: `cd aur && makepkg -si`
  - AUR publishing instructions included
  
- **appstream/**
  - AppStream metadata for improved software center integration
  - Add screenshots here for better visibility in app stores

## Publishing Checklist

1. **GitHub Release**
   - Create a GitHub release with version tag (e.g., `v1.0.0`)
   - Upload AppImage, source tarball, and binary packages
   - Add release notes and changelog

2. **AppImageHub**
   - Submit your AppImage to AppImageHub after creating a GitHub release

3. **Flathub**
   - Create a new repository under the Flathub organization
   - Submit your manifest file

4. **Snap Store**
   - Register your snap name
   - Upload your snap package

5. **Linux Distributions**
   - Debian/Ubuntu: Create a PPA or submit to the official repositories
   - Fedora: Submit to COPR or as a package review request
   - Arch: Submit to AUR

## Resources

- [AppImage Documentation](https://docs.appimage.org/)
- [Flatpak Documentation](https://docs.flatpak.org/)
- [Snapcraft Documentation](https://snapcraft.io/docs)
- [Debian Packaging Guide](https://www.debian.org/doc/manuals/packaging-tutorial/packaging-tutorial.en.pdf)
- [RPM Packaging Guide](https://rpm-packaging-guide.github.io/)
- [AUR Submission Guidelines](https://wiki.archlinux.org/title/AUR_submission_guidelines)
- [AppStream Metadata Guide](https://www.freedesktop.org/software/appstream/docs/)
