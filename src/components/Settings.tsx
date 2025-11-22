import { useState } from 'react';
import { ArrowLeft, User, Bell, Zap, Code, Bluetooth, Activity, Battery, Radio, Terminal, Info } from 'lucide-react';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Input } from './ui/input';
import { Switch } from './ui/switch';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { Slider } from './ui/slider';

interface SettingsProps {
  onBack: () => void;
}

export function Settings({ onBack }: SettingsProps) {
  const [developerMode, setDeveloperMode] = useState(false);
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);
  const [hapticFeedback, setHapticFeedback] = useState(true);
  const [aiModelMode, setAiModelMode] = useState<'on-device' | 'cloud'>('on-device');
  const [colorBlindMode, setColorBlindMode] = useState(false);
  const [samplingRate, setSamplingRate] = useState([50]);

  // Mock developer data
  const [bleData] = useState({
    rssi: -48,
    mtu: 512,
    lastPacket: '12ms ago',
    packetsPerSec: 50,
    battery: 87,
    firmware: 'v1.2.3',
    connectionState: 'connected',
  });

  const [packetLog] = useState([
    { time: '14:32:45.123', type: 'PRESSURE', data: '0x4A 0x3F 0x52 0x41', size: 8 },
    { time: '14:32:45.103', type: 'IMU', data: '0x12 0x34 0x56 0x78', size: 12 },
    { time: '14:32:45.083', type: 'PRESSURE', data: '0x4B 0x40 0x53 0x42', size: 8 },
    { time: '14:32:45.063', type: 'IMU', data: '0x13 0x35 0x57 0x79', size: 12 },
    { time: '14:32:45.043', type: 'BATTERY', data: '0x57', size: 1 },
  ]);

  return (
    <div className="min-h-screen max-w-md mx-auto p-6 pb-24">
      <div className="flex items-center gap-4 mb-6">
        <Button variant="ghost" size="icon" onClick={onBack} className="text-slate-400">
          <ArrowLeft className="w-5 h-5" />
        </Button>
        <h1 className="text-white">Settings</h1>
      </div>

      <Tabs defaultValue="profile" className="mb-6">
        <TabsList className="grid w-full grid-cols-3 mb-6">
          <TabsTrigger value="profile">Profile</TabsTrigger>
          <TabsTrigger value="app">App</TabsTrigger>
          <TabsTrigger value="developer">
            <Code className="w-4 h-4" />
          </TabsTrigger>
        </TabsList>

        {/* Profile Tab */}
        <TabsContent value="profile" className="space-y-4">
          <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50">
            <div className="flex items-center gap-4 mb-6">
              <div className="w-16 h-16 rounded-full bg-gradient-to-br from-cyan-500 to-purple-600 flex items-center justify-center">
                <User className="w-8 h-8 text-white" />
              </div>
              <div className="flex-1">
                <p className="text-white">Alex Thompson</p>
                <p className="text-slate-400">alex@example.com</p>
              </div>
            </div>

            <div className="space-y-4">
              <div>
                <label className="text-slate-400 mb-2 block">Weight (lbs)</label>
                <Input
                  type="number"
                  defaultValue="185"
                  className="bg-slate-900/50 border-slate-600"
                />
              </div>
              <div>
                <label className="text-slate-400 mb-2 block">Height (inches)</label>
                <Input
                  type="number"
                  defaultValue="70"
                  className="bg-slate-900/50 border-slate-600"
                />
              </div>
              <div>
                <label className="text-slate-400 mb-2 block">Shoe Size (US)</label>
                <Input
                  type="number"
                  defaultValue="10.5"
                  className="bg-slate-900/50 border-slate-600"
                />
              </div>
              <div>
                <label className="text-slate-400 mb-2 block">Dominant Foot</label>
                <div className="grid grid-cols-2 gap-3">
                  <button className="p-3 rounded-lg border border-cyan-500 bg-cyan-500/20 text-cyan-400">
                    Left
                  </button>
                  <button className="p-3 rounded-lg border border-slate-700/50 bg-slate-800/40 text-slate-400">
                    Right
                  </button>
                </div>
              </div>
            </div>
          </div>

          <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50">
            <p className="text-slate-200 mb-4">Gait Baseline</p>
            <div className="grid grid-cols-2 gap-3">
              <div className="p-3 bg-slate-900/50 rounded-lg">
                <p className="text-slate-400 mb-1">Stride Length</p>
                <p className="text-cyan-400">28.5 in</p>
              </div>
              <div className="p-3 bg-slate-900/50 rounded-lg">
                <p className="text-slate-400 mb-1">Cadence</p>
                <p className="text-purple-400">165 spm</p>
              </div>
            </div>
            <Button
              variant="outline"
              className="w-full mt-4 border-slate-600 text-slate-300"
            >
              Recalibrate Gait
            </Button>
          </div>
        </TabsContent>

        {/* App Settings Tab */}
        <TabsContent value="app" className="space-y-4">
          <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50">
            <div className="flex items-center gap-3 mb-4">
              <Bell className="w-5 h-5 text-cyan-400" />
              <p className="text-slate-200">Notifications</p>
            </div>
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-slate-200">Push Notifications</p>
                  <p className="text-slate-400">Goal alerts & warnings</p>
                </div>
                <Switch
                  checked={notificationsEnabled}
                  onCheckedChange={setNotificationsEnabled}
                />
              </div>
              {notificationsEnabled && (
                <>
                  <div className="flex items-center justify-between pl-4 border-l-2 border-slate-700">
                    <p className="text-slate-300">Goal achievements</p>
                    <Switch defaultChecked />
                  </div>
                  <div className="flex items-center justify-between pl-4 border-l-2 border-slate-700">
                    <p className="text-slate-300">Low battery alerts</p>
                    <Switch defaultChecked />
                  </div>
                  <div className="flex items-center justify-between pl-4 border-l-2 border-slate-700">
                    <p className="text-slate-300">Pressure warnings</p>
                    <Switch defaultChecked />
                  </div>
                </>
              )}
            </div>
          </div>

          <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50">
            <div className="flex items-center gap-3 mb-4">
              <Zap className="w-5 h-5 text-purple-400" />
              <p className="text-slate-200">Haptic Feedback</p>
            </div>
            <div className="flex items-center justify-between">
              <p className="text-slate-300">Enable vibration alerts</p>
              <Switch checked={hapticFeedback} onCheckedChange={setHapticFeedback} />
            </div>
          </div>

          <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50">
            <div className="flex items-center gap-3 mb-4">
              <Activity className="w-5 h-5 text-pink-400" />
              <p className="text-slate-200">AI Model</p>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <button
                onClick={() => setAiModelMode('on-device')}
                className={`p-4 rounded-lg border transition-all ${
                  aiModelMode === 'on-device'
                    ? 'bg-cyan-500/20 border-cyan-500 text-cyan-400'
                    : 'bg-slate-800/40 border-slate-700/50 text-slate-400'
                }`}
              >
                <p>On-Device</p>
                <p className="text-sm opacity-80">Faster, private</p>
              </button>
              <button
                onClick={() => setAiModelMode('cloud')}
                className={`p-4 rounded-lg border transition-all ${
                  aiModelMode === 'cloud'
                    ? 'bg-purple-500/20 border-purple-500 text-purple-400'
                    : 'bg-slate-800/40 border-slate-700/50 text-slate-400'
                }`}
              >
                <p>Cloud</p>
                <p className="text-sm opacity-80">More accurate</p>
              </button>
            </div>
          </div>

          <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50">
            <div className="flex items-center justify-between mb-4">
              <div>
                <p className="text-slate-200">Color Blind Mode</p>
                <p className="text-slate-400">Use patterns + numbers</p>
              </div>
              <Switch checked={colorBlindMode} onCheckedChange={setColorBlindMode} />
            </div>
          </div>
        </TabsContent>

        {/* Developer Tab */}
        <TabsContent value="developer" className="space-y-4">
          <div className="p-4 bg-gradient-to-r from-amber-500/10 to-orange-500/10 rounded-xl border border-amber-500/30 mb-4">
            <div className="flex items-start gap-3">
              <Info className="w-5 h-5 text-amber-400 mt-0.5" />
              <div>
                <p className="text-amber-400 mb-1">Developer Mode</p>
                <p className="text-slate-400">Advanced debugging & BLE packet inspection</p>
              </div>
            </div>
          </div>

          <div className="flex items-center justify-between p-4 bg-slate-800/40 rounded-lg border border-slate-700/50">
            <div className="flex items-center gap-2">
              <Code className="w-5 h-5 text-cyan-400" />
              <p className="text-slate-200">Enable Developer Mode</p>
            </div>
            <Switch checked={developerMode} onCheckedChange={setDeveloperMode} />
          </div>

          {developerMode && (
            <>
              {/* BLE Connection Stats */}
              <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50">
                <div className="flex items-center gap-2 mb-4">
                  <Bluetooth className="w-5 h-5 text-blue-400" />
                  <p className="text-slate-200">BLE Connection Stats</p>
                  <Badge variant="outline" className="ml-auto bg-green-500/10 text-green-400 border-green-500/50">
                    {bleData.connectionState}
                  </Badge>
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div className="p-3 bg-slate-900/50 rounded-lg">
                    <div className="flex items-center gap-2 mb-1">
                      <Radio className="w-4 h-4 text-slate-400" />
                      <p className="text-slate-400">RSSI</p>
                    </div>
                    <p className="text-cyan-400">{bleData.rssi} dBm</p>
                  </div>
                  <div className="p-3 bg-slate-900/50 rounded-lg">
                    <p className="text-slate-400 mb-1">MTU Size</p>
                    <p className="text-purple-400">{bleData.mtu} bytes</p>
                  </div>
                  <div className="p-3 bg-slate-900/50 rounded-lg">
                    <p className="text-slate-400 mb-1">Packet Rate</p>
                    <p className="text-pink-400">{bleData.packetsPerSec} Hz</p>
                  </div>
                  <div className="p-3 bg-slate-900/50 rounded-lg">
                    <p className="text-slate-400 mb-1">Last Packet</p>
                    <p className="text-green-400">{bleData.lastPacket}</p>
                  </div>
                  <div className="p-3 bg-slate-900/50 rounded-lg">
                    <div className="flex items-center gap-2 mb-1">
                      <Battery className="w-4 h-4 text-slate-400" />
                      <p className="text-slate-400">Battery</p>
                    </div>
                    <p className="text-green-400">{bleData.battery}%</p>
                  </div>
                  <div className="p-3 bg-slate-900/50 rounded-lg">
                    <p className="text-slate-400 mb-1">Firmware</p>
                    <p className="text-blue-400">{bleData.firmware}</p>
                  </div>
                </div>
              </div>

              {/* GATT Characteristics */}
              <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50">
                <p className="text-slate-200 mb-4">GATT Characteristics</p>
                <div className="space-y-2 font-mono text-sm">
                  <div className="p-3 bg-slate-900/50 rounded-lg">
                    <p className="text-cyan-400 mb-1">InsoleService</p>
                    <p className="text-slate-400">UUID: 0000180F-0000-1000-8000-00805f9b34fb</p>
                  </div>
                  <div className="p-3 bg-slate-900/50 rounded-lg pl-6 border-l-2 border-cyan-500/50">
                    <p className="text-purple-400 mb-1">PressureData</p>
                    <p className="text-slate-400">4 × uint16 (Heel, Arch, Ball, Toes)</p>
                  </div>
                  <div className="p-3 bg-slate-900/50 rounded-lg pl-6 border-l-2 border-cyan-500/50">
                    <p className="text-purple-400 mb-1">IMUData</p>
                    <p className="text-slate-400">Quaternions / Euler angles</p>
                  </div>
                  <div className="p-3 bg-slate-900/50 rounded-lg pl-6 border-l-2 border-cyan-500/50">
                    <p className="text-purple-400 mb-1">Battery</p>
                    <p className="text-slate-400">uint8 (0-100%)</p>
                  </div>
                  <div className="p-3 bg-slate-900/50 rounded-lg pl-6 border-l-2 border-cyan-500/50">
                    <p className="text-purple-400 mb-1">Command</p>
                    <p className="text-slate-400">Calibrate / Haptic control</p>
                  </div>
                </div>
              </div>

              {/* Sampling Rate Control */}
              <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50">
                <p className="text-slate-200 mb-4">Sampling Rate</p>
                <div className="flex items-center justify-between mb-2">
                  <span className="text-slate-400">Current Rate</span>
                  <span className="text-cyan-400">{samplingRate[0]} Hz</span>
                </div>
                <Slider
                  value={samplingRate}
                  onValueChange={setSamplingRate}
                  min={20}
                  max={100}
                  step={10}
                  className="mb-2"
                />
                <div className="flex justify-between text-sm text-slate-500">
                  <span>20 Hz</span>
                  <span>100 Hz</span>
                </div>
                <p className="text-slate-400 mt-3">
                  Higher rates = more accurate, lower battery life
                </p>
              </div>

              {/* Live Packet Inspector */}
              <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50">
                <div className="flex items-center gap-2 mb-4">
                  <Terminal className="w-5 h-5 text-green-400" />
                  <p className="text-slate-200">Live Packet Inspector</p>
                  <Badge variant="outline" className="ml-auto bg-green-500/10 text-green-400 border-green-500/50">
                    Live
                  </Badge>
                </div>
                <div className="bg-slate-950 rounded-lg p-4 font-mono text-xs space-y-1 max-h-64 overflow-y-auto">
                  {packetLog.map((packet, i) => (
                    <div key={i} className="text-green-400">
                      <span className="text-slate-500">[{packet.time}]</span>{' '}
                      <span className="text-cyan-400">{packet.type}</span>:{' '}
                      <span className="text-slate-300">{packet.data}</span>{' '}
                      <span className="text-slate-500">({packet.size}B)</span>
                    </div>
                  ))}
                </div>
              </div>

              {/* Developer Actions */}
              <div className="grid grid-cols-2 gap-3">
                <Button variant="outline" className="border-slate-600 text-slate-300">
                  Export Logs
                </Button>
                <Button variant="outline" className="border-slate-600 text-slate-300">
                  Firmware Update
                </Button>
              </div>

              {/* Power Mode Settings */}
              <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50">
                <p className="text-slate-200 mb-4">Power Modes</p>
                <div className="space-y-3">
                  <button className="w-full p-3 rounded-lg border border-cyan-500 bg-cyan-500/20 text-left">
                    <p className="text-cyan-400">Low Power (20 Hz)</p>
                    <p className="text-slate-400 text-sm">Battery: ~48 hours</p>
                  </button>
                  <button className="w-full p-3 rounded-lg border border-slate-700/50 bg-slate-800/40 text-left">
                    <p className="text-slate-300">Balanced (50 Hz)</p>
                    <p className="text-slate-400 text-sm">Battery: ~24 hours</p>
                  </button>
                  <button className="w-full p-3 rounded-lg border border-slate-700/50 bg-slate-800/40 text-left">
                    <p className="text-slate-300">High Fidelity (100 Hz)</p>
                    <p className="text-slate-400 text-sm">Battery: ~12 hours</p>
                  </button>
                </div>
              </div>

              {/* IMU Calibration Details */}
              <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50">
                <p className="text-slate-200 mb-4">IMU Calibration</p>
                <div className="space-y-3">
                  <div className="flex justify-between">
                    <span className="text-slate-400">Accelerometer Offset</span>
                    <span className="text-cyan-400">0.02 g</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-slate-400">Gyroscope Drift</span>
                    <span className="text-purple-400">0.5 °/s</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-slate-400">Magnetometer Calibration</span>
                    <Badge variant="outline" className="bg-green-500/10 text-green-400 border-green-500/50">
                      Good
                    </Badge>
                  </div>
                  <Button
                    variant="outline"
                    className="w-full border-slate-600 text-slate-300 mt-3"
                  >
                    Recalibrate IMU
                  </Button>
                </div>
              </div>

              {/* Battery Graph */}
              <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50">
                <p className="text-slate-200 mb-4">Battery History (24h)</p>
                <div className="h-24 bg-slate-900/50 rounded-lg p-3 flex items-end gap-1">
                  {Array.from({ length: 24 }).map((_, i) => {
                    const height = 100 - i * 0.5 - Math.random() * 2;
                    return (
                      <div
                        key={i}
                        className="flex-1 bg-gradient-to-t from-green-500 to-green-400 rounded-sm"
                        style={{ height: `${height}%` }}
                      />
                    );
                  })}
                </div>
              </div>
            </>
          )}
        </TabsContent>
      </Tabs>
    </div>
  );
}
