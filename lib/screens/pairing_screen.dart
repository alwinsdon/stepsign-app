import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:stepsign_mobile_app/widgets/gradient_button.dart';

class PairingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const PairingScreen({
    super.key,
    required this.onComplete,
    required this.onBack,
  });

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> with SingleTickerProviderStateMixin {
  bool _isScanning = false;
  bool _isConnected = false;
  bool _isCalibrating = false;
  int _calibrationStep = 0;
  String _selectedStreamingMode = '50Hz';
  
  final List<Map<String, dynamic>> _devices = [];
  Map<String, dynamic>? _selectedDevice;
  
  late AnimationController _scanAnimationController;
  Timer? _scanTimer;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    _scanTimer?.cancel();
    super.dispose();
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
      _devices.clear();
    });

    // Simulate device discovery
    _scanTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (_devices.length < 5) {
        setState(() {
          _devices.add({
            'name': 'StepSign ${['Left', 'Right'][_random.nextInt(2)]} #${_devices.length + 1}',
            'rssi': -40 - _random.nextInt(30),
            'battery': 70 + _random.nextInt(30),
            'firmware': 'v1.2.${_random.nextInt(5)}',
          });
        });
      } else {
        _stopScanning();
      }
    });
  }

  void _stopScanning() {
    _scanTimer?.cancel();
    setState(() {
      _isScanning = false;
    });
  }

  void _connectToDevice(Map<String, dynamic> device) {
    setState(() {
      _selectedDevice = device;
      _isConnected = true;
    });
  }

  void _startCalibration() {
    setState(() {
      _isCalibrating = true;
      _calibrationStep = 0;
    });
  }

  void _nextCalibrationStep() {
    if (_calibrationStep < 3) {
      setState(() {
        _calibrationStep++;
      });
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back),
                    color: const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Device Pairing',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          'Connect your smart insoles',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF94A3B8),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              if (!_isConnected) ...[
                // Scanning Section
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_isScanning)
                              AnimatedBuilder(
                                animation: _scanAnimationController,
                                builder: (context, child) {
                                  return Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF06B6D4).withOpacity(
                                          1 - _scanAnimationController.value,
                                        ),
                                        width: 2,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF06B6D4),
                                    Color(0xFFA855F7),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.bluetooth_searching,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _isScanning ? 'Scanning for devices...' : 'Ready to scan',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Scan Button
                if (!_isScanning)
                  GradientButton(
                    onPressed: _startScanning,
                    text: 'Start Scanning',
                    icon: Icons.bluetooth_searching,
                  )
                else
                  OutlinedButton(
                    onPressed: _stopScanning,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Stop Scanning',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFFEF4444),
                          ),
                    ),
                  ),
                const SizedBox(height: 32),

                // Device List
                if (_devices.isNotEmpty) ...[
                  Text(
                    'Available Devices',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_devices.length, (index) {
                    final device = _devices[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
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
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF06B6D4).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
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
                                      device['name'],
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.signal_cellular_alt,
                                          size: 14,
                                          color: _getRSSIColor(device['rssi']),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${device['rssi']} dBm',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: const Color(0xFF94A3B8),
                                              ),
                                        ),
                                        const SizedBox(width: 16),
                                        const Icon(
                                          Icons.battery_std,
                                          size: 14,
                                          color: Color(0xFF22C55E),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${device['battery']}%',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: const Color(0xFF94A3B8),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF94A3B8),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ] else if (!_isCalibrating) ...[
                // Connected Device Info
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF06B6D4).withOpacity(0.1),
                        const Color(0xFFA855F7).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF06B6D4).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF22C55E),
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Connected',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedDevice!['name'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF94A3B8),
                            ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _DeviceInfo(
                            icon: Icons.battery_std,
                            label: 'Battery',
                            value: '${_selectedDevice!['battery']}%',
                            color: const Color(0xFF22C55E),
                          ),
                          _DeviceInfo(
                            icon: Icons.system_update,
                            label: 'Firmware',
                            value: _selectedDevice!['firmware'],
                            color: const Color(0xFF06B6D4),
                          ),
                          _DeviceInfo(
                            icon: Icons.signal_cellular_alt,
                            label: 'Signal',
                            value: '${_selectedDevice!['rssi']} dBm',
                            color: _getRSSIColor(_selectedDevice!['rssi']),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Streaming Mode Selection
                Text(
                  'Streaming Mode',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StreamingModeButton(
                        label: '20Hz',
                        subtitle: 'Battery Saver',
                        isSelected: _selectedStreamingMode == '20Hz',
                        onTap: () => setState(() => _selectedStreamingMode = '20Hz'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StreamingModeButton(
                        label: '50Hz',
                        subtitle: 'Balanced',
                        isSelected: _selectedStreamingMode == '50Hz',
                        onTap: () => setState(() => _selectedStreamingMode = '50Hz'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StreamingModeButton(
                        label: '100Hz',
                        subtitle: 'High Precision',
                        isSelected: _selectedStreamingMode == '100Hz',
                        onTap: () => setState(() => _selectedStreamingMode = '100Hz'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Start Calibration Button
                GradientButton(
                  onPressed: _startCalibration,
                  text: 'Start Calibration',
                  icon: Icons.tune,
                ),
              ] else ...[
                // Calibration Steps
                _CalibrationStep(
                  step: _calibrationStep,
                  onNext: _nextCalibrationStep,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getRSSIColor(int rssi) {
    if (rssi > -50) return const Color(0xFF22C55E);
    if (rssi > -70) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}

class _DeviceInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DeviceInfo({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF94A3B8),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }
}

class _StreamingModeButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _StreamingModeButton({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF06B6D4).withOpacity(0.2)
              : const Color(0xFF1E293B).withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF06B6D4)
                : const Color(0xFF334155).withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isSelected ? const Color(0xFF06B6D4) : Colors.white,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF94A3B8),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CalibrationStep extends StatelessWidget {
  final int step;
  final VoidCallback onNext;

  const _CalibrationStep({
    required this.step,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      {
        'title': 'Stand Normally',
        'description': 'Stand with your feet shoulder-width apart',
        'icon': Icons.person,
      },
      {
        'title': 'Shift to Toes',
        'description': 'Slowly shift your weight forward onto your toes',
        'icon': Icons.arrow_upward,
      },
      {
        'title': 'Shift to Heels',
        'description': 'Slowly shift your weight backward onto your heels',
        'icon': Icons.arrow_downward,
      },
      {
        'title': 'Walk in Place',
        'description': 'Walk in place for 10 seconds',
        'icon': Icons.directions_walk,
      },
    ];

    final currentStep = steps[step];

    return Column(
      children: [
        // Progress Indicator
        Row(
          children: List.generate(4, (index) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                decoration: BoxDecoration(
                  color: index <= step
                      ? const Color(0xFF06B6D4)
                      : const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 32),

        // Step Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF06B6D4),
                Color(0xFFA855F7),
              ],
            ),
          ),
          child: Icon(
            currentStep['icon'] as IconData,
            color: Colors.white,
            size: 64,
          ),
        ),
        const SizedBox(height: 32),

        // Step Info
        Text(
          'Step ${step + 1} of 4',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF94A3B8),
              ),
        ),
        const SizedBox(height: 8),
        Text(
          currentStep['title'] as String,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          currentStep['description'] as String,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF94A3B8),
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),

        // Next Button
        GradientButton(
          onPressed: onNext,
          text: step < 3 ? 'Next Step' : 'Complete Calibration',
          icon: step < 3 ? Icons.arrow_forward : Icons.check,
        ),
      ],
    );
  }
}

