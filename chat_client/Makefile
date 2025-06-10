CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -O2 -march=native 
LDFLAGS = -L/usr/lib -L/usr/local/lib
LIBS = -lfltk -lfltk_images -lportaudio -pthread

# Include paths
INCLUDES = -I./include -I./src -I/usr/include -I/usr/local/include

# Output directories
BINDIR = bin
OBJDIR = obj

# Create necessary directories
$(shell mkdir -p $(BINDIR) $(OBJDIR)/core $(OBJDIR)/audio $(OBJDIR)/gui $(OBJDIR)/network $(OBJDIR)/utils)

# Source files
SRCS = $(wildcard src/*.cpp src/core/*.cpp src/audio/*.cpp src/gui/*.cpp src/network/*.cpp src/utils/*.cpp)
OBJS = $(SRCS:src/%.cpp=$(OBJDIR)/%.o)

# Target executable
TARGET = $(BINDIR)/chat_client

# Main targets
.PHONY: all clean install test

all: $(TARGET)

$(TARGET): $(OBJS)
	@echo "Linking $@..."
	@$(CXX) $(CXXFLAGS) -o $@ $^ $(LDFLAGS) $(LIBS)
	@echo "Build complete: $@"

# Pattern rule for object files
$(OBJDIR)/%.o: src/%.cpp
	@echo "Compiling $<..."
	@mkdir -p $(@D)
	@$(CXX) $(CXXFLAGS) $(INCLUDES) -MMD -MP -c $< -o $@

# Include dependencies
-include $(OBJS:.o=.d)

# Install command
install: $(TARGET)
	@echo "Installing to /usr/local/bin/..."
	@install -m 755 $(TARGET) /usr/local/bin/
	@echo "Installation complete."

# Clean command
clean:
	@echo "Cleaning..."
	@rm -rf $(OBJDIR) $(BINDIR)
	@echo "Cleaned."

# Test target
test:
	@mkdir -p tests/bin
	@echo "Building tests..."
	@$(CXX) $(CXXFLAGS) $(INCLUDES) tests/unit/audio_tests.cpp -o tests/bin/audio_test $(LDFLAGS) $(LIBS)
	@$(CXX) $(CXXFLAGS) $(INCLUDES) tests/integration/full_system_test.cpp -o tests/bin/integration_test $(LDFLAGS) $(LIBS)
	@echo "Running tests..."
	@tests/bin/audio_test
	@tests/bin/integration_test
	@echo "Tests completed."

# Architecture-specific targets
.PHONY: x86_64 arm64

x86_64:
	@echo "Building for x86_64 architecture..."
	@$(MAKE) CXXFLAGS="$(CXXFLAGS) -march=x86-64-v2 -mtune=generic -DUSE_SSE2 -DUSE_AVX"

arm64:
	@echo "Building for ARM64 architecture..."
	@$(MAKE) CXXFLAGS="$(CXXFLAGS) -march=armv8-a -mtune=cortex-a72 -DARM64_NEON_OPTIMIZED"
