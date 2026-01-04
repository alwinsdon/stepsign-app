# Simple ESP32 Installation Fix for Arduino IDE

## Quick Fix (2 steps)

### Step 1: Increase Timeout
1. **Close Arduino IDE completely**
2. Run this command:
   ```bash
   echo "network.timeout=600" >> ~/.arduino15/preferences.txt
   ```
3. **Restart Arduino IDE**

### Step 2: Try Installing "Arduino ESP32 Boards" Instead

Instead of "esp32 by Espressif Systems", try:

1. In Arduino IDE, go to **Tools → Board → Boards Manager**
2. Search for **"Arduino ESP32"**
3. Install **"Arduino ESP32 Boards by Arduino"** (version 2.0.18)
   - This package is usually smaller and downloads faster
   - It works with your firmware code

### Step 3: Select Board
After installation:
1. **Tools → Board → Arduino ESP32 Boards → ESP32 Dev Module**
2. **Tools → Port → (select your ESP32)**
3. Upload your sketch!

## That's it! 

Your firmware code will work with either ESP32 package. The "Arduino ESP32 Boards" is often easier to install.


