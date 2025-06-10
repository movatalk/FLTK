#pragma once

#include <FL/Fl_Double_Window.H>
#include <memory>

class AudioEngine;

class MainWindow : public Fl_Double_Window {
public:
    MainWindow(const char* title, int width, int height, AudioEngine* audio_engine);
    virtual ~MainWindow();

    void update_audio_levels(float input_level, float output_level);

private:
    class Impl;
    std::unique_ptr<Impl> pImpl;
};
