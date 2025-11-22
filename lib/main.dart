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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
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
  String _currentScreen = 'onboarding';
  bool _hasCompletedOnboarding = false;
  bool _isPaired = false;

  void _handleOnboardingComplete() {
    setState(() {
      _hasCompletedOnboarding = true;
      _currentScreen = 'pairing';
    });
  }

  void _handlePairingComplete() {
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
        );
      default:
        return DashboardScreen(
          onNavigate: _navigateToScreen,
          isPaired: _isPaired,
        );
    }
  }
}

