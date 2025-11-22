import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../widgets/gradient_button.dart';
import '../widgets/feature_card.dart';
import '../widgets/permission_card.dart';
import '../widgets/heatmap_preview.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Permission states
  bool _bluetoothGranted = false;
  bool _activityGranted = false;
  bool _notificationsGranted = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _canProceed {
    if (_currentPage < 3) return true;
    return _bluetoothGranted && _activityGranted && _notificationsGranted;
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_canProceed) {
      // Navigate to next screen (Pairing/Dashboard)
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardScreen()));
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF0F172A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildWelcomePage(),
                    _buildVisualizationPage(),
                    _buildAIVerificationPage(),
                    _buildPermissionsPage(),
                  ],
                ),
              ),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF06B6D4), Color(0xFFA855F7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.show_chart,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          const Text(
            'Welcome to StepSign',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // Subtitle
          const Text(
            'Smart insoles powered by AI',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Features section
          const Text(
            'Your smart insoles feature:',
            style: TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Feature cards
          const FeatureCard(
            title: '4 FSR Pressure Sensors',
            subtitle: 'Heel • Arch • Ball • Toes',
            dotColor: Color(0xFF06B6D4),
          ),
          const SizedBox(height: 12),
          const FeatureCard(
            title: '6-Axis IMU + Magnetometer',
            subtitle: 'Pitch • Roll • Yaw tracking',
            dotColor: Color(0xFFA855F7),
          ),
          const SizedBox(height: 12),
          const FeatureCard(
            title: 'Haptic Feedback Motor',
            subtitle: 'Real-time vibration alerts',
            dotColor: Color(0xFFEC4899),
          ),
          const SizedBox(height: 12),
          const FeatureCard(
            title: 'ESP32 BLE Low Energy',
            subtitle: 'Low-power streaming',
            dotColor: Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualizationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF06B6D4), Color(0xFFA855F7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.phone_android,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          const Text(
            'Real-time Visualization',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // Subtitle
          const Text(
            'See your pressure data in action',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          const Text(
            'Live sensor heatmap with smooth interpolation:',
            style: TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          
          // Heatmap preview
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF334155).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: const Center(
              child: SizedBox(
                width: 200,
                height: 400,
                child: HeatmapPreview(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Low', const Color(0xFF3B82F6)),
              const SizedBox(width: 16),
              _buildLegendItem('Medium', const Color(0xFFEAB308)),
              const SizedBox(width: 16),
              _buildLegendItem('High', const Color(0xFFEF4444)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildAIVerificationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF06B6D4), Color(0xFFA855F7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.bolt,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          const Text(
            'AI-Powered Verification',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // Subtitle
          const Text(
            'On-device gesture classification',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          const Text(
            'Our AI model detects and verifies:',
            style: TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          
          // Gesture badges
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _buildGestureBadge('Walking', false),
              _buildGestureBadge('Running', false),
              _buildGestureBadge('Jumping', false),
              _buildGestureBadge('Standing', false),
              _buildGestureBadge('Stairs', false),
              _buildGestureBadge('Cheating', true),
            ],
          ),
          const SizedBox(height: 16),
          
          // Anti-cheat warning
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFF59E0B).withOpacity(0.1),
                  const Color(0xFFF97316).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF59E0B).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '⚠️ Anti-Cheat Detection',
                  style: TextStyle(
                    color: Color(0xFFFBBF24),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Detects shaking, tampering & fake steps',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGestureBadge(String label, bool isDanger) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF334155).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDanger
                ? const Color(0xFFEF4444).withOpacity(0.1)
                : const Color(0xFF06B6D4).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDanger
                  ? const Color(0xFFEF4444).withOpacity(0.5)
                  : const Color(0xFF06B6D4).withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isDanger ? const Color(0xFFEF4444) : const Color(0xFF06B6D4),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF06B6D4), Color(0xFFA855F7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.bluetooth,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          const Text(
            'Permissions Required',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // Subtitle
          const Text(
            'Grant access to get started',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          const Text(
            'We need the following permissions:',
            style: TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          
          // Permission cards
          PermissionCard(
            icon: Icons.bluetooth,
            title: 'Bluetooth',
            subtitle: 'Connect to insoles',
            iconColor: const Color(0xFF3B82F6),
            isGranted: _bluetoothGranted,
            onTap: () {
              setState(() {
                _bluetoothGranted = !_bluetoothGranted;
              });
            },
          ),
          const SizedBox(height: 12),
          PermissionCard(
            icon: Icons.directions_walk,
            title: 'Physical Activity',
            subtitle: 'Track steps & movement',
            iconColor: const Color(0xFFA855F7),
            isGranted: _activityGranted,
            onTap: () {
              setState(() {
                _activityGranted = !_activityGranted;
              });
            },
          ),
          const SizedBox(height: 12),
          PermissionCard(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Goal alerts & warnings',
            iconColor: const Color(0xFFEC4899),
            isGranted: _notificationsGranted,
            onTap: () {
              setState(() {
                _notificationsGranted = !_notificationsGranted;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Page indicator
          SmoothPageIndicator(
            controller: _pageController,
            count: 4,
            effect: ExpandingDotsEffect(
              activeDotColor: const Color(0xFF06B6D4),
              dotColor: const Color(0xFF334155),
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 4,
              spacing: 8,
            ),
          ),
          const SizedBox(height: 24),
          
          // Continue button
          GradientButton(
            text: _currentPage == 3 ? 'Get Started' : 'Continue',
            enabled: _canProceed,
            icon: Icons.arrow_forward,
            onPressed: _nextPage,
          ),
          
          // Back button
          if (_currentPage > 0 && _currentPage < 3) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: _previousPage,
              child: const Text(
                'Back',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

