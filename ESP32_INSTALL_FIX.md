# ESP32 Platform Installation Timeout Fix

## Problem
The ESP32 platform installation is timing out when downloading packages:
```
Error: 4 DEADLINE_EXCEEDED: net/http: request canceled (Client.Timeout or context cancellation while reading body)
```

## Solutions (Try in order)

### Solution 1: Increase Timeout Settings (Recommended)

If using PlatformIO, create or update `platformio.ini` with increased timeout:

```ini
[env:esp32dev]
platform = espressif32
board = esp32dev
framework = arduino
monitor_speed = 115200

[platformio]
default_envs = esp32dev
```

Then set environment variable before installing:
```bash
export PLATFORMIO_CORE_TIMEOUT=600
pio platform install espressif32
```

### Solution 2: Retry Installation

Sometimes it's just a temporary network issue. Try again:
```bash
pio platform install espressif32
```

### Solution 3: Use Alternative Package Index

Try using a different package source. Edit `~/.platformio/platforms/espressif32/platform.json` or use:
```bash
pio platform install espressif32@latest --with-package framework-arduinoespressif32
```

### Solution 4: Manual Download (If above fails)

1. Download the ESP32 platform manually from:
   https://github.com/platformio/platform-espressif32/releases

2. Extract to: `~/.platformio/platforms/espressif32/`

3. Or use git:
```bash
cd ~/.platformio/platforms/
git clone https://github.com/platformio/platform-espressif32.git espressif32
cd espressif32
```

### Solution 5: Use Arduino IDE Instead

If PlatformIO continues to have issues, use Arduino IDE:

1. Install Arduino IDE
2. Go to **File → Preferences**
3. Add to "Additional Boards Manager URLs":
   ```
   https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
   ```
4. Go to **Tools → Board → Boards Manager**
5. Search for "ESP32" and install "esp32 by Espressif Systems"

### Solution 6: Check Network/Firewall

- Ensure you're not behind a restrictive firewall
- Try using a VPN if your network blocks certain domains
- Check if you can access: https://api.registry.platformio.org

## Quick Fix Script

Run this script to increase timeout and retry:

```bash
#!/bin/bash
export PLATFORMIO_CORE_TIMEOUT=600
export PLATFORMIO_HTTP_TIMEOUT=600
pio platform install espressif32 --with-package framework-arduinoespressif32
```


