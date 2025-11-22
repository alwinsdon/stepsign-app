import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnalyticsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const AnalyticsScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedTimeRange = 'Week';
  int _selectedSensor = 0;
  final _random = math.Random();

  List<Map<String, dynamic>> _generateChartData() {
    return List.generate(24, (index) {
      return {
        'time': index.toString(),
        'heel': 30 + _random.nextDouble() * 40,
        'arch': 20 + _random.nextDouble() * 30,
        'ball': 50 + _random.nextDouble() * 40,
        'toes': 15 + _random.nextDouble() * 25,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _generateChartData();

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
                          'Analytics',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          'Historical pressure data',
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

              // Time Range Selector
              Row(
                children: [
                  Expanded(
                    child: _TimeRangeButton(
                      label: 'Day',
                      isSelected: _selectedTimeRange == 'Day',
                      onTap: () => setState(() => _selectedTimeRange = 'Day'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimeRangeButton(
                      label: 'Week',
                      isSelected: _selectedTimeRange == 'Week',
                      onTap: () => setState(() => _selectedTimeRange = 'Week'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimeRangeButton(
                      label: 'Month',
                      isSelected: _selectedTimeRange == 'Month',
                      onTap: () => setState(() => _selectedTimeRange = 'Month'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Multi-Sensor Chart
              Text(
                'Pressure Over Time',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Container(
                height: 250,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF334155).withOpacity(0.5),
                  ),
                ),
                child: CustomPaint(
                  painter: _MultiLineChartPainter(data: chartData),
                  size: const Size(double.infinity, 210),
                ),
              ),
              const SizedBox(height: 16),

              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _LegendItem(
                    color: const Color(0xFF06B6D4),
                    label: 'Heel',
                  ),
                  _LegendItem(
                    color: const Color(0xFFA855F7),
                    label: 'Arch',
                  ),
                  _LegendItem(
                    color: const Color(0xFFF59E0B),
                    label: 'Ball',
                  ),
                  _LegendItem(
                    color: const Color(0xFF22C55E),
                    label: 'Toes',
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Peak Pressure Alerts
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_outlined,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Peak Pressure Alert',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ball of foot exceeded 85 PSI at 2:45 PM',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF94A3B8),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Individual Sensor Tabs
              Text(
                'Individual Sensors',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SensorTab(
                      label: 'Heel',
                      isSelected: _selectedSensor == 0,
                      onTap: () => setState(() => _selectedSensor = 0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SensorTab(
                      label: 'Arch',
                      isSelected: _selectedSensor == 1,
                      onTap: () => setState(() => _selectedSensor = 1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SensorTab(
                      label: 'Ball',
                      isSelected: _selectedSensor == 2,
                      onTap: () => setState(() => _selectedSensor = 2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SensorTab(
                      label: 'Toes',
                      isSelected: _selectedSensor == 3,
                      onTap: () => setState(() => _selectedSensor = 3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Selected Sensor Stats
              _SensorStatsCard(
                sensorIndex: _selectedSensor,
                data: chartData,
              ),
              const SizedBox(height: 32),

              // Export Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_outlined),
                  label: Text(
                    'Export Data (CSV)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF06B6D4),
                    side: const BorderSide(color: Color(0xFF06B6D4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeRangeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeRangeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
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
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isSelected ? const Color(0xFF06B6D4) : Colors.white,
              ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF94A3B8),
              ),
        ),
      ],
    );
  }
}

class _SensorTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SensorTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF06B6D4).withOpacity(0.2)
              : const Color(0xFF1E293B).withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF06B6D4)
                : const Color(0xFF334155).withOpacity(0.5),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? const Color(0xFF06B6D4) : Colors.white,
              ),
        ),
      ),
    );
  }
}

class _SensorStatsCard extends StatelessWidget {
  final int sensorIndex;
  final List<Map<String, dynamic>> data;

  const _SensorStatsCard({
    required this.sensorIndex,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final sensorNames = ['heel', 'arch', 'ball', 'toes'];
    final sensorName = sensorNames[sensorIndex];
    final values = data.map((d) => d[sensorName] as double).toList();
    final avg = values.reduce((a, b) => a + b) / values.length;
    final max = values.reduce(math.max);
    final min = values.reduce(math.min);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF334155).withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: 'Average',
                value: '${avg.toStringAsFixed(1)} PSI',
                color: const Color(0xFF06B6D4),
              ),
              _StatItem(
                label: 'Peak',
                value: '${max.toStringAsFixed(1)} PSI',
                color: const Color(0xFFEF4444),
              ),
              _StatItem(
                label: 'Minimum',
                value: '${min.toStringAsFixed(1)} PSI',
                color: const Color(0xFF22C55E),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF94A3B8),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
              ),
        ),
      ],
    );
  }
}

class _MultiLineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  _MultiLineChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final sensors = ['heel', 'arch', 'ball', 'toes'];
    final colors = [
      const Color(0xFF06B6D4),
      const Color(0xFFA855F7),
      const Color(0xFFF59E0B),
      const Color(0xFF22C55E),
    ];

    final stepWidth = size.width / (data.length - 1);

    for (int s = 0; s < sensors.length; s++) {
      final paint = Paint()
        ..color = colors[s]
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final path = Path();

      for (int i = 0; i < data.length; i++) {
        final x = i * stepWidth;
        final value = data[i][sensors[s]] as double;
        final y = size.height - (value / 100 * size.height);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);
    }

    // Draw grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFF334155).withOpacity(0.3)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = (size.height / 4) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MultiLineChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}

