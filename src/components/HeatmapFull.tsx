import { motion } from 'motion/react';

interface HeatmapFullProps {
  sensorData: {
    heel: number;
    arch: number;
    ball: number;
    toes: number;
  };
}

export function HeatmapFull({ sensorData }: HeatmapFullProps) {
  const getIntensity = (value: number) => Math.min(value / 100, 1);
  const getColor = (intensity: number) => {
    if (intensity > 0.7) return { color: '#ef4444', opacity: 0.8 };
    if (intensity > 0.5) return { color: '#f97316', opacity: 0.7 };
    if (intensity > 0.3) return { color: '#eab308', opacity: 0.6 };
    return { color: '#3b82f6', opacity: 0.4 };
  };

  const heelIntensity = getIntensity(sensorData.heel);
  const archIntensity = getIntensity(sensorData.arch);
  const ballIntensity = getIntensity(sensorData.ball);
  const toesIntensity = getIntensity(sensorData.toes);

  return (
    <div className="relative w-full max-w-[300px] mx-auto aspect-[1/2]">
      <svg viewBox="0 0 100 240" className="w-full h-full">
        <defs>
          <radialGradient id="heel-live" cx="50%" cy="50%">
            <stop offset="0%" stopColor={getColor(heelIntensity).color} stopOpacity={getColor(heelIntensity).opacity} />
            <stop offset="50%" stopColor={getColor(heelIntensity).color} stopOpacity={getColor(heelIntensity).opacity * 0.5} />
            <stop offset="100%" stopColor="#3b82f6" stopOpacity="0.1" />
          </radialGradient>
          <radialGradient id="arch-live" cx="50%" cy="50%">
            <stop offset="0%" stopColor={getColor(archIntensity).color} stopOpacity={getColor(archIntensity).opacity} />
            <stop offset="50%" stopColor={getColor(archIntensity).color} stopOpacity={getColor(archIntensity).opacity * 0.5} />
            <stop offset="100%" stopColor="#3b82f6" stopOpacity="0.1" />
          </radialGradient>
          <radialGradient id="ball-live" cx="50%" cy="50%">
            <stop offset="0%" stopColor={getColor(ballIntensity).color} stopOpacity={getColor(ballIntensity).opacity} />
            <stop offset="50%" stopColor={getColor(ballIntensity).color} stopOpacity={getColor(ballIntensity).opacity * 0.5} />
            <stop offset="100%" stopColor="#3b82f6" stopOpacity="0.1" />
          </radialGradient>
          <radialGradient id="toes-live" cx="50%" cy="50%">
            <stop offset="0%" stopColor={getColor(toesIntensity).color} stopOpacity={getColor(toesIntensity).opacity} />
            <stop offset="50%" stopColor={getColor(toesIntensity).color} stopOpacity={getColor(toesIntensity).opacity * 0.5} />
            <stop offset="100%" stopColor="#3b82f6" stopOpacity="0.1" />
          </radialGradient>
        </defs>

        {/* Insole outline */}
        <path
          d="M 30 10 Q 20 40 25 100 Q 30 140 35 180 Q 40 220 50 235 Q 60 220 65 180 Q 70 140 75 100 Q 80 40 70 10 Q 50 5 30 10 Z"
          fill="#0f172a"
          stroke="#475569"
          strokeWidth="2"
        />

        {/* Pressure regions with smooth interpolation */}
        <motion.ellipse
          cx="50" cy="30" rx="25" ry="32"
          fill="url(#toes-live)"
          animate={{ rx: 25 + toesIntensity * 5, ry: 32 + toesIntensity * 8 }}
          transition={{ duration: 0.2 }}
        />

        <motion.ellipse
          cx="50" cy="80" rx="28" ry="38"
          fill="url(#ball-live)"
          animate={{ rx: 28 + ballIntensity * 5, ry: 38 + ballIntensity * 8 }}
          transition={{ duration: 0.2 }}
        />

        <motion.ellipse
          cx="45" cy="140" rx="22" ry="32"
          fill="url(#arch-live)"
          animate={{ rx: 22 + archIntensity * 4, ry: 32 + archIntensity * 6 }}
          transition={{ duration: 0.2 }}
        />

        <motion.ellipse
          cx="50" cy="200" rx="30" ry="38"
          fill="url(#heel-live)"
          animate={{ rx: 30 + heelIntensity * 6, ry: 38 + heelIntensity * 10 }}
          transition={{ duration: 0.2 }}
        />

        {/* Sensor position markers */}
        <g>
          <circle cx="50" cy="30" r="4" fill="#06b6d4" opacity="0.8" />
          <text x="60" y="33" fill="#94a3b8" fontSize="10">Toes</text>
        </g>
        <g>
          <circle cx="50" cy="80" r="4" fill="#06b6d4" opacity="0.8" />
          <text x="60" y="83" fill="#94a3b8" fontSize="10">Ball</text>
        </g>
        <g>
          <circle cx="45" cy="140" r="4" fill="#06b6d4" opacity="0.8" />
          <text x="15" y="143" fill="#94a3b8" fontSize="10">Arch</text>
        </g>
        <g>
          <circle cx="50" cy="200" r="4" fill="#06b6d4" opacity="0.8" />
          <text x="60" y="203" fill="#94a3b8" fontSize="10">Heel</text>
        </g>
      </svg>
    </div>
  );
}
