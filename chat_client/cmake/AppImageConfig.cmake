include(GNUInstallDirs)

# Installation paths for AppImage packaging
# This file is included by the main CMakeLists.txt when building for AppImage

# Install binaries
install(TARGETS chat_client
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    COMPONENT applications
)

# Install data files
install(DIRECTORY ${CMAKE_SOURCE_DIR}/data/
    DESTINATION ${CMAKE_INSTALL_DATADIR}/chat_client
    COMPONENT data
    FILES_MATCHING PATTERN "*"
)

# Install icons
install(FILES ${CMAKE_SOURCE_DIR}/data/icons/chat_client.svg
    DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/256x256/apps/
    COMPONENT icons
    OPTIONAL
)

# Install desktop file
configure_file(
    ${CMAKE_SOURCE_DIR}/cmake/chat_client.desktop.in
    ${CMAKE_BINARY_DIR}/chat_client.desktop
    @ONLY
)
install(FILES ${CMAKE_BINARY_DIR}/chat_client.desktop
    DESTINATION ${CMAKE_INSTALL_DATADIR}/applications/
    COMPONENT desktop
)

# Install AppStream metadata
configure_file(
    ${CMAKE_SOURCE_DIR}/cmake/chat_client.appdata.xml.in
    ${CMAKE_BINARY_DIR}/chat_client.appdata.xml
    @ONLY
)
install(FILES ${CMAKE_BINARY_DIR}/chat_client.appdata.xml
    DESTINATION ${CMAKE_INSTALL_DATADIR}/metainfo/
    COMPONENT appdata
)
