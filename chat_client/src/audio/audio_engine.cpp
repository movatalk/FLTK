#include "audio_engine.h"
#include <portaudio.h>
#include <iostream>
#include <cmath>

AudioEngine::AudioEngine()
    : stream_(nullptr), current_backend_(Backend::PULSEAUDIO) {
}

AudioEngine::~AudioEngine() {
    stop_stream();
    Pa_Terminate();
}

bool AudioEngine::initialize() {
    PaError err = Pa_Initialize();
    if (err != paNoError) {
        std::cerr << "PortAudio initialization error: " << Pa_GetErrorText(err) << std::endl;
        return false;
    }
    
    current_backend_ = detect_best_backend();
    return true;
}

AudioEngine::Backend AudioEngine::detect_best_backend() {
    // In a real implementation, we would detect available backends
    // based on available host APIs. For now, default to PulseAudio
    // as it's widely available on Linux.
    return Backend::PULSEAUDIO;
}

std::vector<AudioEngine::AudioDevice> AudioEngine::get_devices() {
    std::vector<AudioDevice> devices;
    
    int num_devices = Pa_GetDeviceCount();
    if (num_devices < 0) {
        std::cerr << "PortAudio error: " << Pa_GetErrorText(num_devices) << std::endl;
        return devices;
    }
    
    const PaDeviceInfo* device_info;
    for (int i = 0; i < num_devices; ++i) {
        device_info = Pa_GetDeviceInfo(i);
        if (device_info) {
            AudioDevice device;
            device.id = i;
            device.name = device_info->name;
            device.max_input_channels = device_info->maxInputChannels;
            device.max_output_channels = device_info->maxOutputChannels;
            
            // Add common sample rates
            if (device_info->maxInputChannels > 0 || device_info->maxOutputChannels > 0) {
                device.sample_rates = { 8000, 16000, 22050, 44100, 48000 };
            }
            
            device.is_default = (i == Pa_GetDefaultInputDevice() || 
                               i == Pa_GetDefaultOutputDevice());
            
            devices.push_back(device);
        }
    }
    
    return devices;
}

bool AudioEngine::open_device(int device_id, unsigned int sample_rate) {
    stop_stream(); // Close any existing stream
    
    PaStreamParameters input_params = {};
    input_params.device = device_id;
    input_params.channelCount = 1; // Mono input
    input_params.sampleFormat = paFloat32;
    input_params.suggestedLatency = Pa_GetDeviceInfo(device_id)->defaultLowInputLatency;
    input_params.hostApiSpecificStreamInfo = nullptr;
    
    PaStreamParameters output_params = {};
    output_params.device = device_id;
    output_params.channelCount = 2; // Stereo output
    output_params.sampleFormat = paFloat32;
    output_params.suggestedLatency = Pa_GetDeviceInfo(device_id)->defaultLowOutputLatency;
    output_params.hostApiSpecificStreamInfo = nullptr;
    
    PaError err = Pa_OpenStream(
        &stream_,
        &input_params,
        &output_params,
        sample_rate,
        256, // Frames per buffer
        paClipOff,
        &AudioEngine::pa_audio_callback,
        this
    );
    
    if (err != paNoError) {
        std::cerr << "Failed to open audio stream: " << Pa_GetErrorText(err) << std::endl;
        stream_ = nullptr;
        return false;
    }
    
    return true;
}

void AudioEngine::start_stream() {
    if (stream_) {
        PaError err = Pa_StartStream(stream_);
        if (err != paNoError) {
            std::cerr << "Failed to start audio stream: " << Pa_GetErrorText(err) << std::endl;
        }
    }
}

void AudioEngine::stop_stream() {
    if (stream_) {
        if (Pa_IsStreamActive(stream_) == 1) {
            Pa_StopStream(stream_);
        }
        Pa_CloseStream(stream_);
        stream_ = nullptr;
    }
}

void AudioEngine::set_audio_callback(AudioCallback callback) {
    audio_callback_ = std::move(callback);
}

void AudioEngine::set_level_callback(LevelCallback callback) {
    level_callback_ = std::move(callback);
}

int AudioEngine::pa_audio_callback(const void* input, void* output,
                                 unsigned long frames_per_buffer,
                                 const void* time_info,
                                 unsigned long status_flags,
                                 void* user_data) {
    auto* engine = static_cast<AudioEngine*>(user_data);
    
    const float* input_buffer = static_cast<const float*>(input);
    float* output_buffer = static_cast<float*>(output);
    
    // Clear output buffer
    memset(output_buffer, 0, sizeof(float) * frames_per_buffer * 2); // Stereo output
    
    // Calculate input level (RMS)
    float sum = 0.0f;
    for (unsigned long i = 0; i < frames_per_buffer; ++i) {
        sum += input_buffer[i] * input_buffer[i];
    }
    float rms = sqrtf(sum / frames_per_buffer);
    engine->input_level_.store(rms);
    
    // Call user callback if set
    if (engine->audio_callback_) {
        engine->audio_callback_(input_buffer, output_buffer, frames_per_buffer);
    } else {
        // Simple passthrough if no callback
        for (unsigned long i = 0; i < frames_per_buffer; ++i) {
            output_buffer[i*2] = input_buffer[i]; // Left channel
            output_buffer[i*2+1] = input_buffer[i]; // Right channel
        }
    }
    
    // Calculate output level
    sum = 0.0f;
    for (unsigned long i = 0; i < frames_per_buffer * 2; i += 2) {
        float avg = (output_buffer[i] + output_buffer[i+1]) * 0.5f;
        sum += avg * avg;
    }
    rms = sqrtf(sum / frames_per_buffer);
    engine->output_level_.store(rms);
    
    // Call level callback if set
    if (engine->level_callback_) {
        engine->level_callback_(engine->input_level_.load(), engine->output_level_.load());
    }
    
    return paContinue;
}
