#pragma once

#include <FL/Fl_Group.H>
#include <memory>

class ChatWindow : public Fl_Group {
public:
    ChatWindow(int x, int y, int w, int h);
    virtual ~ChatWindow();
    
    void add_message(const std::string& sender, const std::string& message, bool is_self = false);
    void set_on_send_callback(std::function<void(const std::string&)> callback);

private:
    class Impl;
    std::unique_ptr<Impl> pImpl;
};
