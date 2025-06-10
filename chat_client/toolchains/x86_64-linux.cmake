set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

# Use standard system compiler
set(CMAKE_C_COMPILER gcc)
set(CMAKE_CXX_COMPILER g++)

# x86_64 optimizations
set(CMAKE_C_FLAGS "-march=x86-64-v2 -mtune=generic -O3 -ffast-math")
set(CMAKE_CXX_FLAGS "-march=x86-64-v2 -mtune=generic -O3 -ffast-math -funroll-loops")

# SSE/AVX support
add_definitions(-DUSE_SSE2 -DUSE_AVX)
