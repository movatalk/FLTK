#include "chat_window.h"

#include <FL/Fl.H>
#include <FL/Fl_Text_Display.H>
#include <FL/Fl_Text_Buffer.H>
#include <FL/Fl_Input.H>
#include <FL/Fl_Button.H>
#include <FL/fl_draw.H>
#include <functional>
#include <sstream>
#include <iomanip>
#include <ctime>

class ChatWindow::Impl {
public:
    Fl_Text_Display* message_display;
    Fl_Text_Buffer* message_buffer;
    Fl_Input* input_field;
    Fl_Button* send_button;
    
    std::function<void(const std::string&)> on_send_callback;
    
    static void send_cb(Fl_Widget* w, void* user_data) {
        auto* self = static_cast<Impl*>(user_data);
        std::string message = self->input_field->value();
        if (!message.empty()) {
            if (self->on_send_callback) {
                self->on_send_callback(message);
            }
            self->input_field->value("");
            self->input_field->take_focus();
        }
    }
    
    static void input_key_cb(Fl_Widget* w, void* user_data) {
        auto* self = static_cast<Impl*>(user_data);
        auto* input = static_cast<Fl_Input*>(w);
        
        if (Fl::event() == FL_KEYDOWN && Fl::event_key() == FL_Enter) {
            send_cb(w, user_data);
        }
    }
};

ChatWindow::ChatWindow(int x, int y, int w, int h)
    : Fl_Group(x, y, w, h),
      pImpl(std::make_unique<Impl>()) {
    
    begin();
    
    // Message display area
    pImpl->message_buffer = new Fl_Text_Buffer();
    pImpl->message_display = new Fl_Text_Display(x, y, w, h - 40);
    pImpl->message_display->buffer(pImpl->message_buffer);
    pImpl->message_display->wrap_mode(Fl_Text_Display::WRAP_AT_BOUNDS, 0);
    pImpl->message_display->textfont(FL_HELVETICA);
    pImpl->message_display->textsize(14);
    pImpl->message_display->textcolor(FL_BLACK);
    
    // Input field and send button
    pImpl->input_field = new Fl_Input(x, y + h - 35, w - 100, 30);
    pImpl->input_field->callback(Impl::input_key_cb, pImpl.get());
    pImpl->input_field->when(FL_WHEN_ENTER_KEY_ALWAYS);
    
    pImpl->send_button = new Fl_Button(x + w - 95, y + h - 35, 90, 30, "Send");
    pImpl->send_button->callback(Impl::send_cb, pImpl.get());
    
    end();
    
    // Add welcome message
    add_message("System", "Welcome to the Audio-Visual Chat Client!", false);
}

ChatWindow::~ChatWindow() {
    delete pImpl->message_buffer;
}

void ChatWindow::add_message(const std::string& sender, const std::string& message, bool is_self) {
    // Get current time
    auto now = std::time(nullptr);
    auto tm = *std::localtime(&now);
    std::ostringstream time_str;
    time_str << std::put_time(&tm, "[%H:%M:%S] ");
    
    // Format message
    std::string formatted_message;
    if (is_self) {
        formatted_message = time_str.str() + "You: " + message + "\n";
    } else {
        formatted_message = time_str.str() + sender + ": " + message + "\n";
    }
    
    // Add to buffer
    pImpl->message_buffer->append(formatted_message.c_str());
    
    // Scroll to end
    pImpl->message_display->scroll(
        pImpl->message_buffer->count_lines(0, pImpl->message_buffer->length()),
        0
    );
}

void ChatWindow::set_on_send_callback(std::function<void(const std::string&)> callback) {
    pImpl->on_send_callback = std::move(callback);
}
