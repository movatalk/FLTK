#pragma once

#include <memory>
#include <vector>
#include <functional>
#include <atomic>
#include <string>

// Forward declare PortAudio types to avoid dependency in header
typedef void PaStream;

class AudioEngine {
public:
    enum class Backend { PIPEWIRE, PULSEAUDIO, ALSA, JACK };
    
    struct AudioDevice {
        int id;
        std::string name;
        int max_input_channels;
        int max_output_channels;
        std::vector<int> sample_rates;
        bool is_default;
    };
    
    using AudioCallback = std::function<void(const float* input, float* output, 
                                           unsigned int frames)>;
    using LevelCallback = std::function<void(float input_level, float output_level)>;
    
    AudioEngine();
    ~AudioEngine();
    
    bool initialize();
    std::vector<AudioDevice> get_devices();
    bool open_device(int device_id, unsigned int sample_rate = 44100);
    void set_audio_callback(AudioCallback callback);
    void set_level_callback(LevelCallback callback);
    void start_stream();
    void stop_stream();
    
    float get_input_level() const { return input_level_.load(); }
    float get_output_level() const { return output_level_.load(); }
    
private:
    PaStream* stream_;
    Backend current_backend_;
    AudioCallback audio_callback_;
    LevelCallback level_callback_;
    std::atomic<float> input_level_{0.0f};
    std::atomic<float> output_level_{0.0f};
    
    Backend detect_best_backend();
    static int pa_audio_callback(const void* input, void* output,
                               unsigned long frames_per_buffer,
                               const void* time_info,
                               unsigned long status_flags,
                               void* user_data);
};
