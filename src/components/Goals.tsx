import { useState } from 'react';
import { ArrowLeft, Target, TrendingDown, Calendar, AlertTriangle, MessageSquare } from 'lucide-react';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Input } from './ui/input';
import { Progress } from './ui/progress';
import { motion } from 'motion/react';

interface GoalsProps {
  onBack: () => void;
}

export function Goals({ onBack }: GoalsProps) {
  const [isEditing, setIsEditing] = useState(false);
  const [targetWeight, setTargetWeight] = useState(180);
  const [dailySteps, setDailySteps] = useState(10000);
  const [activeMinutes, setActiveMinutes] = useState(60);
  const [currentWeight] = useState(185);
  const [currentStreak] = useState(12);
  const [verifiedSessions] = useState(89);
  const [flaggedSessions] = useState(3);

  const weightProgress = (((190 - currentWeight) / (190 - targetWeight)) * 100);
  const sessionsRequired = 100;
  const sessionsProgress = (verifiedSessions / sessionsRequired) * 100;

  const flaggedSessionsData = [
    {
      id: 1,
      date: 'Nov 12, 2025',
      reason: 'Pattern matches shake — low confidence',
      steps: 1247,
      status: 'under-review',
    },
    {
      id: 2,
      date: 'Nov 10, 2025',
      reason: 'High vibration, low forward progression',
      steps: 892,
      status: 'disputed',
    },
    {
      id: 3,
      date: 'Nov 8, 2025',
      reason: 'Irregular gait pattern detected',
      steps: 564,
      status: 'flagged',
    },
  ];

  return (
    <div className="min-h-screen max-w-md mx-auto p-6 pb-24">
      <div className="flex items-center gap-4 mb-6">
        <Button variant="ghost" size="icon" onClick={onBack} className="text-slate-400">
          <ArrowLeft className="w-5 h-5" />
        </Button>
        <div className="flex-1">
          <h1 className="text-white">Goals & AI Insights</h1>
          <p className="text-slate-400">Track progress & verification</p>
        </div>
      </div>

      {/* Current Streak */}
      <div className="p-5 bg-gradient-to-br from-cyan-500/10 via-purple-500/10 to-pink-500/10 rounded-xl border border-cyan-500/30 mb-6">
        <div className="flex items-center gap-3 mb-3">
          <div className="w-12 h-12 rounded-full bg-gradient-to-br from-cyan-500 to-purple-600 flex items-center justify-center">
            <Target className="w-6 h-6 text-white" />
          </div>
          <div className="flex-1">
            <p className="text-white">{currentStreak} Day Streak</p>
            <p className="text-slate-400">Keep it up!</p>
          </div>
          <span className="text-3xl">🔥</span>
        </div>
      </div>

      {/* Weight Goal */}
      <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50 mb-6">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <TrendingDown className="w-5 h-5 text-purple-400" />
            <p className="text-slate-200">Weight Goal</p>
          </div>
          <Button
            variant="ghost"
            size="sm"
            onClick={() => setIsEditing(!isEditing)}
            className="text-purple-400 hover:text-purple-300"
          >
            {isEditing ? 'Save' : 'Edit'}
          </Button>
        </div>

        {isEditing ? (
          <div className="space-y-4">
            <div>
              <label className="text-slate-400 mb-2 block">Target Weight (lbs)</label>
              <Input
                type="number"
                value={targetWeight}
                onChange={(e) => setTargetWeight(Number(e.target.value))}
                className="bg-slate-900/50 border-slate-600"
              />
            </div>
            <div>
              <label className="text-slate-400 mb-2 block">Daily Steps Goal</label>
              <Input
                type="number"
                value={dailySteps}
                onChange={(e) => setDailySteps(Number(e.target.value))}
                className="bg-slate-900/50 border-slate-600"
              />
            </div>
            <div>
              <label className="text-slate-400 mb-2 block">Active Minutes Goal</label>
              <Input
                type="number"
                value={activeMinutes}
                onChange={(e) => setActiveMinutes(Number(e.target.value))}
                className="bg-slate-900/50 border-slate-600"
              />
            </div>
          </div>
        ) : (
          <div className="space-y-4">
            <div>
              <div className="flex items-center justify-between mb-2">
                <p className="text-slate-400">Current Weight</p>
                <p className="text-white">{currentWeight} lbs</p>
              </div>
              <div className="flex items-center justify-between mb-2">
                <p className="text-slate-400">Target Weight</p>
                <p className="text-purple-400">{targetWeight} lbs</p>
              </div>
              <Progress value={weightProgress} className="h-2 mb-2" />
              <p className="text-slate-400">{Math.round(weightProgress)}% to goal</p>
            </div>

            <div className="pt-4 border-t border-slate-700/50">
              <div className="flex items-center justify-between mb-2">
                <p className="text-slate-400">Daily Steps</p>
                <p className="text-cyan-400">{dailySteps.toLocaleString()}</p>
              </div>
              <div className="flex items-center justify-between">
                <p className="text-slate-400">Active Minutes</p>
                <p className="text-cyan-400">{activeMinutes} min</p>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Verification Requirements */}
      <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50 mb-6">
        <div className="flex items-center gap-2 mb-4">
          <Calendar className="w-5 h-5 text-cyan-400" />
          <p className="text-slate-200">Verification Progress</p>
        </div>
        
        <div className="mb-4">
          <div className="flex items-center justify-between mb-2">
            <p className="text-slate-400">Verified Sessions</p>
            <p className="text-cyan-400">{verifiedSessions} / {sessionsRequired}</p>
          </div>
          <Progress value={sessionsProgress} className="h-2" />
        </div>

        <div className="p-4 bg-slate-900/50 rounded-lg border border-slate-700/50">
          <p className="text-slate-300 mb-2">How AI verifies steps:</p>
          <ul className="space-y-2 text-slate-400">
            <li className="flex items-start gap-2">
              <div className="w-1.5 h-1.5 rounded-full bg-cyan-400 mt-2" />
              <span>Analyzes pressure patterns from 4 FSR sensors</span>
            </li>
            <li className="flex items-start gap-2">
              <div className="w-1.5 h-1.5 rounded-full bg-purple-400 mt-2" />
              <span>Validates IMU data for forward motion</span>
            </li>
            <li className="flex items-start gap-2">
              <div className="w-1.5 h-1.5 rounded-full bg-pink-400 mt-2" />
              <span>Detects anomalies (shaking, tampering)</span>
            </li>
            <li className="flex items-start gap-2">
              <div className="w-1.5 h-1.5 rounded-full bg-orange-400 mt-2" />
              <span>Ensures gait consistency over time</span>
            </li>
          </ul>
        </div>
      </div>

      {/* Confidence Timeline */}
      <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50 mb-6">
        <p className="text-slate-200 mb-4">Recent Activity Confidence</p>
        <div className="space-y-3">
          {Array.from({ length: 7 }).map((_, i) => {
            const confidence = 70 + Math.random() * 30;
            const isFlagged = confidence < 80;
            return (
              <div key={i} className="flex items-center gap-3">
                <span className="text-slate-400 w-12">
                  Nov {14 - i}
                </span>
                <div className="flex-1 h-2 bg-slate-700 rounded-full overflow-hidden">
                  <motion.div
                    className={`h-full ${
                      isFlagged
                        ? 'bg-gradient-to-r from-yellow-500 to-orange-500'
                        : 'bg-gradient-to-r from-cyan-500 to-purple-600'
                    }`}
                    initial={{ width: 0 }}
                    animate={{ width: `${confidence}%` }}
                    transition={{ duration: 0.5, delay: i * 0.1 }}
                  />
                </div>
                <span className={`w-12 text-right ${isFlagged ? 'text-yellow-400' : 'text-cyan-400'}`}>
                  {Math.round(confidence)}%
                </span>
              </div>
            );
          })}
        </div>
      </div>

      {/* Flagged Sessions */}
      <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50 mb-6">
        <div className="flex items-center gap-2 mb-4">
          <AlertTriangle className="w-5 h-5 text-amber-400" />
          <p className="text-slate-200">Flagged Sessions</p>
          <Badge variant="outline" className="ml-auto bg-amber-500/10 text-amber-400 border-amber-500/50">
            {flaggedSessions}
          </Badge>
        </div>

        <div className="space-y-3">
          {flaggedSessionsData.map((session) => (
            <div
              key={session.id}
              className="p-4 bg-slate-900/50 rounded-lg border border-slate-700/50"
            >
              <div className="flex items-start justify-between mb-2">
                <div className="flex-1">
                  <p className="text-slate-200 mb-1">{session.date}</p>
                  <p className="text-amber-400 mb-2">{session.reason}</p>
                  <p className="text-slate-400">{session.steps} steps recorded</p>
                </div>
                <Badge
                  variant="outline"
                  className={
                    session.status === 'disputed'
                      ? 'bg-blue-500/10 text-blue-400 border-blue-500/50'
                      : session.status === 'under-review'
                      ? 'bg-purple-500/10 text-purple-400 border-purple-500/50'
                      : 'bg-amber-500/10 text-amber-400 border-amber-500/50'
                  }
                >
                  {session.status === 'disputed' && 'Disputed'}
                  {session.status === 'under-review' && 'Review'}
                  {session.status === 'flagged' && 'Flagged'}
                </Badge>
              </div>
              <Button
                variant="outline"
                size="sm"
                className="w-full border-slate-600 text-slate-300"
              >
                <MessageSquare className="w-4 h-4 mr-2" />
                Dispute & Request Review
              </Button>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
