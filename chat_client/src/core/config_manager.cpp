#include "config_manager.h"
#include <fstream>
#include <iostream>
#include <sstream>

ConfigManager::ConfigManager() = default;
ConfigManager::~ConfigManager() = default;

bool ConfigManager::load_config(const std::string& file_path) {
    std::ifstream file(file_path);
    if (!file.is_open()) {
        std::cerr << "Failed to open config file: " << file_path << std::endl;
        return false;
    }

    config_values_.clear();
    std::string line;
    while (std::getline(file, line)) {
        // Skip comments and empty lines
        if (line.empty() || line[0] == '#') continue;
        
        // Parse key=value format
        std::istringstream iss(line);
        std::string key, value;
        
        if (std::getline(iss, key, '=') && std::getline(iss, value)) {
            config_values_[key] = value;
        }
    }

    return true;
}

bool ConfigManager::save_config(const std::string& file_path) {
    std::ofstream file(file_path);
    if (!file.is_open()) {
        std::cerr << "Failed to open config file for writing: " << file_path << std::endl;
        return false;
    }

    file << "# Audio-Visual Chat Client Configuration\n";
    file << "# Generated on " << __DATE__ << " " << __TIME__ << "\n\n";
    
    for (const auto& [key, value] : config_values_) {
        file << key << "=" << value << "\n";
    }

    return true;
}

bool ConfigManager::get_bool(const std::string& key, bool default_value) const {
    auto it = config_values_.find(key);
    if (it == config_values_.end()) {
        return default_value;
    }
    
    return (it->second == "true" || it->second == "1" || it->second == "yes");
}

int ConfigManager::get_int(const std::string& key, int default_value) const {
    auto it = config_values_.find(key);
    if (it == config_values_.end()) {
        return default_value;
    }
    
    try {
        return std::stoi(it->second);
    } catch (...) {
        return default_value;
    }
}

float ConfigManager::get_float(const std::string& key, float default_value) const {
    auto it = config_values_.find(key);
    if (it == config_values_.end()) {
        return default_value;
    }
    
    try {
        return std::stof(it->second);
    } catch (...) {
        return default_value;
    }
}

std::string ConfigManager::get_string(const std::string& key, const std::string& default_value) const {
    auto it = config_values_.find(key);
    if (it == config_values_.end()) {
        return default_value;
    }
    
    return it->second;
}

void ConfigManager::set_bool(const std::string& key, bool value) {
    config_values_[key] = value ? "true" : "false";
}

void ConfigManager::set_int(const std::string& key, int value) {
    config_values_[key] = std::to_string(value);
}

void ConfigManager::set_float(const std::string& key, float value) {
    config_values_[key] = std::to_string(value);
}

void ConfigManager::set_string(const std::string& key, const std::string& value) {
    config_values_[key] = value;
}
