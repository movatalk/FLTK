#include "../../src/audio/audio_engine.h"
#include <iostream>
#include <string>
#include <chrono>

// Test for ARM64 specific optimizations
int main() {
    std::cout << "Running ARM64 specific tests..." << std::endl;
    
    #ifdef ARM64_NEON_OPTIMIZED
    std::cout << "✅ ARM64 NEON optimizations enabled" << std::endl;
    #else
    std::cout << "❌ ARM64 NEON optimizations not enabled" << std::endl;
    return 1;
    #endif
    
    // Test audio processing performance on ARM64
    constexpr size_t BUFFER_SIZE = 4096;
    float input_buffer[BUFFER_SIZE];
    float output_buffer[BUFFER_SIZE];
    
    // Fill buffer with test data
    for (size_t i = 0; i < BUFFER_SIZE; ++i) {
        input_buffer[i] = static_cast<float>(i) / BUFFER_SIZE;
    }
    
    // Measure processing time for a simple gain operation
    auto start = std::chrono::high_resolution_clock::now();
    
    for (int iter = 0; iter < 1000; ++iter) {
        for (size_t i = 0; i < BUFFER_SIZE; ++i) {
            output_buffer[i] = input_buffer[i] * 1.5f;
        }
    }
    
    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double, std::milli> elapsed = end - start;
    
    std::cout << "ARM64 audio processing test: " << elapsed.count() << " ms" << std::endl;
    std::cout << "ARM64 tests completed successfully" << std::endl;
    
    return 0;
}
