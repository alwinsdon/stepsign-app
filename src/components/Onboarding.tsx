import { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { ChevronRight, Bluetooth, Activity, Smartphone, Zap } from 'lucide-react';
import { Button } from './ui/button';
import { HeatmapPreview } from './HeatmapPreview';
import { Badge } from './ui/badge';

interface OnboardingProps {
  onComplete: () => void;
}

export function Onboarding({ onComplete }: OnboardingProps) {
  const [step, setStep] = useState(0);
  const [permissions, setPermissions] = useState({
    bluetooth: false,
    activity: false,
    notifications: false,
  });

  const slides = [
    {
      title: 'Welcome to StepSign',
      subtitle: 'Smart insoles powered by AI',
      icon: Activity,
      content: (
        <div className="space-y-4">
          <p className="text-slate-300 font-[Roboto] font-bold text-[20px]">Your smart insoles feature:</p>
          <div className="space-y-3">
            <div className="flex items-start gap-3 p-3 bg-slate-800/40 rounded-lg border border-slate-700/50">
              <div className="w-2 h-2 rounded-full bg-cyan-400 mt-2" />
              <div>
                <p className="text-cyan-400 font-[Roboto] font-bold text-[24px]">4 FSR Pressure Sensors</p>
                <p className="text-slate-400 font-normal font-[Roboto]">Heel • Arch • Ball • Toes</p>
              </div>
            </div>
            <div className="flex items-start gap-3 p-3 bg-slate-800/40 rounded-lg border border-slate-700/50">
              <div className="w-2 h-2 rounded-full bg-purple-400 mt-2" />
              <div>
                <p className="text-purple-400 font-[Roboto] text-[24px] font-bold">6-Axis IMU + Magnetometer</p>
                <p className="text-slate-400 font-normal font-[Roboto]">Pitch • Roll • Yaw tracking</p>
              </div>
            </div>
            <div className="flex items-start gap-3 p-3 bg-slate-800/40 rounded-lg border border-slate-700/50">
              <div className="w-2 h-2 rounded-full bg-pink-400 mt-2" />
              <div>
                <p className="text-pink-400 font-[Roboto] font-bold text-[24px]">Haptic Feedback Motor</p>
                <p className="text-slate-400 font-[Roboto]">Real-time vibration alerts</p>
              </div>
            </div>
            <div className="flex items-start gap-3 p-3 bg-slate-800/40 rounded-lg border border-slate-700/50">
              <div className="w-2 h-2 rounded-full bg-blue-400 mt-2" />
              <div>
                <p className="text-blue-400 text-[24px] font-bold">ESP32 BLE Low Energy</p>
                <p className="text-slate-400 font-[Roboto]">Low-power streaming</p>
              </div>
            </div>
          </div>
        </div>
      ),
    },
    {
      title: 'Real-time Visualization',
      subtitle: 'See your pressure data in action',
      icon: Smartphone,
      content: (
        <div className="space-y-4">
          <p className="text-slate-300">Live sensor heatmap with smooth interpolation:</p>
          <div className="bg-slate-800/40 rounded-xl p-6 border border-slate-700/50">
            <HeatmapPreview />
          </div>
          <div className="flex gap-2 items-center justify-center">
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-blue-500" />
              <span className="text-slate-400">Low</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-yellow-500" />
              <span className="text-slate-400">Medium</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-red-500" />
              <span className="text-slate-400">High</span>
            </div>
          </div>
        </div>
      ),
    },
    {
      title: 'AI-Powered Verification',
      subtitle: 'On-device gesture classification',
      icon: Zap,
      content: (
        <div className="space-y-4">
          <p className="text-slate-300">Our AI model detects and verifies:</p>
          <div className="grid grid-cols-2 gap-3">
            {['Walking', 'Running', 'Jumping', 'Standing', 'Stairs', 'Cheating'].map((gesture) => (
              <div
                key={gesture}
                className="p-4 bg-slate-800/40 rounded-lg border border-slate-700/50 text-center"
              >
                <Badge
                  variant="outline"
                  className={
                    gesture === 'Cheating'
                      ? 'bg-red-500/10 text-red-400 border-red-500/50'
                      : 'bg-cyan-500/10 text-cyan-400 border-cyan-500/50'
                  }
                >
                  {gesture}
                </Badge>
              </div>
            ))}
          </div>
          <div className="p-4 bg-gradient-to-r from-amber-500/10 to-orange-500/10 rounded-lg border border-amber-500/30">
            <p className="text-amber-400">⚠️ Anti-Cheat Detection</p>
            <p className="text-slate-400">Detects shaking, tampering & fake steps</p>
          </div>
        </div>
      ),
    },
    {
      title: 'Permissions Required',
      subtitle: 'Grant access to get started',
      icon: Bluetooth,
      content: (
        <div className="space-y-4">
          <p className="text-slate-300">We need the following permissions:</p>
          <div className="space-y-3">
            <button
              onClick={() => setPermissions({ ...permissions, bluetooth: true })}
              className="w-full p-4 bg-slate-800/40 rounded-lg border border-slate-700/50 flex items-center justify-between hover:bg-slate-800/60 transition-colors"
            >
              <div className="flex items-center gap-3">
                <Bluetooth className="w-5 h-5 text-blue-400" />
                <div className="text-left">
                  <p className="text-slate-200">Bluetooth</p>
                  <p className="text-slate-400">Connect to insoles</p>
                </div>
              </div>
              <div
                className={`w-5 h-5 rounded-full border-2 flex items-center justify-center ${
                  permissions.bluetooth
                    ? 'bg-cyan-500 border-cyan-500'
                    : 'border-slate-600'
                }`}
              >
                {permissions.bluetooth && (
                  <div className="w-2 h-2 bg-white rounded-full" />
                )}
              </div>
            </button>
            <button
              onClick={() => setPermissions({ ...permissions, activity: true })}
              className="w-full p-4 bg-slate-800/40 rounded-lg border border-slate-700/50 flex items-center justify-between hover:bg-slate-800/60 transition-colors"
            >
              <div className="flex items-center gap-3">
                <Activity className="w-5 h-5 text-purple-400" />
                <div className="text-left">
                  <p className="text-slate-200">Physical Activity</p>
                  <p className="text-slate-400">Track steps & movement</p>
                </div>
              </div>
              <div
                className={`w-5 h-5 rounded-full border-2 flex items-center justify-center ${
                  permissions.activity
                    ? 'bg-cyan-500 border-cyan-500'
                    : 'border-slate-600'
                }`}
              >
                {permissions.activity && (
                  <div className="w-2 h-2 bg-white rounded-full" />
                )}
              </div>
            </button>
            <button
              onClick={() => setPermissions({ ...permissions, notifications: true })}
              className="w-full p-4 bg-slate-800/40 rounded-lg border border-slate-700/50 flex items-center justify-between hover:bg-slate-800/60 transition-colors"
            >
              <div className="flex items-center gap-3">
                <Smartphone className="w-5 h-5 text-pink-400" />
                <div className="text-left">
                  <p className="text-slate-200">Notifications</p>
                  <p className="text-slate-400">Goal alerts & warnings</p>
                </div>
              </div>
              <div
                className={`w-5 h-5 rounded-full border-2 flex items-center justify-center ${
                  permissions.notifications
                    ? 'bg-cyan-500 border-cyan-500'
                    : 'border-slate-600'
                }`}
              >
                {permissions.notifications && (
                  <div className="w-2 h-2 bg-white rounded-full" />
                )}
              </div>
            </button>
          </div>
        </div>
      ),
    },
  ];

  const canProceed = step < 3 || Object.values(permissions).every((p) => p);

  return (
    <div className="min-h-screen flex flex-col max-w-md mx-auto p-6">
      <AnimatePresence mode="wait">
        <motion.div
          key={step}
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          exit={{ opacity: 0, x: -20 }}
          className="flex-1 flex flex-col"
        >
          <div className="flex-1">
            <div className="flex items-center justify-center mt-12 mb-8">
              {slides[step].icon && (() => {
                const Icon = slides[step].icon;
                return (
                  <div className="w-20 h-20 rounded-full bg-gradient-to-br from-cyan-500 to-purple-600 flex items-center justify-center">
                    <Icon className="w-10 h-10 text-white" />
                  </div>
                );
              })()}
            </div>

            <h1 className="text-white text-center mb-2">{slides[step].title}</h1>
            <p className="text-slate-400 text-center mb-8">{slides[step].subtitle}</p>

            <div className="mt-8">{slides[step].content}</div>
          </div>

          <div className="space-y-4 mt-8">
            <div className="flex gap-2 justify-center">
              {slides.map((_, i) => (
                <div
                  key={i}
                  className={`h-1 rounded-full transition-all ${
                    i === step
                      ? 'w-8 bg-gradient-to-r from-cyan-500 to-purple-600'
                      : 'w-1 bg-slate-700'
                  }`}
                />
              ))}
            </div>

            <Button
              onClick={() => {
                if (step === slides.length - 1) {
                  onComplete();
                } else {
                  setStep(step + 1);
                }
              }}
              disabled={!canProceed}
              className="w-full bg-gradient-to-r from-cyan-500 to-purple-600 hover:from-cyan-600 hover:to-purple-700 text-white"
            >
              {step === slides.length - 1 ? 'Get Started' : 'Continue'}
              <ChevronRight className="w-5 h-5 ml-2" />
            </Button>

            {step > 0 && step < slides.length - 1 && (
              <Button
                onClick={() => setStep(step - 1)}
                variant="ghost"
                className="w-full text-slate-400"
              >
                Back
              </Button>
            )}
          </div>
        </motion.div>
      </AnimatePresence>
    </div>
  );
}