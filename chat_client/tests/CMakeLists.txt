cmake_minimum_required(VERSION 3.16)

# Unit tests
add_executable(audio_test unit/audio_tests.cpp)
target_include_directories(audio_test PRIVATE ${CMAKE_SOURCE_DIR}/src)
add_test(NAME AudioTest COMMAND audio_test)

# Integration test
add_executable(integration_test integration/full_system_test.cpp)
target_include_directories(integration_test PRIVATE ${CMAKE_SOURCE_DIR}/src)
add_test(NAME IntegrationTest COMMAND integration_test)
