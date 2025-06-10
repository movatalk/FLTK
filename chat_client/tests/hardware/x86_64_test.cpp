#include "../../src/audio/audio_engine.h"
#include <iostream>
#include <string>
#include <chrono>

// Test for x86_64 specific optimizations
int main() {
    std::cout << "Running x86_64 specific tests..." << std::endl;
    
    #if defined(USE_SSE2) || defined(USE_AVX)
    std::cout << "✅ x86_64 SIMD optimizations enabled:" << std::endl;
    #ifdef USE_SSE2
    std::cout << "   - SSE2 support" << std::endl;
    #endif
    #ifdef USE_AVX
    std::cout << "   - AVX support" << std::endl;
    #endif
    #else
    std::cout << "❌ x86_64 SIMD optimizations not enabled" << std::endl;
    return 1;
    #endif
    
    // Test audio processing performance on x86_64
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
    
    std::cout << "x86_64 audio processing test: " << elapsed.count() << " ms" << std::endl;
    std::cout << "x86_64 tests completed successfully" << std::endl;
    
    return 0;
}
