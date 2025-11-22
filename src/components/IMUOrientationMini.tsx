import { motion } from 'motion/react';

interface IMUOrientationMiniProps {
  imuData: {
    pitch: number;
    roll: number;
    yaw: number;
  };
}

export function IMUOrientationMini({ imuData }: IMUOrientationMiniProps) {
  return (
    <div className="bg-slate-900/50 rounded-lg p-6 flex items-center justify-center">
      <div className="relative w-48 h-48">
        {/* 3D insole representation */}
        <motion.div
          className="absolute inset-0"
          style={{
            transformStyle: 'preserve-3d',
            perspective: '1000px',
          }}
          animate={{
            rotateX: imuData.pitch,
            rotateY: imuData.yaw,
            rotateZ: imuData.roll,
          }}
          transition={{ duration: 0.3 }}
        >
          {/* Top surface */}
          <div
            className="absolute w-20 h-40 left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 rounded-full bg-gradient-to-br from-cyan-500/30 to-purple-600/30 border-2 border-cyan-500/50"
            style={{
              transform: 'translateZ(10px)',
            }}
          >
            <div className="absolute top-4 left-1/2 -translate-x-1/2 w-2 h-2 bg-cyan-400 rounded-full" />
            <div className="absolute top-14 left-1/2 -translate-x-1/2 w-2 h-2 bg-cyan-400 rounded-full" />
            <div className="absolute top-24 left-1/2 -translate-x-1/2 w-2 h-2 bg-cyan-400 rounded-full" />
            <div className="absolute top-34 left-1/2 -translate-x-1/2 w-2 h-2 bg-cyan-400 rounded-full" />
          </div>

          {/* Bottom surface (shadow) */}
          <div
            className="absolute w-20 h-40 left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 rounded-full bg-slate-800/50 blur-sm"
            style={{
              transform: 'translateZ(-10px)',
            }}
          />
        </motion.div>

        {/* Axis indicators */}
        <div className="absolute -bottom-8 left-0 right-0 flex justify-center gap-4 text-xs">
          <div className="flex items-center gap-1">
            <div className="w-2 h-2 bg-cyan-500 rounded-full" />
            <span className="text-slate-400">X</span>
          </div>
          <div className="flex items-center gap-1">
            <div className="w-2 h-2 bg-purple-500 rounded-full" />
            <span className="text-slate-400">Y</span>
          </div>
          <div className="flex items-center gap-1">
            <div className="w-2 h-2 bg-pink-500 rounded-full" />
            <span className="text-slate-400">Z</span>
          </div>
        </div>

        {/* Grid background */}
        <svg className="absolute inset-0 w-full h-full opacity-20" viewBox="0 0 100 100">
          <defs>
            <pattern id="grid" width="10" height="10" patternUnits="userSpaceOnUse">
              <path d="M 10 0 L 0 0 0 10" fill="none" stroke="#475569" strokeWidth="0.5"/>
            </pattern>
          </defs>
          <rect width="100" height="100" fill="url(#grid)" />
        </svg>
      </div>
    </div>
  );
}
