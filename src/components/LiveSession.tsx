import { useState, useEffect } from 'react';
import { motion } from 'motion/react';
import { ArrowLeft, Activity, AlertTriangle, CheckCircle2, Zap, Gauge } from 'lucide-react';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Slider } from './ui/slider';
import { Switch } from './ui/switch';
import { HeatmapFull } from './HeatmapFull';
import { IMUOrientationMini } from './IMUOrientationMini';

interface LiveSessionProps {
  onBack: () => void;
}

type Gesture = 'Walking' | 'Running' | 'Standing' | 'Jumping' | 'Stairs';
type CheatStatus = 'verified' | 'suspicious' | 'flagged';

export function LiveSession({ onBack }: LiveSessionProps) {
  const [sessionTime, setSessionTime] = useState(0);
  const [steps, setSteps] = useState(0);
  const [currentGesture, setCurrentGesture] = useState<Gesture>('Walking');
  const [gestureConfidence, setGestureConfidence] = useState(92);
  const [cheatStatus, setCheatStatus] = useState<CheatStatus>('verified');
  const [cheatReason, setCheatReason] = useState('');
  const [hapticEnabled, setHapticEnabled] = useState(true);
  const [hapticIntensity, setHapticIntensity] = useState([70]);
  const [dataRate, setDataRate] = useState(50);
  const [latency, setLatency] = useState(12);
  const [sensorData, setSensorData] = useState({
    heel: 0,
    arch: 0,
    ball: 0,
    toes: 0,
  });
  const [imuData, setImuData] = useState({
    pitch: 0,
    roll: 0,
    yaw: 0,
  });

  useEffect(() => {
    const interval = setInterval(() => {
      setSessionTime((t) => t + 1);
      
      // Simulate step detection
      if (Math.random() > 0.7 && currentGesture !== 'Standing') {
        setSteps((s) => s + 1);
      }

      // Simulate gesture changes
      if (Math.random() > 0.95) {
        const gestures: Gesture[] = ['Walking', 'Running', 'Standing', 'Jumping', 'Stairs'];
        const newGesture = gestures[Math.floor(Math.random() * gestures.length)];
        setCurrentGesture(newGesture);
        setGestureConfidence(Math.floor(Math.random() * 20) + 80);
      }

      // Simulate cheat detection (rare)
      if (Math.random() > 0.98) {
        const statuses: CheatStatus[] = ['verified', 'suspicious', 'flagged'];
        const reasons = [
          '',
          'Pattern matches shake — low confidence',
          'Possible tampering: high vibration, low forward progression',
        ];
        const idx = Math.floor(Math.random() * statuses.length);
        setCheatStatus(statuses[idx]);
        setCheatReason(reasons[idx]);
      } else if (Math.random() > 0.9) {
        setCheatStatus('verified');
        setCheatReason('');
      }

      // Simulate sensor data based on gesture
      const gestureMultiplier = {
        Walking: 1,
        Running: 1.5,
        Standing: 0.3,
        Jumping: 2,
        Stairs: 1.2,
      }[currentGesture];

      setSensorData({
        heel: Math.random() * 100 * gestureMultiplier,
        arch: Math.random() * 60 * gestureMultiplier,
        ball: Math.random() * 80 * gestureMultiplier,
        toes: Math.random() * 50 * gestureMultiplier,
      });

      // Simulate IMU data
      setImuData({
        pitch: Math.sin(sessionTime / 10) * 15 * gestureMultiplier,
        roll: Math.cos(sessionTime / 15) * 10,
        yaw: Math.sin(sessionTime / 20) * 20,
      });

      // Vary data rate slightly
      setDataRate(48 + Math.floor(Math.random() * 5));
      setLatency(10 + Math.floor(Math.random() * 6));
    }, 1000);

    return () => clearInterval(interval);
  }, [sessionTime, currentGesture]);

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  const getCheatColor = () => {
    if (cheatStatus === 'verified') return 'text-green-400 border-green-500/50 bg-green-500/10';
    if (cheatStatus === 'suspicious') return 'text-yellow-400 border-yellow-500/50 bg-yellow-500/10';
    return 'text-red-400 border-red-500/50 bg-red-500/10';
  };

  const getCheatIcon = () => {
    if (cheatStatus === 'verified') return <CheckCircle2 className="w-4 h-4" />;
    if (cheatStatus === 'suspicious') return <AlertTriangle className="w-4 h-4" />;
    return <AlertTriangle className="w-4 h-4" />;
  };

  return (
    <div className="min-h-screen max-w-md mx-auto p-6 pb-24">
      <div className="flex items-center gap-4 mb-6">
        <Button
          variant="ghost"
          size="icon"
          onClick={onBack}
          className="text-slate-400"
        >
          <ArrowLeft className="w-5 h-5" />
        </Button>
        <div className="flex-1">
          <h1 className="text-white">Live Session</h1>
          <p className="text-slate-400">{formatTime(sessionTime)}</p>
        </div>
        <div className="flex items-center gap-2">
          <motion.div
            className="w-2 h-2 bg-red-500 rounded-full"
            animate={{ opacity: [1, 0.3, 1] }}
            transition={{ duration: 1.5, repeat: Infinity }}
          />
          <span className="text-red-400">REC</span>
        </div>
      </div>

      {/* Quick Stats */}
      <div className="grid grid-cols-3 gap-3 mb-6">
        <div className="p-3 bg-slate-800/40 rounded-lg border border-slate-700/50 text-center">
          <p className="text-white">{steps}</p>
          <p className="text-slate-400">Steps</p>
        </div>
        <div className="p-3 bg-slate-800/40 rounded-lg border border-slate-700/50 text-center">
          <p className="text-white">{dataRate} Hz</p>
          <p className="text-slate-400">Data Rate</p>
        </div>
        <div className="p-3 bg-slate-800/40 rounded-lg border border-slate-700/50 text-center">
          <p className="text-white">{latency} ms</p>
          <p className="text-slate-400">Latency</p>
        </div>
      </div>

      {/* Gesture Detection */}
      <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50 mb-6">
        <div className="flex items-center gap-3 mb-4">
          <Activity className="w-5 h-5 text-cyan-400" />
          <p className="text-slate-200">Current Activity</p>
        </div>
        <div className="flex items-center justify-between mb-3">
          <div>
            <p className="text-white mb-1">{currentGesture}</p>
            <div className="flex items-center gap-2">
              <div className="h-2 w-24 bg-slate-700 rounded-full overflow-hidden">
                <motion.div
                  className="h-full bg-gradient-to-r from-cyan-500 to-purple-600"
                  animate={{ width: `${gestureConfidence}%` }}
                  transition={{ duration: 0.3 }}
                />
              </div>
              <span className="text-slate-400">{gestureConfidence}%</span>
            </div>
          </div>
          <Badge variant="outline" className="bg-cyan-500/10 text-cyan-400 border-cyan-500/50">
            AI Model
          </Badge>
        </div>
        
        {/* Waveform visualization */}
        <div className="h-16 bg-slate-900/50 rounded-lg p-2 flex items-center gap-1">
          {Array.from({ length: 50 }).map((_, i) => {
            const height = Math.random() * (currentGesture === 'Standing' ? 0.3 : 1);
            return (
              <motion.div
                key={i}
                className="flex-1 bg-gradient-to-t from-cyan-500 to-purple-600 rounded-sm"
                animate={{ height: `${height * 100}%` }}
                transition={{ duration: 0.1 }}
              />
            );
          })}
        </div>
      </div>

      {/* Cheat Detection */}
      <div className={`p-4 rounded-xl border mb-6 ${getCheatColor()}`}>
        <div className="flex items-center gap-2 mb-1">
          {getCheatIcon()}
          <p className="font-medium">
            {cheatStatus === 'verified' && 'Verified Steps'}
            {cheatStatus === 'suspicious' && '⚠️ Unverified Steps'}
            {cheatStatus === 'flagged' && '⚠️ Possible Tampering Detected'}
          </p>
        </div>
        {cheatReason && <p className="text-sm opacity-80">{cheatReason}</p>}
      </div>

      {/* Full Heatmap */}
      <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50 mb-6">
        <div className="flex items-center justify-between mb-4">
          <p className="text-slate-200">Pressure Heatmap</p>
          <div className="flex gap-2 items-center text-sm">
            <div className="flex items-center gap-1">
              <div className="w-2 h-2 rounded-full bg-blue-500" />
              <span className="text-slate-400">Low</span>
            </div>
            <div className="flex items-center gap-1">
              <div className="w-2 h-2 rounded-full bg-yellow-500" />
              <span className="text-slate-400">Med</span>
            </div>
            <div className="flex items-center gap-1">
              <div className="w-2 h-2 rounded-full bg-red-500" />
              <span className="text-slate-400">High</span>
            </div>
          </div>
        </div>
        <HeatmapFull sensorData={sensorData} />
        
        {/* Sensor Readings */}
        <div className="grid grid-cols-4 gap-2 mt-4">
          <div className="p-2 bg-slate-900/50 rounded text-center">
            <p className="text-slate-400">Heel</p>
            <p className="text-cyan-400">{Math.round(sensorData.heel)} N</p>
          </div>
          <div className="p-2 bg-slate-900/50 rounded text-center">
            <p className="text-slate-400">Arch</p>
            <p className="text-yellow-400">{Math.round(sensorData.arch)} N</p>
          </div>
          <div className="p-2 bg-slate-900/50 rounded text-center">
            <p className="text-slate-400">Ball</p>
            <p className="text-orange-400">{Math.round(sensorData.ball)} N</p>
          </div>
          <div className="p-2 bg-slate-900/50 rounded text-center">
            <p className="text-slate-400">Toes</p>
            <p className="text-blue-400">{Math.round(sensorData.toes)} N</p>
          </div>
        </div>
      </div>

      {/* IMU Orientation */}
      <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50 mb-6">
        <p className="text-slate-200 mb-4">IMU Orientation</p>
        <IMUOrientationMini imuData={imuData} />
        <div className="grid grid-cols-3 gap-2 mt-4">
          <div className="p-2 bg-slate-900/50 rounded text-center">
            <p className="text-slate-400">Pitch</p>
            <p className="text-cyan-400">{Math.round(imuData.pitch)}°</p>
          </div>
          <div className="p-2 bg-slate-900/50 rounded text-center">
            <p className="text-slate-400">Roll</p>
            <p className="text-purple-400">{Math.round(imuData.roll)}°</p>
          </div>
          <div className="p-2 bg-slate-900/50 rounded text-center">
            <p className="text-slate-400">Yaw</p>
            <p className="text-pink-400">{Math.round(imuData.yaw)}°</p>
          </div>
        </div>
      </div>

      {/* Haptic Controls */}
      <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50 mb-6">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <Zap className="w-5 h-5 text-purple-400" />
            <p className="text-slate-200">Haptic Feedback</p>
          </div>
          <Switch checked={hapticEnabled} onCheckedChange={setHapticEnabled} />
        </div>
        {hapticEnabled && (
          <div className="space-y-2">
            <div className="flex items-center justify-between">
              <span className="text-slate-400">Intensity</span>
              <span className="text-slate-200">{hapticIntensity[0]}%</span>
            </div>
            <Slider
              value={hapticIntensity}
              onValueChange={setHapticIntensity}
              max={100}
              step={1}
            />
            <Button
              variant="outline"
              size="sm"
              className="w-full border-slate-600 text-slate-300"
              onClick={() => {
                // Trigger haptic test
              }}
            >
              <Gauge className="w-4 h-4 mr-2" />
              Test Vibration
            </Button>
          </div>
        )}
      </div>

      <Button
        onClick={onBack}
        className="w-full bg-red-500/20 border-red-500 hover:bg-red-500/30 text-red-400"
      >
        End Session
      </Button>
    </div>
  );
}
