#!/bin/bash
# Fix Arduino IDE ESP32 Platform Installation via Git

echo "=== Arduino IDE ESP32 Installation Fix ==="
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "ERROR: Git is not installed!"
    echo "Install it with: sudo apt-get install git"
    exit 1
fi

# Check if python3 is installed
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python3 is not installed!"
    echo "Install it with: sudo apt-get install python3"
    exit 1
fi

# Determine Arduino packages directory
ARDUINO_DIR="$HOME/.arduino15/packages"
ESP32_DIR="$ARDUINO_DIR/esp32/hardware/esp32"

echo "Arduino packages directory: $ARDUINO_DIR"
echo "ESP32 installation directory: $ESP32_DIR"
echo ""

# Create directory structure
echo "Creating directory structure..."
mkdir -p "$ESP32_DIR"
cd "$ESP32_DIR" || exit 1

# Check if already installed
if [ -d ".git" ]; then
    echo "ESP32 platform already exists. Updating..."
    git pull
    git submodule update --init --recursive
else
    echo "Cloning ESP32 Arduino repository..."
    echo "This may take a few minutes..."
    git clone https://github.com/espressif/arduino-esp32.git .
    
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to clone repository"
        exit 1
    fi
    
    echo "Checking out stable version 3.3.5..."
    git checkout 3.3.5
    
    if [ $? -ne 0 ]; then
        echo "Warning: Could not checkout 3.3.5, using latest version"
    fi
    
    echo "Initializing submodules..."
    git submodule update --init --recursive
fi

echo ""
echo "Installing ESP32 tools..."
cd tools || exit 1

if [ -f "get.py" ]; then
    python3 get.py
    if [ $? -ne 0 ]; then
        echo "Warning: Tools installation had issues, but continuing..."
    fi
else
    echo "Warning: get.py not found, tools may need manual installation"
fi

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Next steps:"
echo "1. Close and restart Arduino IDE"
echo "2. Go to Tools → Board → ESP32 Dev Module"
echo "3. Select your ESP32 port: Tools → Port"
echo "4. Open firmware_test/firmware_test.ino"
echo "5. Click Upload"
echo ""
echo "If ESP32 boards don't appear, try:"
echo "  - Restart Arduino IDE"
echo "  - Check: $ESP32_DIR exists and has files"
echo "  - Verify tools are installed in: $ESP32_DIR/tools"


