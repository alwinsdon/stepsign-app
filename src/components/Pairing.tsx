import { useState, useEffect } from 'react';
import { motion } from 'motion/react';
import { ArrowLeft, Bluetooth, Signal, Battery, Zap, CheckCircle2 } from 'lucide-react';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Slider } from './ui/slider';

interface PairingProps {
  onComplete: () => void;
  onBack: () => void;
}

type ConnectionState = 'idle' | 'scanning' | 'connecting' | 'connected' | 'calibrating' | 'synced';
type StreamMode = 'low-power' | 'high-fidelity';

interface Device {
  id: string;
  name: string;
  side: 'Left' | 'Right';
  rssi: number;
  battery: number;
  firmware: string;
  state: ConnectionState;
}

export function Pairing({ onComplete, onBack }: PairingProps) {
  const [connectionState, setConnectionState] = useState<ConnectionState>('idle');
  const [devices, setDevices] = useState<Device[]>([]);
  const [selectedDevice, setSelectedDevice] = useState<Device | null>(null);
  const [streamMode, setStreamMode] = useState<StreamMode>('low-power');
  const [calibrationStep, setCalibrationStep] = useState(0);
  const [sensorReadings, setSensorReadings] = useState([0, 0, 0, 0]);

  const startScan = () => {
    setConnectionState('scanning');
    setTimeout(() => {
      setDevices([
        {
          id: 'SS-L-001',
          name: 'StepSign Left',
          side: 'Left',
          rssi: -45,
          battery: 87,
          firmware: 'v1.2.3',
          state: 'idle',
        },
        {
          id: 'SS-R-001',
          name: 'StepSign Right',
          side: 'Right',
          rssi: -52,
          battery: 91,
          firmware: 'v1.2.3',
          state: 'idle',
        },
      ]);
      setConnectionState('idle');
    }, 2000);
  };

  const connectDevice = (device: Device) => {
    setSelectedDevice(device);
    setConnectionState('connecting');
    setTimeout(() => {
      setConnectionState('connected');
      setDevices(
        devices.map((d) =>
          d.id === device.id ? { ...d, state: 'connected' } : d
        )
      );
    }, 1500);
  };

  const startCalibration = () => {
    setConnectionState('calibrating');
    setCalibrationStep(0);
  };

  useEffect(() => {
    if (connectionState === 'calibrating' && calibrationStep < 4) {
      const interval = setInterval(() => {
        setSensorReadings((prev) => {
          const newReadings = [...prev];
          newReadings[calibrationStep] = Math.random() * 100 + 50;
          return newReadings;
        });
      }, 100);

      const timeout = setTimeout(() => {
        setCalibrationStep((prev) => prev + 1);
      }, 2000);

      return () => {
        clearInterval(interval);
        clearTimeout(timeout);
      };
    } else if (calibrationStep === 4) {
      setTimeout(() => {
        setConnectionState('synced');
      }, 1000);
    }
  }, [connectionState, calibrationStep]);

  const sensorNames = ['Heel', 'Arch', 'Ball', 'Toes'];

  return (
    <div className="min-h-screen max-w-md mx-auto p-6">
      <div className="flex items-center gap-4 mb-6">
        <Button
          variant="ghost"
          size="icon"
          onClick={onBack}
          className="text-slate-400"
        >
          <ArrowLeft className="w-5 h-5" />
        </Button>
        <h1 className="text-white">Device Pairing</h1>
      </div>

      {/* Connection state indicator */}
      <div className="mb-6 p-4 bg-slate-800/40 rounded-xl border border-slate-700/50">
        <div className="flex items-center gap-3">
          <div className="relative">
            <Bluetooth className="w-6 h-6 text-cyan-400" />
            {connectionState === 'scanning' && (
              <motion.div
                className="absolute inset-0 bg-cyan-400 rounded-full"
                animate={{ scale: [1, 1.5, 1], opacity: [0.5, 0, 0.5] }}
                transition={{ duration: 1.5, repeat: Infinity }}
              />
            )}
            {(connectionState === 'connected' || connectionState === 'calibrating' || connectionState === 'synced') && (
              <motion.div
                className="absolute -top-1 -right-1 w-3 h-3 bg-green-500 rounded-full"
                animate={{ scale: [1, 1.2, 1] }}
                transition={{ duration: 2, repeat: Infinity }}
              />
            )}
          </div>
          <div className="flex-1">
            <p className="text-slate-200">
              {connectionState === 'idle' && 'Ready to scan'}
              {connectionState === 'scanning' && 'Scanning for devices...'}
              {connectionState === 'connecting' && 'Connecting...'}
              {connectionState === 'connected' && 'Connected'}
              {connectionState === 'calibrating' && 'Calibrating sensors...'}
              {connectionState === 'synced' && 'Synced & Ready'}
            </p>
            <p className="text-slate-400">
              {connectionState === 'idle' && 'BLE Low Energy Mode'}
              {connectionState === 'scanning' && 'Searching nearby...'}
              {connectionState === 'connecting' && 'Establishing connection...'}
              {connectionState === 'connected' && 'Device ready'}
              {connectionState === 'calibrating' && `Step ${calibrationStep + 1}/4`}
              {connectionState === 'synced' && 'All sensors verified'}
            </p>
          </div>
          {connectionState === 'synced' && (
            <CheckCircle2 className="w-6 h-6 text-green-500" />
          )}
        </div>
      </div>

      {connectionState === 'idle' && devices.length === 0 && (
        <div className="space-y-4">
          <Button
            onClick={startScan}
            className="w-full bg-gradient-to-r from-cyan-500 to-purple-600 hover:from-cyan-600 hover:to-purple-700 text-white"
          >
            <Bluetooth className="w-5 h-5 mr-2" />
            Start Scanning
          </Button>
          <p className="text-slate-400 text-center">
            Make sure your insoles are powered on and nearby
          </p>
        </div>
      )}

      {connectionState === 'scanning' && (
        <div className="flex items-center justify-center py-12">
          <motion.div
            className="w-16 h-16 border-4 border-cyan-500 border-t-transparent rounded-full"
            animate={{ rotate: 360 }}
            transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
          />
        </div>
      )}

      {devices.length > 0 && connectionState === 'idle' && (
        <div className="space-y-4">
          <h2 className="text-slate-300">Available Devices</h2>
          {devices.map((device) => (
            <motion.div
              key={device.id}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              className="p-4 bg-slate-800/40 rounded-xl border border-slate-700/50 hover:bg-slate-800/60 transition-colors cursor-pointer"
              onClick={() => connectDevice(device)}
            >
              <div className="flex items-start justify-between mb-3">
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-1">
                    <p className="text-slate-200">{device.name}</p>
                    <Badge variant="outline" className="bg-cyan-500/10 text-cyan-400 border-cyan-500/50">
                      {device.side}
                    </Badge>
                  </div>
                  <p className="text-slate-400">{device.id}</p>
                </div>
              </div>
              
              <div className="grid grid-cols-3 gap-3">
                <div className="flex items-center gap-2">
                  <Signal className="w-4 h-4 text-slate-400" />
                  <div>
                    <p className="text-slate-400">{device.rssi} dBm</p>
                    <p className="text-slate-500">RSSI</p>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <Battery className="w-4 h-4 text-green-400" />
                  <div>
                    <p className="text-slate-200">{device.battery}%</p>
                    <p className="text-slate-500">Battery</p>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <Zap className="w-4 h-4 text-purple-400" />
                  <div>
                    <p className="text-slate-200">{device.firmware}</p>
                    <p className="text-slate-500">Firmware</p>
                  </div>
                </div>
              </div>
            </motion.div>
          ))}
          
          <Button
            onClick={startScan}
            variant="outline"
            className="w-full border-slate-600 text-slate-300"
          >
            Rescan
          </Button>
        </div>
      )}

      {connectionState === 'connected' && selectedDevice && (
        <div className="space-y-6">
          <div className="p-4 bg-gradient-to-r from-green-500/10 to-emerald-500/10 rounded-xl border border-green-500/30">
            <p className="text-green-400">✓ Connected — {selectedDevice.side.toLowerCase()} insole ready</p>
          </div>

          <div className="space-y-3">
            <h3 className="text-slate-300">Streaming Mode</h3>
            <div className="grid grid-cols-2 gap-3">
              <button
                onClick={() => setStreamMode('low-power')}
                className={`p-4 rounded-lg border transition-all ${
                  streamMode === 'low-power'
                    ? 'bg-cyan-500/20 border-cyan-500 text-cyan-400'
                    : 'bg-slate-800/40 border-slate-700/50 text-slate-400'
                }`}
              >
                <Zap className="w-5 h-5 mb-2 mx-auto" />
                <p>Low Power</p>
                <p className="text-slate-500">20 Hz</p>
              </button>
              <button
                onClick={() => setStreamMode('high-fidelity')}
                className={`p-4 rounded-lg border transition-all ${
                  streamMode === 'high-fidelity'
                    ? 'bg-purple-500/20 border-purple-500 text-purple-400'
                    : 'bg-slate-800/40 border-slate-700/50 text-slate-400'
                }`}
              >
                <Signal className="w-5 h-5 mb-2 mx-auto" />
                <p>High Fidelity</p>
                <p className="text-slate-500">100 Hz</p>
              </button>
            </div>
          </div>

          <Button
            onClick={startCalibration}
            className="w-full bg-gradient-to-r from-cyan-500 to-purple-600 hover:from-cyan-600 hover:to-purple-700 text-white"
          >
            Start Calibration
          </Button>
        </div>
      )}

      {connectionState === 'calibrating' && (
        <div className="space-y-6">
          <div className="p-6 bg-slate-800/40 rounded-xl border border-slate-700/50">
            <p className="text-slate-300 mb-4">Press each region when prompted:</p>
            <div className="space-y-3">
              {sensorNames.map((name, idx) => (
                <div
                  key={name}
                  className={`p-3 rounded-lg border transition-all ${
                    idx < calibrationStep
                      ? 'bg-green-500/20 border-green-500/50'
                      : idx === calibrationStep
                      ? 'bg-cyan-500/20 border-cyan-500 animate-pulse'
                      : 'bg-slate-800/40 border-slate-700/50'
                  }`}
                >
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-slate-200">{name}</span>
                    {idx < calibrationStep && (
                      <CheckCircle2 className="w-5 h-5 text-green-500" />
                    )}
                    {idx === calibrationStep && (
                      <motion.div
                        className="w-5 h-5 border-2 border-cyan-500 rounded-full border-t-transparent"
                        animate={{ rotate: 360 }}
                        transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
                      />
                    )}
                  </div>
                  {idx <= calibrationStep && sensorReadings[idx] > 0 && (
                    <div className="space-y-1">
                      <div className="h-2 bg-slate-700 rounded-full overflow-hidden">
                        <motion.div
                          className="h-full bg-gradient-to-r from-cyan-500 to-purple-600"
                          initial={{ width: 0 }}
                          animate={{ width: `${(sensorReadings[idx] / 150) * 100}%` }}
                        />
                      </div>
                      <p className="text-slate-400">{Math.round(sensorReadings[idx])} N</p>
                    </div>
                  )}
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {connectionState === 'synced' && (
        <div className="space-y-6">
          <div className="p-6 bg-gradient-to-r from-green-500/10 to-emerald-500/10 rounded-xl border border-green-500/30 text-center">
            <CheckCircle2 className="w-16 h-16 text-green-500 mx-auto mb-3" />
            <p className="text-green-400 mb-2">All Sensors Verified</p>
            <p className="text-slate-400">Your insoles are ready to use</p>
          </div>

          <div className="grid grid-cols-2 gap-3">
            {sensorNames.map((name, idx) => (
              <div
                key={name}
                className="p-3 bg-slate-800/40 rounded-lg border border-slate-700/50"
              >
                <p className="text-slate-400 mb-1">{name}</p>
                <p className="text-cyan-400">{Math.round(sensorReadings[idx])} N</p>
              </div>
            ))}
          </div>

          <Button
            onClick={onComplete}
            className="w-full bg-gradient-to-r from-cyan-500 to-purple-600 hover:from-cyan-600 hover:to-purple-700 text-white"
          >
            Continue to Dashboard
          </Button>
        </div>
      )}
    </div>
  );
}
