# AppImage Packaging

This directory contains resources for AppImage packaging of the FLTK Chat Client.

## Current Files
- AppImage build script is located at `/scripts/build_appimage.sh`
- The AppStream metadata template is at `/cmake/chat_client.appdata.xml.in`

## AppImageHub Submission Checklist

1. Make sure your AppImage is built with the latest linuxdeploy.
2. Create a GitHub release with your AppImage file.
3. Test your AppImage on several distributions:
   - Ubuntu
   - Fedora
   - Debian
   - openSUSE

4. Create a pull request to [AppImageHub](https://github.com/AppImage/appimage.github.io) with:
   ```
   https://github.com/movatalk/FLTK/releases/download/v1.0.0/ChatClient-1.0.0-x86_64.AppImage
   ```

5. Metadata validation commands:
   ```bash
   # Validate the desktop file
   desktop-file-validate ChatClient.AppDir/usr/share/applications/chat_client.desktop
   
   # Validate the AppStream metadata
   appstream-util validate ChatClient.AppDir/usr/share/metainfo/chat_client.appdata.xml
   ```

## Useful Resources
- [AppImage Developer Guide](https://docs.appimage.org/packaging-guide/manual.html)
- [AppImageHub Submission](https://github.com/AppImage/appimage.github.io/blob/master/README.md)
