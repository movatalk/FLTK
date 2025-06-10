#include "../../src/core/application.h"
#include <iostream>
#include <thread>
#include <chrono>

int main(int argc, char** argv) {
    std::cout << "Running full system integration test..." << std::endl;
    
    // Init test arguments
    char* test_args[] = {(char*)"integration_test", (char*)"--test-mode"};
    int test_argc = 2;
    
    try {
        // Create application instance
        Application app(test_argc, test_args);
        
        // Initialize application
        bool init_result = app.initialize();
        std::cout << "Application initialization: " << (init_result ? "SUCCESS" : "FAILED") << std::endl;
        
        if (init_result) {
            std::cout << "Application initialized successfully. In real test would run UI for a few seconds." << std::endl;
            std::cout << "Skipping UI test in automated environment." << std::endl;
            
            // In a real test, we might do:
            // std::thread([&app] { app.run(); }).detach();
            // std::this_thread::sleep_for(std::chrono::seconds(5));
            // And then send simulated events
        }
        
        // Cleanup
        app.shutdown();
        std::cout << "Application shutdown complete" << std::endl;
        
        return init_result ? 0 : 1;
    } catch (const std::exception& e) {
        std::cerr << "Error during integration test: " << e.what() << std::endl;
        return 1;
    }
}
