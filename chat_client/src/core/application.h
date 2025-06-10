#pragma once

#include <memory>
#include <string>

// Forward declarations
class AudioEngine;
class MainWindow;
class ConfigManager;
class ProtocolManager;

class Application {
public:
    Application(int argc, char** argv);
    ~Application();

    bool initialize();
    int run();
    void shutdown();

private:
    class Impl;
    std::unique_ptr<Impl> pImpl;
};
