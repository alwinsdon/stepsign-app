import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/onboarding_screen.dart';
import 'screens/pairing_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/live_session_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/viewer_3d_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/settings_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage service
  await StorageService.init();
  
  // Set status bar to transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const StepSignApp());
}

class StepSignApp extends StatelessWidget {
  const StepSignApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StepSign',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF06B6D4), // Cyan
          secondary: const Color(0xFFA855F7), // Purple
          surface: const Color(0xFF1E293B),
          background: const Color(0xFF0F172A),
        ),
      ),
      home: const AppNavigator(),
    );
  }
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  String _currentScreen = 'loading';
  bool _hasCompletedOnboarding = false;
  bool _isPaired = false;

  @override
  void initState() {
    super.initState();
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    // Load persisted state
    _hasCompletedOnboarding = StorageService.hasCompletedOnboarding;
    _isPaired = StorageService.isDevicePaired;
    
    // Determine initial screen based on saved state
    String initialScreen;
    if (!_hasCompletedOnboarding) {
      initialScreen = 'onboarding';
    } else if (!_isPaired) {
      initialScreen = 'pairing';
    } else {
      initialScreen = 'dashboard';
    }
    
    setState(() {
      _currentScreen = initialScreen;
    });
  }

  void _handleOnboardingComplete() async {
    await StorageService.setOnboardingCompleted(true);
    setState(() {
      _hasCompletedOnboarding = true;
      _currentScreen = 'pairing';
    });
  }

  void _handlePairingComplete() async {
    await StorageService.setDevicePaired(true);
    setState(() {
      _isPaired = true;
      _currentScreen = 'dashboard';
    });
  }

  void _navigateToScreen(String screen) {
    setState(() {
      _currentScreen = screen;
    });
  }

  void _handleAppReset() {
    setState(() {
      _hasCompletedOnboarding = false;
      _isPaired = false;
      _currentScreen = 'onboarding';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F172A), // Slate 950
            Color(0xFF1E293B), // Slate 900
            Color(0xFF0F172A), // Slate 950
          ],
        ),
      ),
      child: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case 'loading':
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF06B6D4),
            ),
          ),
        );
      case 'onboarding':
        return OnboardingScreen(onComplete: _handleOnboardingComplete);
      case 'pairing':
        return PairingScreen(
          onComplete: _handlePairingComplete,
          onBack: () => _navigateToScreen('dashboard'),
        );
      case 'dashboard':
        return DashboardScreen(
          onNavigate: _navigateToScreen,
          isPaired: _isPaired,
        );
      case 'live':
        return LiveSessionScreen(
          onBack: () => _navigateToScreen('dashboard'),
        );
      case 'analytics':
        return AnalyticsScreen(
          onBack: () => _navigateToScreen('dashboard'),
        );
      case '3d':
        return Viewer3DScreen(
          onBack: () => _navigateToScreen('dashboard'),
        );
      case 'goals':
        return GoalsScreen(
          onBack: () => _navigateToScreen('dashboard'),
        );
      case 'wallet':
        return WalletScreen(
          onBack: () => _navigateToScreen('dashboard'),
        );
      case 'settings':
        return SettingsScreen(
          onBack: () => _navigateToScreen('dashboard'),
          onResetApp: _handleAppReset,
        );
      default:
        return DashboardScreen(
          onNavigate: _navigateToScreen,
          isPaired: _isPaired,
        );
    }
  }
}

