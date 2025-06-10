CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -O2

# Target executable
TARGET = chat_client_mock

# Default target
all: $(TARGET)

$(TARGET): mock_main.cpp
	@echo "Building mock chat client..."
	$(CXX) $(CXXFLAGS) $< -o $@
	@echo "Build complete! Run with ./$(TARGET)"

clean:
	@echo "Cleaning..."
	rm -f $(TARGET)

run: $(TARGET)
	@echo "Running mock chat client..."
	./$(TARGET)

.PHONY: all clean run
