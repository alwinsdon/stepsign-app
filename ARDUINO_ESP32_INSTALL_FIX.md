# Arduino IDE - ESP32 Platform Installation Timeout Fix

## Problem
Arduino IDE is timing out when downloading ESP32 platform packages:
```
Failed to install platform: 'esp32:esp32:3.3.5'.
Error: 4 DEADLINE_EXCEEDED: net/http: request canceled
```

## Solutions (Try in order)

### Solution 1: Increase Arduino IDE Timeout (Recommended)

1. **Close Arduino IDE completely**

2. **Edit Arduino preferences file:**
   - Linux: `~/.arduino15/preferences.txt`
   - Windows: `%APPDATA%\Arduino15\preferences.txt`
   - macOS: `~/Library/Arduino15/preferences.txt`

3. **Add or modify these lines:**
   ```
   network.timeout=600
   ```

4. **Restart Arduino IDE** and try installing ESP32 again

### Solution 2: Manual Installation via Git (Most Reliable)

This bypasses the slow download:

1. **Open Terminal/Command Prompt**

2. **Navigate to Arduino packages directory:**
   ```bash
   cd ~/.arduino15/packages
   ```

3. **Create esp32 directory:**
   ```bash
   mkdir -p esp32/hardware/esp32
   cd esp32/hardware/esp32
   ```

4. **Clone the ESP32 Arduino repository:**
   ```bash
   git clone https://github.com/espressif/arduino-esp32.git .
   ```

5. **Checkout the stable version (3.3.5):**
   ```bash
   git checkout 3.3.5
   git submodule update --init --recursive
   ```

6. **Install tools manually:**
   ```bash
   cd tools
   python3 get.py
   ```

7. **Restart Arduino IDE** - ESP32 boards should now appear

### Solution 3: Use Alternative Board Manager URL

1. **Open Arduino IDE**
2. **Go to File → Preferences**
3. **In "Additional Boards Manager URLs", add:**
   ```
   https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
   ```
4. **Go to Tools → Board → Boards Manager**
5. **Search for "esp32"**
6. **Install "esp32 by Espressif Systems"**

### Solution 4: Download and Install Manually

1. **Download ESP32 package manually:**
   - Visit: https://github.com/espressif/arduino-esp32/releases
   - Download the latest release ZIP file

2. **Extract to:**
   - Linux: `~/.arduino15/packages/esp32/hardware/esp32/`
   - Windows: `%LOCALAPPDATA%\Arduino15\packages\esp32\hardware\esp32\`
   - macOS: `~/Library/Arduino15/packages/esp32/hardware/esp32/`

3. **Install tools:**
   ```bash
   cd ~/.arduino15/packages/esp32/hardware/esp32/tools
   python3 get.py
   ```

### Solution 5: Check Network/Firewall

- Ensure firewall isn't blocking Arduino IDE
- Try using a VPN if your network restricts certain domains
- Check if you can access: https://raw.githubusercontent.com

## Quick Fix Script (Linux/Mac)

I've created `fix-arduino-esp32.sh` - run it to automatically install ESP32 via git method.

## After Installation

1. **Select Board:** Tools → Board → ESP32 Dev Module
2. **Select Port:** Tools → Port → (your ESP32 COM port)
3. **Open your sketch:** `firmware_test/firmware_test.ino`
4. **Upload:** Click the Upload button

## Verify Installation

After installation, you should see:
- **Tools → Board** shows "ESP32 Dev Module" and other ESP32 boards
- **Tools → Port** shows your ESP32 device when connected


