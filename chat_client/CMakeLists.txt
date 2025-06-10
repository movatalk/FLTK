cmake_minimum_required(VERSION 3.16)
project(chat_client VERSION 1.0.0 LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Add compile options
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra")

# Find required packages
find_package(FLTK REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_check_modules(PORTAUDIO REQUIRED portaudio-2.0)
find_package(Threads REQUIRED)

# Add platform specific flags and libraries
if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|arm64")
    message(STATUS "Building for ARM64 architecture")
    add_compile_options(-march=armv8-a -mtune=cortex-a72 -O3)
    add_compile_definitions(ARM_NEON)
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64")
    message(STATUS "Building for x86_64 architecture")
    add_compile_options(-march=x86-64-v2 -mtune=generic -O3)
    add_compile_definitions(USE_SSE2 USE_AVX)
endif()

# Source files
file(GLOB_RECURSE SOURCES 
    "src/*.cpp"
    "src/*.h"
)

# Include directories
include_directories(
    ${CMAKE_SOURCE_DIR}/include
    ${FLTK_INCLUDE_DIR}
    ${PORTAUDIO_INCLUDE_DIRS}
)

# Define the executable
add_executable(chat_client ${SOURCES})

# Link libraries
target_link_libraries(chat_client
    ${FLTK_LIBRARIES}
    ${PORTAUDIO_LIBRARIES}
    ${CMAKE_THREAD_LIBS_INIT}
    pthread
)

# Option to build AppImage
option(BUILD_APPIMAGE "Configure project for AppImage packaging" OFF)
if(BUILD_APPIMAGE)
    message(STATUS "Configuring for AppImage packaging")
    include(${CMAKE_SOURCE_DIR}/cmake/AppImageConfig.cmake)
endif()

# Basic installation rules (for non-AppImage builds)
if(NOT BUILD_APPIMAGE)
    install(TARGETS chat_client DESTINATION bin)
    install(DIRECTORY data/ DESTINATION share/chat_client)
endif()

# Enable testing
enable_testing()
add_subdirectory(tests)
