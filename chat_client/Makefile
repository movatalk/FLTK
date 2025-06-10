CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -O2
INCLUDEDIRS = -Iinclude -I/usr/include
LIBDIRS = -L/usr/lib
LIBS = -lfltk -lfltk_images -lportaudio -lpthread

# Platform-specific optimizations
ifeq ($(shell uname -m),aarch64)
    CXXFLAGS += -march=armv8-a -mtune=cortex-a72 -O3 -funroll-loops -ffast-math
    CXXFLAGS += -DARM64_NEON_OPTIMIZED
endif

# Sources and objects
SRC_DIR = src
OBJ_DIR = obj
BIN_DIR = bin

SOURCES = $(shell find $(SRC_DIR) -name '*.cpp')
OBJECTS = $(patsubst $(SRC_DIR)/%.cpp,$(OBJ_DIR)/%.o,$(SOURCES))
DEPS = $(OBJECTS:.o=.d)

TARGET = $(BIN_DIR)/chat_client

# Ensure directories exist
DIRS = $(OBJ_DIR) $(BIN_DIR) \
	$(OBJ_DIR)/core $(OBJ_DIR)/audio $(OBJ_DIR)/gui \
	$(OBJ_DIR)/network $(OBJ_DIR)/utils

# Default target
all: $(TARGET)

# Create directories
$(OBJ_DIR)/%.o: | $(DIRS)

$(DIRS):
	mkdir -p $@

# Compile
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDEDIRS) -MMD -MP -c $< -o $@

# Link
$(TARGET): $(OBJECTS)
	$(CXX) $(CXXFLAGS) -o $@ $^ $(LIBDIRS) $(LIBS)

# Clean
clean:
	rm -rf $(OBJ_DIR) $(BIN_DIR)

# Test
test: $(TARGET)
	cd tests && $(MAKE)

# Install
install: $(TARGET)
	install -d $(DESTDIR)/usr/local/bin
	install -m 755 $(TARGET) $(DESTDIR)/usr/local/bin/
	install -d $(DESTDIR)/usr/local/share/chat_client
	cp -r data/* $(DESTDIR)/usr/local/share/chat_client/

# Dependencies
-include $(DEPS)

.PHONY: all clean test install
