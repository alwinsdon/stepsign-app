import { useState, useEffect } from 'react';
import { ArrowLeft, Play, Pause, RotateCw, Grid3x3, Eye } from 'lucide-react';
import { motion } from 'motion/react';
import { Button } from './ui/button';
import { Slider } from './ui/slider';
import { Switch } from './ui/switch';

interface Viewer3DProps {
  onBack: () => void;
}

export function Viewer3D({ onBack }: Viewer3DProps) {
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState([0]);
  const [showWireframe, setShowWireframe] = useState(false);
  const [showSensors, setShowSensors] = useState(true);
  const [autoRotate, setAutoRotate] = useState(false);
  const [rotation, setRotation] = useState({ x: 20, y: 30, z: 0 });
  const [imuData, setImuData] = useState({ pitch: 0, roll: 0, yaw: 0 });

  // Exact CAD insole path
  const insolePath = "M386.18 42.56L386.77 42.53L387.35 42.51L387.93 42.5L388.5 42.48L389.06 42.47L389.62 42.46L390.73 42.46L391.81 42.46L392.87 42.47L393.91 42.49L394.93 42.53L395.94 42.57L396.92 42.63L397.88 42.69L398.83 42.76L399.75 42.85L400.66 42.94L401.56 43.04L402.43 43.15L403.29 43.27L404.13 43.4L404.96 43.54L405.77 43.68L406.57 43.84L407.35 44L408.12 44.17L408.87 44.35L409.61 44.54L410.34 44.73L411.05 44.93L411.76 45.14L412.44 45.36L413.12 45.58L413.79 45.82L414.44 46.05L415.08 46.3L415.71 46.55L416.33 46.81L416.94 47.07L417.54 47.35L418.14 47.62L418.72 47.91L419.29 48.2L419.85 48.49L420.4 48.8L420.95 49.1L421.49 49.42L422.02 49.73L422.54 50.06L423.05 50.39L423.56 50.72L424.06 51.06L424.55 51.41L425.03 51.75L425.51 52.11L425.98 52.47L426.45 52.83L426.91 53.2L427.36 53.57L427.81 53.95L428.25 54.33L428.69 54.71L429.12 55.1L429.55 55.49L429.97 55.89L430.8 56.69L431.61 57.51L432.4 58.35L433.17 59.19L433.93 60.05L434.68 60.92L435.41 61.8L436.12 62.69L436.82 63.59L437.51 64.51L438.18 65.43L438.85 66.36L439.49 67.29L440.13 68.24L440.75 69.19L441.36 70.15L441.96 71.12L442.54 72.09L443.12 73.07L443.67 74.06L444.22 75.05L444.76 76.04L445.28 77.04L445.79 78.04L446.29 79.05L446.78 80.06L447.25 81.08L447.72 82.1L448.17 83.12L448.61 84.15L449.04 85.18L449.46 86.21L449.87 87.25L450.27 88.28L450.65 89.33L451.03 90.37L451.4 91.42L451.75 92.47L452.1 93.53L452.44 94.58L452.76 95.64L453.08 96.71L453.39 97.77L453.69 98.85L453.98 99.92L454.27 101L454.54 102.08L454.81 103.17L455.06 104.26L455.32 105.36L455.56 106.46L455.79 107.57L456.02 108.68L456.24 109.8L456.46 110.93L456.67 112.06L456.87 113.2L457.07 114.35L457.26 115.5L457.45 116.66L457.63 117.83L457.8 119.01L457.97 120.2L458.14 121.4L458.3 122.6L458.46 123.82L458.61 125.04L458.76 126.27L458.91 127.52L459.05 128.77L459.19 130.03L459.32 131.29L459.46 132.57L459.59 133.86L459.71 135.15L459.83 136.45L459.96 137.76L460.07 139.08L460.19 140.41L460.3 141.74L460.41 143.08L460.52 144.43L460.63 145.78L460.84 148.5L461.03 151.25L461.23 154L461.41 156.77L461.59 159.55L461.76 162.32L461.93 165.09L462.08 167.85L462.23 170.59L462.31 171.95L462.38 173.31L462.45 174.66L462.52 176L462.58 177.33L462.65 178.65L462.71 179.97L462.77 181.27L462.83 182.57L462.89 183.85L462.95 185.13L463.01 186.39L463.06 187.64L463.12 188.88L463.17 190.11L463.22 191.33L463.27 192.54L463.32 193.73L463.37 194.91L463.42 196.08L463.47 197.24L463.52 198.39L463.57 199.53L463.61 200.65L463.66 201.76L463.71 202.87L463.76 203.96L463.81 205.04L463.86 206.11L463.91 207.18L463.96 208.23L464.02 209.28L464.07 210.31L464.13 211.34L464.19 212.37L464.25 213.38L464.38 215.4L464.52 217.4L464.67 219.39L464.83 221.37L465.01 223.36L465.21 225.35L465.43 227.35L465.54 228.36L465.66 229.37L465.79 230.39L465.92 231.41L466.06 232.44L466.2 233.47L466.35 234.52L466.51 235.57L466.67 236.62L466.84 237.69L467.01 238.77L467.19 239.85L467.38 240.95L467.57 242.05L467.78 243.17L467.98 244.29L468.2 245.43L468.42 246.58L468.65 247.74L468.89 248.92L469.14 250.1L469.39 251.3L469.65 252.51L469.92 253.74L470.19 254.97L470.47 256.22L470.77 257.49L471.06 258.77L471.37 260.06L471.69 261.36L472.01 262.68L472.34 264.02L472.68 265.36L473.02 266.73L473.38 268.1L473.74 269.5L474.11 270.9L474.48 272.32L474.87 273.76L475.26 275.22L475.66 276.69L476.07 278.18L476.48 279.69L476.9 281.22L477.32 282.77L477.76 284.34L478.19 285.93L478.41 286.74L478.63 287.55L478.86 288.37L479.08 289.2L479.3 290.03L479.53 290.87L479.76 291.71L479.99 292.56L480.21 293.42L480.44 294.29L480.67 295.16L480.9 296.05L481.14 296.94L481.37 297.84L481.6 298.74L481.83 299.66L482.07 300.58L482.3 301.52L482.53 302.46L482.77 303.41L483 304.38L483.23 305.35L483.47 306.33L483.7 307.33L483.93 308.33L484.17 309.35L484.4 310.37L484.63 311.41L484.86 312.46L485.09 313.53L485.32 314.6L485.55 315.69L485.78 316.79L486 317.9L486.23 319.03L486.45 320.17L486.68 321.33L486.9 322.5L487.12 323.68L487.33 324.88L487.55 326.1L487.76 327.33L487.98 328.58L488.19 329.84L488.39 331.13L488.6 332.42L488.8 333.74L489 335.07L489.2 336.43L489.39 337.8L489.58 339.19L489.77 340.59L489.96 342.02L490.14 343.47L490.03 345.16L489.92 346.84L489.8 348.52L489.67 350.18L489.54 351.84L489.4 353.49L489.25 355.12L489.1 356.75L488.94 358.37L488.77 359.99L488.6 361.59L488.43 363.18L488.24 364.77L488.06 366.35L487.86 367.91L487.66 369.47L487.46 371.02L487.25 372.56L487.03 374.09L486.82 375.61L486.36 378.62L485.89 381.6L485.41 384.54L484.9 387.44L484.38 390.3L483.85 393.13L483.3 395.92L482.74 398.66L482.17 401.37L481.59 404.04L481 406.68L480.39 409.27L479.78 411.83L479.16 414.34L478.53 416.82L477.89 419.26L477.25 421.67L476.6 424.03L475.95 426.36L475.29 428.64L474.63 430.9L473.96 433.11L473.3 435.29L472.62 437.43L471.95 439.53L471.27 441.6L470.6 443.63L469.92 445.63L469.24 447.59L468.56 449.51L467.88 451.41L467.2 453.27L466.53 455.09L465.85 456.89L465.17 458.65L464.5 460.38L463.83 462.08L463.16 463.75L462.49 465.39L461.82 467L461.16 468.58L460.5 470.14L459.84 471.67L459.19 473.17L458.53 474.64L457.88 476.09L457.24 477.52L456.6 478.92L455.96 480.3L455.32 481.66L454.69 482.99L454.06 484.3L453.43 485.6L452.81 486.87L452.19 488.12L451.58 489.35L450.97 490.56L450.37 491.75L449.76 492.92L449.17 494.08L448.57 495.22L447.99 496.34L447.4 497.44L446.82 498.53L446.24 499.6L445.67 500.66L445.1 501.7L444.54 502.73L443.98 503.74L443.42 504.74L442.87 505.72L442.32 506.69L441.78 507.65L441.24 508.59L440.7 509.52L440.17 510.44L439.64 511.35L439.12 512.24L438.6 513.12L438.08 514L437.56 514.85L437.05 515.7L436.54 516.54L436.04 517.36L435.54 518.18L435.04 518.98L434.54 519.77L434.05 520.56L433.56 521.33L433.07 522.09L432.58 522.84L432.1 523.58L431.14 525.03L430.18 526.44L429.23 527.81L428.29 529.15L427.35 530.44L426.42 531.7L425.49 532.92L424.56 534.11L423.64 535.26L422.72 536.38L421.8 537.46L420.89 538.52L419.99 539.54L419.08 540.52L418.18 541.48L417.29 542.41L416.4 543.31L415.52 544.18L414.65 545.02L413.78 545.83L412.93 546.62L412.08 547.38L411.24 548.12L410.42 548.83L409.61 549.52L408.82 550.18L408.03 550.83L407.27 551.45L406.52 552.05L405.79 552.63L405.07 553.19L404.37 553.73L403.69 554.25L403.02 554.75L402.37 555.23L401.73 555.7L401.11 556.15L400.5 556.58L399.9 557L399.32 557.4L398.74 557.78L398.18 558.15L397.62 558.51L397.07 558.84L396.52 559.17L395.97 559.48L395.42 559.78L394.87 560.06L394.31 560.33L393.75 560.58L393.18 560.83L392.6 561.06L392.01 561.27L391.4 561.48L390.78 561.67L390.15 561.85L389.51 562.02L388.85 562.17L388.17 562.32L387.48 562.45L386.77 562.57L386.05 562.69L385.32 562.79L384.57 562.88L383.82 562.96L383.05 563.03L382.27 563.09L381.49 563.14L380.7 563.18L379.11 563.23L377.52 563.25L376.73 563.25L375.96 563.24L375.19 563.22L374.43 563.19L373.68 563.15L372.95 563.1L372.23 563.05L371.53 562.99L370.84 562.92L370.17 562.83L369.51 562.74L368.87 562.65L368.25 562.54L367.64 562.42L367.05 562.29L366.47 562.15L365.9 562L365.35 561.83L364.81 561.66L364.27 561.47L363.75 561.27L363.23 561.05L362.71 560.82L362.19 560.58L361.67 560.32L361.15 560.04L360.62 559.75L360.09 559.44L359.54 559.11L358.99 558.77L358.43 558.41L357.86 558.03L357.28 557.64L356.69 557.23L356.09 556.8L355.48 556.36L354.85 555.91L354.22 555.44L353.57 554.96L352.92 554.47L352.26 553.97L351.6 553.46L350.26 552.43L348.92 551.37L347.6 550.31L346.95 549.78L346.31 549.25L345.69 548.73L345.08 548.22L344.49 547.72L343.91 547.22L343.36 546.73L342.83 546.26L342.32 545.79L341.83 545.34L341.36 544.89L340.92 544.46L340.5 544.04L340.09 543.63L339.72 543.23L339.36 542.84L339.02 542.46L338.7 542.09L338.4 541.72L338.11 541.36L337.84 541.01L337.57 540.65L337.08 539.95L336.6 539.24L336.12 538.5L335.88 538.11L335.63 537.72L335.38 537.31L335.12 536.89L334.84 536.46L334.56 536.01L334.27 535.54L333.97 535.06L333.65 534.55L333.33 534.03L332.99 533.48L332.64 532.92L332.28 532.33L331.9 531.72L331.52 531.09L331.13 530.43L330.73 529.75L330.32 529.05L329.9 528.32L329.48 527.57L329.06 526.8L328.64 526L328.21 525.19L327.79 524.34L327.37 523.48L326.95 522.59L326.54 521.68L326.13 520.75L325.73 519.8L325.34 518.83L324.96 517.84L324.58 516.82L324.21 515.79L323.85 514.74L323.5 513.67L323.16 512.58L322.83 511.48L322.51 510.36L322.2 509.22L321.9 508.07L321.6 506.91L321.31 505.73L321.03 504.54L320.76 503.34L320.49 502.13L320.23 500.91L319.72 498.44L319.22 495.94L318.72 493.42L318.23 490.87L317.74 488.31L317.24 485.72L316.74 483.1L316.23 480.46L315.71 477.79L315.19 475.09L314.92 473.72L314.66 472.33L314.39 470.94L314.12 469.53L313.86 468.1L313.59 466.66L313.32 465.2L313.05 463.73L312.78 462.24L312.51 460.72L312.25 459.2L311.98 457.65L311.72 456.09L311.46 454.51L311.2 452.91L310.94 451.3L310.69 449.68L310.44 448.04L310.19 446.39L309.95 444.73L309.47 441.39L309.01 438.04L308.58 434.68L308.16 431.35L307.97 429.69L307.78 428.06L307.59 426.43L307.42 424.83L307.25 423.24L307.09 421.68L306.94 420.13L306.8 418.61L306.67 417.11L306.54 415.63L306.43 414.18L306.33 412.75L306.24 411.34L306.17 409.95L306.1 408.58L306.05 407.24L306.01 405.91L305.99 404.59L305.98 403.29L305.99 402.01L306.01 400.73L306.05 399.45L306.11 398.18L306.18 396.91L306.27 395.64L306.39 394.36L306.52 393.07L306.67 391.76L306.84 390.45L307.03 389.11L307.24 387.76L307.47 386.39L307.73 384.99L308 383.58L308.29 382.13L308.6 380.67L308.94 379.18L309.29 377.67L309.66 376.13L310.04 374.56L310.45 372.98L310.87 371.37L311.3 369.74L311.75 368.09L312.22 366.42L312.7 364.73L313.18 363.03L313.68 361.32L314.19 359.6L314.7 357.87L315.75 354.4L316.81 350.93L317.89 347.46L318.96 344.01L320.03 340.6L321.09 337.21L322.14 333.87L323.17 330.56L324.19 327.28L325.19 324.04L326.16 320.82L327.12 317.62L328.06 314.42L328.99 311.22L329.89 308L330.78 304.78L331.66 301.53L332.51 298.26L333.34 294.98L334.14 291.67L334.92 288.35L335.67 285.02L336.38 281.68L337.05 278.34L337.38 276.67L337.69 275.01L337.99 273.35L338.27 271.69L338.55 270.04L338.81 268.39L339.06 266.74L339.3 265.1L339.52 263.46L339.73 261.83L339.93 260.19L340.11 258.56L340.28 256.93L340.44 255.3L340.58 253.67L340.71 252.03L340.83 250.39L340.93 248.74L341.02 247.09L341.1 245.42L341.17 243.75L341.22 242.06L341.27 240.35L341.3 238.62L341.32 236.87L341.33 235.1L341.34 233.3L341.33 231.47L341.32 229.62L341.29 227.73L341.26 225.81L341.22 223.86L341.18 221.87L341.13 219.85L341.07 217.8L341.01 215.71L340.94 213.58L340.87 211.42L340.79 209.22L340.71 206.98L340.63 204.71L340.55 202.41L340.46 200.08L340.37 197.71L340.28 195.31L340.18 192.89L340.09 190.43L340 187.95L339.91 185.45L339.82 182.92L339.73 180.38L339.64 177.81L339.56 175.23L339.47 172.64L339.32 167.43L339.18 162.2L339.06 156.96L338.96 151.74L338.92 149.15L338.88 146.57L338.85 144.01L338.83 141.47L338.82 138.95L338.81 136.46L338.81 133.99L338.82 131.56L338.84 129.17L338.85 127.99L338.86 126.82L338.88 125.66L338.9 124.51L338.92 123.38L338.94 122.25L338.97 121.14L338.99 120.04L339.02 118.96L339.05 117.89L339.09 116.83L339.13 115.78L339.17 114.75L339.21 113.73L339.25 112.73L339.3 111.73L339.35 110.76L339.4 109.8L339.46 108.85L339.51 107.91L339.57 106.99L339.64 106.08L339.7 105.19L339.77 104.31L339.84 103.44L339.91 102.59L339.99 101.75L340.07 100.92L340.15 100.1L340.23 99.29L340.32 98.5L340.41 97.72L340.51 96.94L340.6 96.18L340.8 94.68L341.01 93.22L341.24 91.79L341.47 90.38L341.72 88.99L341.98 87.61L342.25 86.23L342.53 84.86L342.83 83.48L343.14 82.08L343.47 80.66L343.81 79.22L344 78.48L344.19 77.74L344.39 76.99L344.61 76.22L344.83 75.45L345.07 74.67L345.32 73.88L345.59 73.08L345.88 72.27L346.18 71.44L346.51 70.61L346.87 69.76L347.24 68.9L347.65 68.04L348.09 67.15L348.56 66.26L349.07 65.36L349.61 64.45L349.9 63.99L350.2 63.52L350.51 63.06L350.83 62.59L351.16 62.12L351.51 61.65L351.87 61.17L352.24 60.69L352.62 60.21L353.02 59.73L353.43 59.25L353.86 58.76L354.3 58.27L354.76 57.78L355.23 57.29L355.72 56.79L356.23 56.29L356.75 55.8L357.3 55.3L357.86 54.79L358.44 54.29L359.03 53.79L359.65 53.28L360.29 52.77L360.95 52.27L361.63 51.76L362.33 51.25L363.06 50.74L363.81 50.23L364.58 49.71L365.37 49.2L366.19 48.69L367.04 48.18L367.91 47.66L368.81 47.15L369.73 46.64L370.68 46.12L371.66 45.61L372.67 45.1L373.71 44.59L374.78 44.08L375.87 43.57L377 43.06L378.16 42.56L386.18 42.56Z";

  useEffect(() => {
    if (isPlaying) {
      const interval = setInterval(() => {
        setCurrentTime(([time]) => {
          const newTime = time >= 100 ? 0 : time + 1;
          // Simulate IMU data playback
          setImuData({
            pitch: Math.sin(newTime / 10) * 20,
            roll: Math.cos(newTime / 15) * 15,
            yaw: Math.sin(newTime / 8) * 25,
          });
          return [newTime];
        });
      }, 100);
      return () => clearInterval(interval);
    }
  }, [isPlaying]);

  useEffect(() => {
    if (autoRotate) {
      const interval = setInterval(() => {
        setRotation((prev) => ({
          ...prev,
          y: (prev.y + 1) % 360,
        }));
      }, 50);
      return () => clearInterval(interval);
    }
  }, [autoRotate]);

  return (
    <div className="min-h-screen max-w-md mx-auto p-6 pb-24">
      <div className="flex items-center gap-4 mb-6">
        <Button variant="ghost" size="icon" onClick={onBack} className="text-slate-400">
          <ArrowLeft className="w-5 h-5" />
        </Button>
        <div className="flex-1">
          <h1 className="text-white">3D Orientation Viewer</h1>
          <p className="text-slate-400">IMU replay & visualization</p>
        </div>
      </div>

      {/* 3D Viewer */}
      <div className="p-6 bg-slate-800/40 rounded-xl border border-slate-700/50 mb-6">
        <div className="relative w-full h-80 bg-slate-900/50 rounded-lg flex items-center justify-center overflow-hidden">
          {/* Grid background */}
          <svg className="absolute inset-0 w-full h-full opacity-10" viewBox="0 0 100 100">
            <defs>
              <pattern id="grid-3d" width="5" height="5" patternUnits="userSpaceOnUse">
                <path d="M 5 0 L 0 0 0 5" fill="none" stroke="#475569" strokeWidth="0.5"/>
              </pattern>
            </defs>
            <rect width="100" height="100" fill="url(#grid-3d)" />
          </svg>

          {/* 3D Insole Model */}
          <motion.div
            className="relative"
            style={{
              transformStyle: 'preserve-3d',
              perspective: '1200px',
            }}
            animate={{
              rotateX: rotation.x + imuData.pitch,
              rotateY: rotation.y + imuData.yaw,
              rotateZ: rotation.z + imuData.roll + 180,
            }}
            transition={{ duration: 0.2 }}
          >
            <div
              className="relative"
              style={{
                transformStyle: 'preserve-3d',
                width: '140px',
                height: '320px',
              }}
            >
              {/* Top surface - Exact CAD insole shape */}
              <div
                className="absolute inset-0"
                style={{
                  transform: 'translateZ(10px)',
                }}
              >
                <svg viewBox="280 20 240 580" className="w-full h-full" preserveAspectRatio="xMidYMid meet">
                  <defs>
                    <linearGradient id="insole-gradient-top" x1="0%" y1="0%" x2="100%" y2="100%">
                      <stop offset="0%" style={{ stopColor: '#06b6d4', stopOpacity: showWireframe ? 0 : 0.3 }} />
                      <stop offset="50%" style={{ stopColor: '#9333ea', stopOpacity: showWireframe ? 0 : 0.3 }} />
                      <stop offset="100%" style={{ stopColor: '#ec4899', stopOpacity: showWireframe ? 0 : 0.3 }} />
                    </linearGradient>
                    <filter id="glow">
                      <feGaussianBlur stdDeviation="3" result="coloredBlur"/>
                      <feMerge>
                        <feMergeNode in="coloredBlur"/>
                        <feMergeNode in="SourceGraphic"/>
                      </feMerge>
                    </filter>
                  </defs>
                  
                  {/* Exact CAD insole outline */}
                  <path
                    d={insolePath}
                    fill={showWireframe ? 'none' : 'url(#insole-gradient-top)'}
                    stroke="#06b6d4"
                    strokeWidth={showWireframe ? '2' : '3'}
                    opacity={showWireframe ? '1' : '0.9'}
                    filter={showWireframe ? 'none' : 'url(#glow)'}
                  />

                  {/* Sensor indicators */}
                  {showSensors && (
                    <>
                      <circle cx="400" cy="65" r="7" fill="#06b6d4" className="animate-pulse" opacity="0.95">
                        <animate attributeName="r" values="7;9;7" dur="1.5s" repeatCount="indefinite" />
                      </circle>
                      <circle cx="400" cy="150" r="7" fill="#9333ea" className="animate-pulse" opacity="0.95">
                        <animate attributeName="r" values="7;9;7" dur="1.5s" begin="0.2s" repeatCount="indefinite" />
                      </circle>
                      <circle cx="360" cy="330" r="7" fill="#ec4899" className="animate-pulse" opacity="0.95">
                        <animate attributeName="r" values="7;9;7" dur="1.5s" begin="0.4s" repeatCount="indefinite" />
                      </circle>
                      <circle cx="388" cy="520" r="7" fill="#f97316" className="animate-pulse" opacity="0.95">
                        <animate attributeName="r" values="7;9;7" dur="1.5s" begin="0.6s" repeatCount="indefinite" />
                      </circle>
                    </>
                  )}
                </svg>
              </div>

              {/* Bottom surface */}
              <div
                className="absolute inset-0"
                style={{
                  transform: 'translateZ(-10px)',
                }}
              >
                <svg viewBox="280 20 240 580" className="w-full h-full opacity-40 blur-sm" preserveAspectRatio="xMidYMid meet">
                  <path
                    d={insolePath}
                    fill="#1e293b"
                    stroke={showWireframe ? '#475569' : 'none'}
                    strokeWidth="1"
                  />
                </svg>
              </div>

              {/* 3D Edge for depth */}
              {!showWireframe && (
                <div
                  className="absolute inset-0 pointer-events-none"
                  style={{
                    transform: 'translateZ(0px)',
                  }}
                >
                  <svg viewBox="280 20 240 580" className="w-full h-full" preserveAspectRatio="xMidYMid meet">
                    <defs>
                      <linearGradient id="edge-gradient" x1="0%" y1="0%" x2="0%" y2="100%">
                        <stop offset="0%" style={{ stopColor: '#1e293b', stopOpacity: 0.8 }} />
                        <stop offset="100%" style={{ stopColor: '#0f172a', stopOpacity: 0.9 }} />
                      </linearGradient>
                    </defs>
                    <path
                      d={insolePath}
                      fill="url(#edge-gradient)"
                      stroke="#06b6d4"
                      strokeWidth="0.5"
                      opacity="0.6"
                    />
                  </svg>
                </div>
              )}
            </div>
          </motion.div>

          {/* Axis labels */}
          <div className="absolute bottom-4 left-4 flex gap-3 text-xs">
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
        </div>
      </div>

      {/* IMU Data Display */}
      <div className="grid grid-cols-3 gap-3 mb-6">
        <div className="p-4 bg-slate-800/40 rounded-lg border border-slate-700/50 text-center">
          <p className="text-slate-400 mb-1">Pitch</p>
          <p className="text-cyan-400">{Math.round(imuData.pitch)}°</p>
        </div>
        <div className="p-4 bg-slate-800/40 rounded-lg border border-slate-700/50 text-center">
          <p className="text-slate-400 mb-1">Roll</p>
          <p className="text-purple-400">{Math.round(imuData.roll)}°</p>
        </div>
        <div className="p-4 bg-slate-800/40 rounded-lg border border-slate-700/50 text-center">
          <p className="text-slate-400 mb-1">Yaw</p>
          <p className="text-pink-400">{Math.round(imuData.yaw)}°</p>
        </div>
      </div>

      {/* Playback Controls */}
      <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50 mb-6">
        <div className="flex items-center gap-3 mb-4">
          <Button
            variant="outline"
            size="icon"
            onClick={() => setIsPlaying(!isPlaying)}
            className="border-slate-600"
          >
            {isPlaying ? (
              <Pause className="w-4 h-4 text-slate-300" />
            ) : (
              <Play className="w-4 h-4 text-slate-300" />
            )}
          </Button>
          <div className="flex-1">
            <Slider
              value={currentTime}
              onValueChange={(value) => {
                setCurrentTime(value);
                setImuData({
                  pitch: Math.sin(value[0] / 10) * 20,
                  roll: Math.cos(value[0] / 15) * 15,
                  yaw: Math.sin(value[0] / 8) * 25,
                });
              }}
              max={100}
              step={1}
              className="flex-1"
            />
          </div>
          <span className="text-slate-400 min-w-[3rem] text-right">{currentTime[0]}s</span>
        </div>
      </div>

      {/* View Options */}
      <div className="space-y-3 mb-6">
        <div className="flex items-center justify-between p-4 bg-slate-800/40 rounded-lg border border-slate-700/50">
          <div className="flex items-center gap-2">
            <Grid3x3 className="w-5 h-5 text-slate-400" />
            <span className="text-slate-200">Wireframe Mode</span>
          </div>
          <Switch checked={showWireframe} onCheckedChange={setShowWireframe} />
        </div>
        <div className="flex items-center justify-between p-4 bg-slate-800/40 rounded-lg border border-slate-700/50">
          <div className="flex items-center gap-2">
            <Eye className="w-5 h-5 text-slate-400" />
            <span className="text-slate-200">Show Sensors</span>
          </div>
          <Switch checked={showSensors} onCheckedChange={setShowSensors} />
        </div>
        <div className="flex items-center justify-between p-4 bg-slate-800/40 rounded-lg border border-slate-700/50">
          <div className="flex items-center gap-2">
            <RotateCw className="w-5 h-5 text-slate-400" />
            <span className="text-slate-200">Auto Rotate</span>
          </div>
          <Switch checked={autoRotate} onCheckedChange={setAutoRotate} />
        </div>
      </div>

      {/* Manual Rotation Controls */}
      {!autoRotate && (
        <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50 space-y-4">
          <p className="text-slate-200">Manual Rotation</p>
          <div className="space-y-3">
            <div>
              <div className="flex items-center justify-between mb-2">
                <span className="text-slate-400">X Axis</span>
                <span className="text-cyan-400">{rotation.x}°</span>
              </div>
              <Slider
                value={[rotation.x]}
                onValueChange={([value]) => setRotation({ ...rotation, x: value })}
                max={360}
                step={1}
              />
            </div>
            <div>
              <div className="flex items-center justify-between mb-2">
                <span className="text-slate-400">Y Axis</span>
                <span className="text-purple-400">{rotation.y}°</span>
              </div>
              <Slider
                value={[rotation.y]}
                onValueChange={([value]) => setRotation({ ...rotation, y: value })}
                max={360}
                step={1}
              />
            </div>
            <div>
              <div className="flex items-center justify-between mb-2">
                <span className="text-slate-400">Z Axis</span>
                <span className="text-pink-400">{rotation.z}°</span>
              </div>
              <Slider
                value={[rotation.z]}
                onValueChange={([value]) => setRotation({ ...rotation, z: value })}
                max={360}
                step={1}
              />
            </div>
          </div>
          <Button
            variant="outline"
            className="w-full border-slate-600 text-slate-300"
            onClick={() => setRotation({ x: 20, y: 30, z: 0 })}
          >
            Reset View
          </Button>
        </div>
      )}
    </div>
  );
}
