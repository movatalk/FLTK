#include "audio_controls.h"
#include "../audio/audio_engine.h"

#include <FL/Fl.H>
#include <FL/Fl_Box.H>
#include <FL/Fl_Value_Slider.H>
#include <FL/Fl_Check_Button.H>
#include <FL/Fl_Round_Button.H>
#include <FL/Fl_Group.H>

class AudioControls::Impl {
public:
    AudioEngine* audio_engine;
    Fl_Value_Slider* volume_slider;
    Fl_Value_Slider* gain_slider;
    Fl_Check_Button* mute_input_checkbox;
    Fl_Check_Button* mute_output_checkbox;
    Fl_Round_Button* echo_cancellation_checkbox;
    
    float output_volume = 1.0f;
    float input_gain = 1.0f;
    bool mute_input = false;
    bool mute_output = false;
    bool echo_cancellation = false;
    
    static void volume_changed_cb(Fl_Widget* w, void* user_data) {
        auto* self = static_cast<Impl*>(user_data);
        auto* slider = static_cast<Fl_Value_Slider*>(w);
        self->output_volume = static_cast<float>(slider->value());
    }
    
    static void gain_changed_cb(Fl_Widget* w, void* user_data) {
        auto* self = static_cast<Impl*>(user_data);
        auto* slider = static_cast<Fl_Value_Slider*>(w);
        self->input_gain = static_cast<float>(slider->value());
    }
    
    static void mute_input_cb(Fl_Widget* w, void* user_data) {
        auto* self = static_cast<Impl*>(user_data);
        auto* checkbox = static_cast<Fl_Check_Button*>(w);
        self->mute_input = checkbox->value() == 1;
    }
    
    static void mute_output_cb(Fl_Widget* w, void* user_data) {
        auto* self = static_cast<Impl*>(user_data);
        auto* checkbox = static_cast<Fl_Check_Button*>(w);
        self->mute_output = checkbox->value() == 1;
    }
    
    static void echo_cancellation_cb(Fl_Widget* w, void* user_data) {
        auto* self = static_cast<Impl*>(user_data);
        auto* checkbox = static_cast<Fl_Check_Button*>(w);
        self->echo_cancellation = checkbox->value() == 1;
    }
};

AudioControls::AudioControls(int x, int y, int w, int h, AudioEngine* audio_engine)
    : Fl_Group(x, y, w, h),
      pImpl(std::make_unique<Impl>()) {
    
    pImpl->audio_engine = audio_engine;
    
    begin();
    
    // Volume control
    new Fl_Box(x, y, 100, 25, "Output Volume:");
    pImpl->volume_slider = new Fl_Value_Slider(x + 120, y, w - 140, 25);
    pImpl->volume_slider->type(FL_HOR_NICE_SLIDER);
    pImpl->volume_slider->minimum(0.0);
    pImpl->volume_slider->maximum(1.0);
    pImpl->volume_slider->step(0.01);
    pImpl->volume_slider->value(1.0);
    pImpl->volume_slider->callback(Impl::volume_changed_cb, pImpl.get());
    
    // Input gain
    new Fl_Box(x, y + 35, 100, 25, "Input Gain:");
    pImpl->gain_slider = new Fl_Value_Slider(x + 120, y + 35, w - 140, 25);
    pImpl->gain_slider->type(FL_HOR_NICE_SLIDER);
    pImpl->gain_slider->minimum(0.0);
    pImpl->gain_slider->maximum(2.0);
    pImpl->gain_slider->step(0.01);
    pImpl->gain_slider->value(1.0);
    pImpl->gain_slider->callback(Impl::gain_changed_cb, pImpl.get());
    
    // Mute controls
    pImpl->mute_input_checkbox = new Fl_Check_Button(x, y + 70, 150, 25, "Mute Input");
    pImpl->mute_input_checkbox->callback(Impl::mute_input_cb, pImpl.get());
    
    pImpl->mute_output_checkbox = new Fl_Check_Button(x + 200, y + 70, 150, 25, "Mute Output");
    pImpl->mute_output_checkbox->callback(Impl::mute_output_cb, pImpl.get());
    
    // Audio processing options
    Fl_Group* processing_group = new Fl_Group(x, y + 105, w, 100, "Audio Processing");
    processing_group->box(FL_ENGRAVED_FRAME);
    processing_group->align(FL_ALIGN_TOP_LEFT);
    processing_group->begin();
    
    pImpl->echo_cancellation_checkbox = new Fl_Check_Button(x + 10, y + 130, 200, 25, "Echo Cancellation");
    pImpl->echo_cancellation_checkbox->callback(Impl::echo_cancellation_cb, pImpl.get());
    
    new Fl_Check_Button(x + 10, y + 160, 200, 25, "Noise Suppression");
    new Fl_Check_Button(x + 200, y + 130, 200, 25, "Auto Gain Control");
    new Fl_Check_Button(x + 200, y + 160, 200, 25, "Voice Activity Detection");
    
    processing_group->end();
    
    end();
    
    // Set audio callback that applies these settings
    audio_engine->set_audio_callback([this](const float* input, float* output, unsigned int frames) {
        bool mute_in = pImpl->mute_input;
        bool mute_out = pImpl->mute_output;
        float gain = pImpl->input_gain;
        float volume = pImpl->output_volume;
        
        for (unsigned int i = 0; i < frames; ++i) {
            // Process input with gain and mute
            float in_sample = mute_in ? 0.0f : input[i] * gain;
            
            // Simple passthrough to both channels with volume control
            output[i*2] = output[i*2+1] = mute_out ? 0.0f : in_sample * volume;
        }
    });
}

AudioControls::~AudioControls() = default;
