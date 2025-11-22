import { useState, useEffect } from 'react';
import { motion } from 'motion/react';
import {
  Activity,
  Zap,
  Target,
  Wallet,
  Play,
  Square,
  Settings,
  TrendingUp,
  BarChart3,
  Box,
  Flame,
  Clock,
} from 'lucide-react';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Progress } from './ui/progress';
import { HeatmapMini } from './HeatmapMini';

interface DashboardProps {
  onNavigate: (screen: string) => void;
  isPaired: boolean;
}

export function Dashboard({ onNavigate, isPaired }: DashboardProps) {
  const [isSessionActive, setIsSessionActive] = useState(false);
  const [steps, setSteps] = useState(7842);
  const [activeMinutes, setActiveMinutes] = useState(64);
  const [calories, setCalories] = useState(342);
  const [stakedAmount] = useState(250);
  const [pendingRewards] = useState(12.5);
  const [currentWeight] = useState(185);
  const [goalWeight] = useState(180);

  const goalProgress = ((7842 / 10000) * 100);
  const weightProgress = (((190 - currentWeight) / (190 - goalWeight)) * 100);

  useEffect(() => {
    if (isSessionActive) {
      const interval = setInterval(() => {
        setSteps((s) => s + Math.floor(Math.random() * 3));
        if (Math.random() > 0.7) {
          setActiveMinutes((m) => m + 1);
          setCalories((c) => c + Math.floor(Math.random() * 5));
        }
      }, 2000);
      return () => clearInterval(interval);
    }
  }, [isSessionActive]);

  return (
    <div className="min-h-screen max-w-md mx-auto p-6 pb-24">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-white mb-1">StepSign</h1>
          <p className="text-slate-400">Good morning, Alex</p>
        </div>
        <Button
          variant="ghost"
          size="icon"
          onClick={() => onNavigate('settings')}
          className="text-slate-400"
        >
          <Settings className="w-5 h-5" />
        </Button>
      </div>

      {/* Connection Status */}
      {isPaired && (
        <motion.div
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          className="mb-6 p-4 bg-gradient-to-r from-green-500/10 to-emerald-500/10 rounded-xl border border-green-500/30"
        >
          <div className="flex items-center gap-2">
            <div className="relative">
              <div className="w-2 h-2 bg-green-500 rounded-full" />
              <motion.div
                className="absolute inset-0 bg-green-500 rounded-full"
                animate={{ scale: [1, 2, 1], opacity: [0.5, 0, 0.5] }}
                transition={{ duration: 2, repeat: Infinity }}
              />
            </div>
            <p className="text-green-400">Connected — both insoles synced</p>
          </div>
        </motion.div>
      )}

      {/* Main Stats Grid */}
      <div className="grid grid-cols-3 gap-3 mb-6">
        <div className="p-4 bg-slate-800/40 rounded-xl border border-slate-700/50">
          <Activity className="w-5 h-5 text-cyan-400 mb-2" />
          <p className="text-white">{steps.toLocaleString()}</p>
          <p className="text-slate-400">Steps</p>
        </div>
        <div className="p-4 bg-slate-800/40 rounded-xl border border-slate-700/50">
          <Clock className="w-5 h-5 text-purple-400 mb-2" />
          <p className="text-white">{activeMinutes}</p>
          <p className="text-slate-400">Active min</p>
        </div>
        <div className="p-4 bg-slate-800/40 rounded-xl border border-slate-700/50">
          <Flame className="w-5 h-5 text-orange-400 mb-2" />
          <p className="text-white">{calories}</p>
          <p className="text-slate-400">Calories</p>
        </div>
      </div>

      {/* Daily Goal Progress */}
      <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50 mb-6">
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-2">
            <Target className="w-5 h-5 text-cyan-400" />
            <p className="text-slate-200">Daily Goal</p>
          </div>
          <Badge variant="outline" className="bg-cyan-500/10 text-cyan-400 border-cyan-500/50">
            {Math.round(goalProgress)}%
          </Badge>
        </div>
        <div className="mb-2">
          <Progress value={goalProgress} className="h-2" />
        </div>
        <div className="flex items-center justify-between">
          <p className="text-slate-400">{steps.toLocaleString()} / 10,000 steps</p>
          <p className="text-cyan-400">+{Math.round(goalProgress / 10)} tokens</p>
        </div>
      </div>

      {/* Weight Goal */}
      <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50 mb-6">
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-2">
            <TrendingUp className="w-5 h-5 text-purple-400" />
            <p className="text-slate-200">Weight Goal</p>
          </div>
          <button
            onClick={() => onNavigate('goals')}
            className="text-purple-400 hover:text-purple-300"
          >
            Edit
          </button>
        </div>
        <div className="mb-2">
          <Progress value={weightProgress} className="h-2" />
        </div>
        <p className="text-slate-400">{currentWeight} lbs → {goalWeight} lbs target</p>
      </div>

      {/* Live Preview */}
      <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50 mb-6">
        <div className="flex items-center justify-between mb-4">
          <p className="text-slate-200">Live Sensors</p>
          <div className="flex gap-2">
            <button
              onClick={() => onNavigate('3d')}
              className="text-slate-400 hover:text-cyan-400 transition-colors"
            >
              <Box className="w-5 h-5" />
            </button>
            <button
              onClick={() => onNavigate('analytics')}
              className="text-slate-400 hover:text-cyan-400 transition-colors"
            >
              <BarChart3 className="w-5 h-5" />
            </button>
          </div>
        </div>
        <div className="bg-slate-900/50 rounded-lg p-4">
          <HeatmapMini isActive={isSessionActive} />
        </div>
      </div>

      {/* Wallet Summary */}
      <div
        onClick={() => onNavigate('wallet')}
        className="p-5 bg-gradient-to-br from-amber-500/10 via-orange-500/10 to-pink-500/10 rounded-xl border border-amber-500/30 mb-6 cursor-pointer hover:border-amber-500/50 transition-colors"
      >
        <div className="flex items-center gap-3 mb-4">
          <div className="w-10 h-10 rounded-full bg-gradient-to-br from-amber-500 to-pink-600 flex items-center justify-center">
            <Wallet className="w-5 h-5 text-white" />
          </div>
          <div className="flex-1">
            <p className="text-slate-200">Wallet</p>
            <p className="text-slate-400">Staked & Rewards</p>
          </div>
        </div>
        <div className="grid grid-cols-2 gap-4">
          <div>
            <p className="text-amber-400">{stakedAmount} STEP</p>
            <p className="text-slate-400">Staked</p>
          </div>
          <div>
            <p className="text-green-400">+{pendingRewards} STEP</p>
            <p className="text-slate-400">Pending</p>
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-2 gap-3">
        <Button
          onClick={() => {
            if (isSessionActive) {
              setIsSessionActive(false);
            } else {
              setIsSessionActive(true);
              onNavigate('live');
            }
          }}
          className={`h-auto py-4 ${
            isSessionActive
              ? 'bg-red-500/20 border-red-500 hover:bg-red-500/30 text-red-400'
              : 'bg-gradient-to-r from-cyan-500 to-purple-600 hover:from-cyan-600 hover:to-purple-700 text-white'
          }`}
        >
          {isSessionActive ? (
            <>
              <Square className="w-5 h-5 mr-2" />
              End Session
            </>
          ) : (
            <>
              <Play className="w-5 h-5 mr-2" />
              Start Session
            </>
          )}
        </Button>
        <Button
          onClick={() => onNavigate('pairing')}
          variant="outline"
          className="h-auto py-4 border-slate-600 text-slate-300"
        >
          <Zap className="w-5 h-5 mr-2" />
          Calibrate
        </Button>
      </div>
    </div>
  );
}
