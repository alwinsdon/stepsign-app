import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'dart:async';
import '../widgets/heatmap_mini.dart';
import '../widgets/gradient_button.dart';
import '../services/storage_service.dart';
import '../services/wallet_service.dart';
import '../services/ble_service.dart';
import '../models/sensor_data.dart';

class DashboardScreen extends StatefulWidget {
  final Function(String) onNavigate;
  final bool isPaired;

  const DashboardScreen({
    super.key,
    required this.onNavigate,
    required this.isPaired,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _steps = 0;
  double _distance = 0.0;
  int _calories = 0;
  int _activeMinutes = 0;
  double _tokenBalance = 0.0;
  String _userName = 'User';
  bool _isLoading = true;
  
  // BLE sensor data
  final BleService _bleService = BleService();
  Map<String, double>? _sensorData;
  StreamSubscription<SensorFrame>? _sensorSubscription;
  
  StreamSubscription<StepCount>? _stepCountStream;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTokenBalance();
    _initPedometer();
    _initBleSubscription();
  }
  
  @override
  void dispose() {
    _stepCountStream?.cancel();
    _sensorSubscription?.cancel();
    super.dispose();
  }
  
  void _initBleSubscription() {
    // Subscribe to BLE sensor data if device is connected
    _sensorSubscription = _bleService.sensorDataStream.listen((frame) {
      if (mounted) {
        setState(() {
          _sensorData = frame.pressureMap;
        });
      }
    });
  }
  
  Future<void> _loadUserData() async {
    final userName = StorageService.userName;
    setState(() {
      _userName = userName ?? 'User';
    });
  }
  
  Future<void> _loadTokenBalance() async {
    final walletAddress = StorageService.walletAddress;
    if (walletAddress != null && walletAddress.isNotEmpty) {
      try {
        final walletData = await WalletService.getWalletBalance(walletAddress);
        setState(() {
          _tokenBalance = (walletData['balance'] ?? 0) / 1000000; // Convert from micro-STEP
          _isLoading = false;
        });
      } catch (e) {
        print('Error loading token balance: $e');
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _initPedometer() {
    _stepCountStream = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: _onStepCountError,
    );
  }
  
  void _onStepCount(StepCount event) {
    setState(() {
      _steps = event.steps;
      // Calculate derived metrics
      _distance = (_steps * 0.762) / 1000; // Average stride ~0.762m, convert to km
      _calories = (_steps * 0.04).round(); // ~0.04 cal per step
      _activeMinutes = (_steps / 100).round(); // Rough estimate
    });
  }
  
  void _onStepCountError(error) {
    print('Pedometer error: $error');
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF94A3B8),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userName,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => widget.onNavigate('settings'),
                    icon: const Icon(Icons.settings_outlined),
                    color: const Color(0xFF94A3B8),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Stats Grid
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.directions_walk,
                      label: 'Steps',
                      value: _steps.toString(),
                      color: const Color(0xFF06B6D4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.timer_outlined,
                      label: 'Active',
                      value: '$_activeMinutes min',
                      color: const Color(0xFFA855F7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.local_fire_department_outlined,
                      label: 'Calories',
                      value: _calories.toString(),
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.straighten_outlined,
                      label: 'Distance',
                      value: '${_distance.toStringAsFixed(1)} km',
                      color: const Color(0xFF22C55E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Daily Goal Progress
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daily Goal',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${((_steps / 10000) * 100).clamp(0, 100).toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: const Color(0xFF06B6D4),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (_steps / 10000).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: const Color(0xFF334155),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF06B6D4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_steps / 10,000 steps',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF94A3B8),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Live Sensor Preview - Always show for demo
              Text(
                'Live Sensor Preview',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF334155).withOpacity(0.5),
                  ),
                ),
                child: HeatmapMini(
                  isActive: _steps > 0 || _sensorData != null,
                  sensorData: _sensorData,
                ),
              ),
              const SizedBox(height: 32),

              // Wallet Summary
              GestureDetector(
                onTap: () => widget.onNavigate('wallet'),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFF59E0B).withOpacity(0.1),
                        const Color(0xFFF97316).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFF59E0B),
                              Color(0xFFEC4899),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'STEP Token Balance',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF94A3B8),
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isLoading 
                                ? 'Loading...' 
                                : '${_tokenBalance.toStringAsFixed(1)} STEP',
                              style: Theme.of(context).textTheme.titleLarge,
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
              const SizedBox(height: 32),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (!widget.isPaired)
                GradientButton(
                  onPressed: () => widget.onNavigate('pairing'),
                  text: 'Pair Insoles',
                  icon: Icons.bluetooth,
                )
              else ...[
                GradientButton(
                  onPressed: () => widget.onNavigate('live'),
                  text: 'Start Session',
                  icon: Icons.play_arrow,
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => widget.onNavigate('pairing'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    side: const BorderSide(color: Color(0xFF334155)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.settings_outlined, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 8),
                      Text(
                        'Calibrate',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF94A3B8),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // Bottom Navigation Buttons
              Row(
                children: [
                  Expanded(
                    child: _NavButton(
                      icon: Icons.analytics_outlined,
                      label: 'Analytics',
                      onTap: () => widget.onNavigate('analytics'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NavButton(
                      icon: Icons.threed_rotation_outlined,
                      label: '3D View',
                      onTap: () => widget.onNavigate('3d'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _NavButton(
                      icon: Icons.flag_outlined,
                      label: 'Goals',
                      onTap: () => widget.onNavigate('goals'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NavButton(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Wallet',
                      onTap: () => widget.onNavigate('wallet'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF334155).withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF94A3B8),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF334155).withOpacity(0.5),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF06B6D4), size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

