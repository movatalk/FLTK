set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)
set(CMAKE_AR aarch64-linux-gnu-ar)
set(CMAKE_STRIP aarch64-linux-gnu-strip)

set(CMAKE_FIND_ROOT_PATH /usr/aarch64-linux-gnu)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# ARM64 optimizations
set(CMAKE_C_FLAGS "-march=armv8-a -mtune=cortex-a72 -O3 -ffast-math")
set(CMAKE_CXX_FLAGS "-march=armv8-a -mtune=cortex-a72 -O3 -ffast-math -funroll-loops")

# NEON SIMD support
add_definitions(-DARM_NEON)
