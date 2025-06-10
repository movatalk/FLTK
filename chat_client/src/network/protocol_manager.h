#pragma once

#include <memory>

class ConfigManager;

class ProtocolManager {
public:
    ProtocolManager();
    ~ProtocolManager();
    
    bool initialize(ConfigManager* config_manager);
    void shutdown();
    
    bool send_message(const std::string& channel, const std::string& message);
    void register_message_callback(std::function<void(const std::string&, const std::string&)> callback);

private:
    class Impl;
    std::unique_ptr<Impl> pImpl;
};
