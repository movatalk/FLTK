#pragma once

#include <FL/Fl_Group.H>
#include <memory>

class AudioEngine;

class AudioControls : public Fl_Group {
public:
    AudioControls(int x, int y, int w, int h, AudioEngine* audio_engine);
    virtual ~AudioControls();

private:
    class Impl;
    std::unique_ptr<Impl> pImpl;
};
