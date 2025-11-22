import { useState } from 'react';
import { Onboarding } from './components/Onboarding';
import { Pairing } from './components/Pairing';
import { Dashboard } from './components/Dashboard';
import { LiveSession } from './components/LiveSession';
import { Analytics } from './components/Analytics';
import { Viewer3D } from './components/Viewer3D';
import { Goals } from './components/Goals';
import { Wallet } from './components/Wallet';
import { Settings } from './components/Settings';

type Screen = 'onboarding' | 'pairing' | 'dashboard' | 'live' | 'analytics' | '3d' | 'goals' | 'wallet' | 'settings';

export default function App() {
  const [currentScreen, setCurrentScreen] = useState<Screen>('onboarding');
  const [hasCompletedOnboarding, setHasCompletedOnboarding] = useState(false);
  const [isPaired, setIsPaired] = useState(false);

  const handleOnboardingComplete = () => {
    setHasCompletedOnboarding(true);
    setCurrentScreen('pairing');
  };

  const handlePairingComplete = () => {
    setIsPaired(true);
    setCurrentScreen('dashboard');
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-slate-950 via-slate-900 to-slate-950">
      {currentScreen === 'onboarding' && (
        <Onboarding onComplete={handleOnboardingComplete} />
      )}
      {currentScreen === 'pairing' && (
        <Pairing onComplete={handlePairingComplete} onBack={() => setCurrentScreen('dashboard')} />
      )}
      {currentScreen === 'dashboard' && (
        <Dashboard onNavigate={setCurrentScreen} isPaired={isPaired} />
      )}
      {currentScreen === 'live' && (
        <LiveSession onBack={() => setCurrentScreen('dashboard')} />
      )}
      {currentScreen === 'analytics' && (
        <Analytics onBack={() => setCurrentScreen('dashboard')} />
      )}
      {currentScreen === '3d' && (
        <Viewer3D onBack={() => setCurrentScreen('dashboard')} />
      )}
      {currentScreen === 'goals' && (
        <Goals onBack={() => setCurrentScreen('dashboard')} />
      )}
      {currentScreen === 'wallet' && (
        <Wallet onBack={() => setCurrentScreen('dashboard')} />
      )}
      {currentScreen === 'settings' && (
        <Settings onBack={() => setCurrentScreen('dashboard')} />
      )}
    </div>
  );
}
