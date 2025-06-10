# AppStream Metadata for Chat Client

This directory contains the AppStream metadata for the chat client, which helps software centers display your application with the correct information.

## Important Files
- Base AppStream metadata is already defined in `cmake/chat_client.appdata.xml.in`
- Screenshots should be placed in this directory and referenced in the AppStream metadata

## Required Screenshot Sizes
For optimal display in software centers:
- Main screenshot: 1248×702 px (16:9 aspect ratio)
- Additional screenshots: At least 624×351 px (16:9 aspect ratio)

## How to Add Screenshots
1. Add screenshot files to this directory:
   - `screenshot-1.png` - Main application window
   - `screenshot-2.png` - Chat features
   - `screenshot-3.png` - Audio/video controls

2. Update the AppStream metadata file to include these screenshots:
   ```xml
   <screenshots>
     <screenshot type="default">
       <image>https://raw.githubusercontent.com/movatalk/FLTK/main/chat_client/packaging/appstream/screenshot-1.png</image>
       <caption>Main interface of the chat client</caption>
     </screenshot>
     <screenshot>
       <image>https://raw.githubusercontent.com/movatalk/FLTK/main/chat_client/packaging/appstream/screenshot-2.png</image>
       <caption>Chat features</caption>
     </screenshot>
     <screenshot>
       <image>https://raw.githubusercontent.com/movatalk/FLTK/main/chat_client/packaging/appstream/screenshot-3.png</image>
       <caption>Audio/video controls</caption>
     </screenshot>
   </screenshots>
   ```

## Validation
Validate your AppStream metadata with:
```bash
appstream-util validate chat_client.appdata.xml
```

## Resources
- [AppStream Documentation](https://www.freedesktop.org/software/appstream/docs/)
- [AppStream Metadata Templates](https://github.com/ximion/appstream/tree/master/data/templates)
