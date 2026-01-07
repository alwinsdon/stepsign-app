import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/gradient_button.dart';
import '../widgets/feature_card.dart';
import '../widgets/permission_card.dart';
import '../widgets/heatmap_preview.dart';
import '../services/storage_service.dart';
import '../services/ble_service.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // User profile controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  
  // Permission states
  bool _bluetoothGranted = false;
  bool _activityGranted = false;
  bool _notificationsGranted = false;
  bool _isRequestingPermission = false;
  
  // BLE pairing state
  final BleService _bleService = BleService();
  bool _isScanning = false;
  bool _isPaired = false;

  @override
  void initState() {
    super.initState();
    _loadSavedPermissions();
  }

  Future<void> _loadSavedPermissions() async {
    // First check actual permission status from the system
    final bluetoothStatus = await Permission.bluetoothConnect.status;
    final activityStatus = await Permission.activityRecognition.status;
    final notificationStatus = await Permission.notification.status;
    
    setState(() {
      _bluetoothGranted = bluetoothStatus.isGranted;
      _activityGranted = activityStatus.isGranted;
      _notificationsGranted = notificationStatus.isGranted;
    });
    
    // Update storage with actual permission states
    await StorageService.setBluetoothGranted(_bluetoothGranted);
    await StorageService.setActivityGranted(_activityGranted);
    await StorageService.setNotificationsGranted(_notificationsGranted);
  }

  Future<void> _requestBluetoothPermission() async {
    if (_isRequestingPermission) return;
    
    setState(() => _isRequestingPermission = true);
    
    try {
      // Request Bluetooth permissions (Android 12+ requires multiple)
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse, // Required for BLE scanning on older Android
      ].request();
      
      final granted = statuses[Permission.bluetoothConnect]?.isGranted ?? false;
      
      setState(() => _bluetoothGranted = granted);
      await StorageService.setBluetoothGranted(granted);
    } finally {
      setState(() => _isRequestingPermission = false);
    }
  }

  Future<void> _requestActivityPermission() async {
    if (_isRequestingPermission) return;
    
    setState(() => _isRequestingPermission = true);
    
    try {
      final status = await Permission.activityRecognition.request();
      final granted = status.isGranted;
      
      setState(() => _activityGranted = granted);
      await StorageService.setActivityGranted(granted);
    } finally {
      setState(() => _isRequestingPermission = false);
    }
  }

  Future<void> _requestNotificationPermission() async {
    if (_isRequestingPermission) return;
    
    setState(() => _isRequestingPermission = true);
    
    try {
      final status = await Permission.notification.request();
      final granted = status.isGranted;
      
      setState(() => _notificationsGranted = granted);
      await StorageService.setNotificationsGranted(granted);
    } finally {
      setState(() => _isRequestingPermission = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  bool get _canProceed {
    if (_currentPage == 1) {
      // Profile page - require name at minimum
      return _nameController.text.trim().isNotEmpty;
    }
    if (_currentPage == 4) {
      // Permissions page - require all permissions
      return _bluetoothGranted && _activityGranted && _notificationsGranted;
    }
    if (_currentPage == 5) {
      // Pairing page - require device to be paired (or allow skip)
      return true; // Allow proceeding even without pairing
    }
    return true;
  }

  void _nextPage() async {
    if (_currentPage == 1 && _nameController.text.trim().isNotEmpty) {
      // Save user profile
      await StorageService.setUserName(_nameController.text.trim());
      if (_ageController.text.isNotEmpty) {
        await StorageService.setUserAge(int.tryParse(_ageController.text) ?? 0);
      }
      if (_weightController.text.isNotEmpty) {
        await StorageService.setUserWeight(double.tryParse(_weightController.text) ?? 0);
      }
      if (_heightController.text.isNotEmpty) {
        await StorageService.setUserHeight(double.tryParse(_heightController.text) ?? 0);
      }
    }
    
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentPage == 5) {
      // Complete onboarding
      if (_isPaired) {
        await StorageService.setDevicePaired(true);
      }
      widget.onComplete();
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
                    _buildProfilePage(),
                    _buildVisualizationPage(),
                    _buildAIVerificationPage(),
                    _buildPermissionsPage(),
                    _buildPairingPage(),
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

  Widget _buildProfilePage() {
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
              Icons.person,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          const Text(
            'Create Your Profile',
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
            'Help us personalize your experience',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Name field
          _buildTextField(
            controller: _nameController,
            label: 'Your Name',
            hint: 'Enter your name',
            icon: Icons.person_outline,
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 16),
          
          // Age field
          _buildTextField(
            controller: _ageController,
            label: 'Age',
            hint: 'Enter your age',
            icon: Icons.cake_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          
          // Weight field
          _buildTextField(
            controller: _weightController,
            label: 'Weight (kg)',
            hint: 'Enter your weight',
            icon: Icons.fitness_center,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          
          // Height field
          _buildTextField(
            controller: _heightController,
            label: 'Height (cm)',
            hint: 'Enter your height',
            icon: Icons.height,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          
          // Info text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.info_outline,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This info helps calculate accurate calorie burn and stride length',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFE2E8F0),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF64748B)),
            prefixIcon: Icon(icon, color: const Color(0xFF64748B)),
            filled: true,
            fillColor: const Color(0xFF1E293B).withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFF334155).withOpacity(0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFF334155).withOpacity(0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF06B6D4),
              ),
            ),
          ),
        ),
      ],
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
            onTap: _requestBluetoothPermission,
          ),
          const SizedBox(height: 12),
          PermissionCard(
            icon: Icons.directions_walk,
            title: 'Physical Activity',
            subtitle: 'Track steps & movement',
            iconColor: const Color(0xFFA855F7),
            isGranted: _activityGranted,
            onTap: _requestActivityPermission,
          ),
          const SizedBox(height: 12),
          PermissionCard(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Goal alerts & warnings',
            iconColor: const Color(0xFFEC4899),
            isGranted: _notificationsGranted,
            onTap: _requestNotificationPermission,
          ),
        ],
      ),
    );
  }

  Future<void> _startScan() async {
    if (_isScanning) return;
    
    setState(() => _isScanning = true);
    
    try {
      await _bleService.startScan(timeout: const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Scan error: $e');
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  Future<void> _connectToDevice(DiscoveredDevice device) async {
    try {
      await _bleService.connect(device);
      if (mounted) {
        setState(() => _isPaired = true);
        await StorageService.setDevicePaired(true);
      }
    } catch (e) {
      debugPrint('Connection error: $e');
    }
  }

  Widget _buildPairingPage() {
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
              gradient: LinearGradient(
                colors: _isPaired 
                  ? [const Color(0xFF10B981), const Color(0xFF059669)]
                  : [const Color(0xFF06B6D4), const Color(0xFFA855F7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              _isPaired ? Icons.bluetooth_connected : Icons.bluetooth_searching,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          Text(
            _isPaired ? 'Device Connected!' : 'Pair Your Insoles',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            _isPaired 
              ? 'Your StepSign insoles are ready'
              : 'Connect to your StepSign device',
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          if (_isPaired) ...[
            // Connected device info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF10B981),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _bleService.connectedDeviceName ?? 'StepSign Insole',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Connected and ready',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Scan button
            GradientButton(
              text: _isScanning ? 'Scanning...' : 'Scan for Devices',
              icon: _isScanning ? Icons.hourglass_empty : Icons.search,
              enabled: !_isScanning,
              onPressed: _startScan,
            ),
            const SizedBox(height: 24),
            
            // Device list
            if (_bleService.discoveredDevices.isNotEmpty) ...[
              const Text(
                'Available Devices:',
                style: TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(_bleService.discoveredDevices.length, (index) {
                final device = _bleService.discoveredDevices[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildDeviceCard(device),
                );
              }),
            ] else if (!_isScanning) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF334155).withOpacity(0.5),
                  ),
                ),
                child: Column(
                  children: const [
                    Icon(
                      Icons.bluetooth_disabled,
                      color: Color(0xFF64748B),
                      size: 48,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No devices found',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Make sure your insoles are powered on',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Skip option
            TextButton(
              onPressed: () {
                // Allow skipping pairing
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text(
                'Skip for now',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeviceCard(DiscoveredDevice device) {
    return GestureDetector(
      onTap: () => _connectToDevice(device),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF334155).withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF06B6D4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.bluetooth,
                color: Color(0xFF06B6D4),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name.isNotEmpty ? device.name : 'Unknown Device',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Signal: ${device.rssi} dBm',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF64748B),
            ),
          ],
        ),
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
            count: 6,
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
            text: _currentPage == 5 ? 'Get Started' : 'Continue',
            enabled: _canProceed,
            icon: Icons.arrow_forward,
            onPressed: _nextPage,
          ),
          
          // Back button
          if (_currentPage > 0 && _currentPage < 5) ...[
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

