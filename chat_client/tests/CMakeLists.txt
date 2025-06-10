cmake_minimum_required(VERSION 3.16)

# Unit tests
add_executable(audio_test unit/audio_tests.cpp)
target_include_directories(audio_test PRIVATE ${CMAKE_SOURCE_DIR}/src)
add_test(NAME AudioTest COMMAND audio_test)

# Integration test
add_executable(integration_test integration/full_system_test.cpp)
target_include_directories(integration_test PRIVATE ${CMAKE_SOURCE_DIR}/src)
add_test(NAME IntegrationTest COMMAND integration_test)

# Hardware-specific tests
if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|arm64")
    add_executable(arm64_test hardware/arm64_test.cpp)
    target_include_directories(arm64_test PRIVATE ${CMAKE_SOURCE_DIR}/src)
    add_test(NAME ARM64Test COMMAND arm64_test)
endif()

if(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64")
    add_executable(x86_64_test hardware/x86_64_test.cpp)
    target_include_directories(x86_64_test PRIVATE ${CMAKE_SOURCE_DIR}/src)
    add_test(NAME X86_64Test COMMAND x86_64_test)
endif()
