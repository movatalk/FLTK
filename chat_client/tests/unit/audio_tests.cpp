#include "../../src/audio/audio_engine.h"
#include <iostream>
#include <cassert>

int main() {
    std::cout << "Running audio engine tests..." << std::endl;
    
    // Create audio engine
    AudioEngine engine;
    
    // Test initialization
    bool init_result = engine.initialize();
    std::cout << "Audio initialization: " << (init_result ? "SUCCESS" : "FAILED") << std::endl;
    
    if (init_result) {
        // Test device enumeration
        auto devices = engine.get_devices();
        std::cout << "Found " << devices.size() << " audio devices:" << std::endl;
        
        for (const auto& device : devices) {
            std::cout << "- Device ID: " << device.id << ", Name: " << device.name
                      << " (Input: " << device.max_input_channels
                      << ", Output: " << device.max_output_channels << ")" << std::endl;
        }
        
        // Don't actually open devices in automated tests to avoid issues
        std::cout << "Skipping device open test in automated environment" << std::endl;
    }
    
    std::cout << "Audio tests completed" << std::endl;
    return init_result ? 0 : 1;
}
