#pragma once

#include <string>
#include <unordered_map>

class ConfigManager {
public:
    ConfigManager();
    ~ConfigManager();

    bool load_config(const std::string& file_path);
    bool save_config(const std::string& file_path);
    
    bool get_bool(const std::string& key, bool default_value = false) const;
    int get_int(const std::string& key, int default_value = 0) const;
    float get_float(const std::string& key, float default_value = 0.0f) const;
    std::string get_string(const std::string& key, const std::string& default_value = "") const;
    
    void set_bool(const std::string& key, bool value);
    void set_int(const std::string& key, int value);
    void set_float(const std::string& key, float value);
    void set_string(const std::string& key, const std::string& value);

private:
    std::unordered_map<std::string, std::string> config_values_;
};
