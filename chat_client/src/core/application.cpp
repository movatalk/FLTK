#include "application.h"
#include "../audio/audio_engine.h"
#include "../gui/main_window.h"
#include "config_manager.h"
#include "../network/protocol_manager.h"

#include <FL/Fl.H>
#include <iostream>

class Application::Impl {
public:
    int argc;
    char** argv;
    std::unique_ptr<ConfigManager> config_manager;
    std::unique_ptr<AudioEngine> audio_engine;
    std::unique_ptr<MainWindow> main_window;
    std::unique_ptr<ProtocolManager> protocol_manager;
    
    Impl(int argc_, char** argv_) 
        : argc(argc_), argv(argv_) {}
};

Application::Application(int argc, char** argv) 
    : pImpl(std::make_unique<Impl>(argc, argv)) {
}

Application::~Application() = default;

bool Application::initialize() {
    // Initialize FLTK
    Fl::scheme("gtk+");
    Fl::visual(FL_DOUBLE | FL_RGB);
    
    // Create config manager
    pImpl->config_manager = std::make_unique<ConfigManager>();
    if (!pImpl->config_manager->load_config("config/default.json")) {
        std::cerr << "Failed to load configuration" << std::endl;
        return false;
    }
    
    // Initialize audio engine
    pImpl->audio_engine = std::make_unique<AudioEngine>();
    if (!pImpl->audio_engine->initialize()) {
        std::cerr << "Failed to initialize audio engine" << std::endl;
        return false;
    }
    
    // Create and show main window
    pImpl->main_window = std::make_unique<MainWindow>(
        "Audio-Visual Chat Client", 
        800, 600, 
        pImpl->audio_engine.get()
    );
    pImpl->main_window->show();
    
    // Initialize protocol manager
    pImpl->protocol_manager = std::make_unique<ProtocolManager>();
    if (!pImpl->protocol_manager->initialize(pImpl->config_manager.get())) {
        std::cerr << "Warning: Failed to initialize communication protocols" << std::endl;
        // Continue anyway, user might configure it later
    }
    
    return true;
}

int Application::run() {
    // Start FLTK event loop
    return Fl::run();
}

void Application::shutdown() {
    if (pImpl->audio_engine) {
        pImpl->audio_engine->stop_stream();
    }
    
    if (pImpl->protocol_manager) {
        pImpl->protocol_manager->shutdown();
    }
}
