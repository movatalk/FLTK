/**
 * Audio-Visual Chat Client
 * 
 * @file main.cpp
 * @author Tom Sapletta
 * @copyright 2025 Tom Sapletta
 * @license Apache-2.0
 */

#include "core/application.h"
#include <iostream>

int main(int argc, char** argv) {
    try {
        // Create and initialize application
        Application app(argc, argv);
        
        if (!app.initialize()) {
            std::cerr << "Failed to initialize application" << std::endl;
            return 1;
        }
        
        std::cout << "Audio-Visual Chat Client started successfully" << std::endl;
        
        // Run application
        int result = app.run();
        
        // Cleanup
        app.shutdown();
        
        return result;
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    } catch (...) {
        std::cerr << "Unknown error occurred" << std::endl;
        return 1;
    }
}
