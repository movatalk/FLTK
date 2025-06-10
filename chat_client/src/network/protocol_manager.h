#ifndef PROTOCOL_MANAGER_H
#define PROTOCOL_MANAGER_H

#include <memory>
#include <string>
#include <functional>  // Add include for std::function

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

#endif // PROTOCOL_MANAGER_H
