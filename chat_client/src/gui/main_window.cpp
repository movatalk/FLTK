#include "main_window.h"
#include "chat_window.h"
#include "audio_controls.h"
#include "../audio/audio_engine.h"

#include <FL/Fl.H>
#include <FL/Fl_Tabs.H>
#include <FL/Fl_Group.H>
#include <FL/Fl_Box.H>
#include <FL/Fl_Button.H>
#include <FL/Fl_Progress.H>
#include <FL/Fl_Choice.H>
#include <FL/fl_draw.H>

class MainWindow::Impl {
public:
    AudioEngine* audio_engine;
    Fl_Tabs* tabs;
    ChatWindow* chat_window;
    AudioControls* audio_controls;
    Fl_Progress* input_level_meter;
    Fl_Progress* output_level_meter;
    Fl_Choice* device_selector;
    Fl_Button* connect_button;
    
    static void timer_callback(void* user_data) {
        auto* window = static_cast<MainWindow*>(user_data);
        window->update_audio_levels(
            window->pImpl->audio_engine->get_input_level(),
            window->pImpl->audio_engine->get_output_level()
        );
        Fl::repeat_timeout(0.05, timer_callback, user_data); // 50ms refresh rate
    }
    
    static void device_changed_cb(Fl_Widget* w, void* user_data) {
        auto* self = static_cast<Impl*>(user_data);
        int device_id = self->device_selector->value();
        self->audio_engine->open_device(device_id);
    }
    
    static void connect_clicked_cb(Fl_Widget* w, void* user_data) {
        auto* self = static_cast<Impl*>(user_data);
        auto* button = static_cast<Fl_Button*>(w);
        
        if (std::string(button->label()) == "Connect") {
            self->audio_engine->start_stream();
            button->label("Disconnect");
        } else {
            self->audio_engine->stop_stream();
            button->label("Connect");
        }
    }
};

MainWindow::MainWindow(const char* title, int width, int height, AudioEngine* audio_engine)
    : Fl_Double_Window(width, height, title),
      pImpl(std::make_unique<Impl>()) {
    
    pImpl->audio_engine = audio_engine;
    
    begin();
    
    // Create tabs layout
    pImpl->tabs = new Fl_Tabs(10, 10, width-20, height-20);
    pImpl->tabs->begin();
    
    // Chat tab
    Fl_Group* chat_group = new Fl_Group(10, 35, width-20, height-45, "Chat");
    chat_group->begin();
    pImpl->chat_window = new ChatWindow(15, 40, width-30, height-100);
    chat_group->end();
    
    // Audio tab
    Fl_Group* audio_group = new Fl_Group(10, 35, width-20, height-45, "Audio");
    audio_group->begin();
    
    // Audio device selector
    new Fl_Box(20, 45, 120, 25, "Audio Device:");
    pImpl->device_selector = new Fl_Choice(150, 45, width-180, 25);
    pImpl->device_selector->callback(Impl::device_changed_cb, pImpl.get());
    
    // Connect button
    pImpl->connect_button = new Fl_Button(20, 80, 120, 30, "Connect");
    pImpl->connect_button->callback(Impl::connect_clicked_cb, pImpl.get());
    
    // Audio level meters
    new Fl_Box(20, 120, 100, 25, "Input Level:");
    pImpl->input_level_meter = new Fl_Progress(130, 120, width-160, 25);
    pImpl->input_level_meter->minimum(0.0);
    pImpl->input_level_meter->maximum(1.0);
    pImpl->input_level_meter->color(FL_BACKGROUND_COLOR);
    pImpl->input_level_meter->selection_color(FL_GREEN);
    
    new Fl_Box(20, 155, 100, 25, "Output Level:");
    pImpl->output_level_meter = new Fl_Progress(130, 155, width-160, 25);
    pImpl->output_level_meter->minimum(0.0);
    pImpl->output_level_meter->maximum(1.0);
    pImpl->output_level_meter->color(FL_BACKGROUND_COLOR);
    pImpl->output_level_meter->selection_color(FL_BLUE);
    
    // Audio controls
    pImpl->audio_controls = new AudioControls(20, 190, width-40, height-230, audio_engine);
    
    audio_group->end();
    
    // Settings tab
    Fl_Group* settings_group = new Fl_Group(10, 35, width-20, height-45, "Settings");
    settings_group->begin();
    new Fl_Box(width/2-100, height/2-15, 200, 30, "Settings Panel (To Be Implemented)");
    settings_group->end();
    
    pImpl->tabs->end();
    end();
    
    // Populate device list
    auto devices = audio_engine->get_devices();
    for (const auto& device : devices) {
        if (device.max_input_channels > 0 && device.max_output_channels > 0) {
            pImpl->device_selector->add(device.name.c_str(), 0, nullptr, &device.id, 0);
            if (device.is_default) {
                pImpl->device_selector->value(pImpl->device_selector->size() - 1);
            }
        }
    }
    
    // Set callbacks
    audio_engine->set_level_callback([this](float input, float output) {
        update_audio_levels(input, output);
    });
    
    // Start UI update timer
    Fl::add_timeout(0.05, Impl::timer_callback, this);
    
    // Try to open default audio device
    if (!devices.empty()) {
        int default_device_id = 0;
        for (const auto& device : devices) {
            if (device.is_default && device.max_input_channels > 0 && device.max_output_channels > 0) {
                default_device_id = device.id;
                break;
            }
        }
        audio_engine->open_device(default_device_id);
    }
}

MainWindow::~MainWindow() {
    Fl::remove_timeout(Impl::timer_callback, this);
}

void MainWindow::update_audio_levels(float input_level, float output_level) {
    // Scale levels for better visualization (logarithmic scaling)
    constexpr float scale_factor = 5.0f;
    float input_scaled = std::min(1.0f, input_level * scale_factor);
    float output_scaled = std::min(1.0f, output_level * scale_factor);
    
    pImpl->input_level_meter->value(input_scaled);
    pImpl->output_level_meter->value(output_scaled);
    
    // Change color based on level
    if (input_scaled > 0.8f) {
        pImpl->input_level_meter->selection_color(FL_RED);
    } else {
        pImpl->input_level_meter->selection_color(FL_GREEN);
    }
    
    if (output_scaled > 0.8f) {
        pImpl->output_level_meter->selection_color(FL_RED);
    } else {
        pImpl->output_level_meter->selection_color(FL_BLUE);
    }
    
    pImpl->input_level_meter->redraw();
    pImpl->output_level_meter->redraw();
}
