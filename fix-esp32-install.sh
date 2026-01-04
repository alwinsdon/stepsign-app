#!/bin/bash
# Fix ESP32 Platform Installation Timeout

echo "=== ESP32 Platform Installation Fix ==="
echo ""

# Increase timeout settings
export PLATFORMIO_CORE_TIMEOUT=600
export PLATFORMIO_HTTP_TIMEOUT=600

echo "Timeout settings increased:"
echo "  PLATFORMIO_CORE_TIMEOUT=$PLATFORMIO_CORE_TIMEOUT"
echo "  PLATFORMIO_HTTP_TIMEOUT=$PLATFORMIO_HTTP_TIMEOUT"
echo ""

# Check if PlatformIO is installed
if ! command -v pio &> /dev/null; then
    echo "ERROR: PlatformIO CLI not found!"
    echo "Install it with: pip install platformio"
    exit 1
fi

echo "Attempting to install ESP32 platform..."
echo "This may take several minutes due to large package size..."
echo ""

# Try to install with increased timeout
pio platform install espressif32

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ ESP32 platform installed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Create platformio.ini in your project root"
    echo "2. Add the configuration from ESP32_INSTALL_FIX.md"
    echo "3. Run: pio run -t upload"
else
    echo ""
    echo "✗ Installation failed. Try the alternative solutions in ESP32_INSTALL_FIX.md"
    exit 1
fi


