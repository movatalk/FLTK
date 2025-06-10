cmake_minimum_required(VERSION 3.16)
project(AudioChatClient VERSION 1.0.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find FLTK
find_package(FLTK REQUIRED)

# Find PortAudio
find_package(PkgConfig REQUIRED)
pkg_check_modules(PORTAUDIO REQUIRED portaudio-2.0)

# Platform-specific optimizations
if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|arm64")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=armv8-a -mtune=cortex-a72 -O3")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -funroll-loops -ffast-math")
    add_definitions(-DARM64_NEON_OPTIMIZED)
endif()

# Sources
file(GLOB_RECURSE SOURCES 
    "src/*.cpp"
    "src/*.h"
)

add_executable(chat_client ${SOURCES})

# Include directories
target_include_directories(chat_client PRIVATE
    ${CMAKE_SOURCE_DIR}/include
    ${FLTK_INCLUDE_DIR}
    ${PORTAUDIO_INCLUDE_DIRS}
)

# Link libraries
target_link_libraries(chat_client PRIVATE
    ${FLTK_LIBRARIES}
    ${PORTAUDIO_LIBRARIES}
    pthread
)

# Installation
install(TARGETS chat_client DESTINATION bin)
install(DIRECTORY data/ DESTINATION share/chat_client)

# Testing
enable_testing()
add_subdirectory(tests)
