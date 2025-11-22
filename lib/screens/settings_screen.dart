import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const SettingsScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _developerMode = false;
  bool _notificationsEnabled = true;
  bool _hapticFeedback = true;
  String _aiModelMode = 'on-device';
  bool _colorBlindMode = false;
  double _samplingRate = 50;
  String _dominantFoot = 'left';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back),
                      color: const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),

              // Tabs
              const TabBar(
                labelColor: Color(0xFF06B6D4),
                unselectedLabelColor: Color(0xFF94A3B8),
                indicatorColor: Color(0xFF06B6D4),
                tabs: [
                  Tab(text: 'Profile'),
                  Tab(text: 'App'),
                  Tab(icon: Icon(Icons.code)),
                ],
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  children: [
                    _buildProfileTab(),
                    _buildAppTab(),
                    _buildDeveloperTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
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
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF06B6D4),
                            Color(0xFFA855F7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alex Thompson',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            'alex@example.com',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF94A3B8),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _InputField(label: 'Weight (lbs)', defaultValue: '185'),
                const SizedBox(height: 16),
                _InputField(label: 'Height (inches)', defaultValue: '70'),
                const SizedBox(height: 16),
                _InputField(label: 'Shoe Size (US)', defaultValue: '10.5'),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dominant Foot',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF94A3B8),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _FootButton(
                            label: 'Left',
                            isSelected: _dominantFoot == 'left',
                            onTap: () => setState(() => _dominantFoot = 'left'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FootButton(
                            label: 'Right',
                            isSelected: _dominantFoot == 'right',
                            onTap: () => setState(() => _dominantFoot = 'right'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
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
                Text(
                  'Gait Baseline',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stride Length',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF94A3B8),
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '28.5 in',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: const Color(0xFF06B6D4),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cadence',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF94A3B8),
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '165 spm',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: const Color(0xFFA855F7),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF94A3B8),
                      side: const BorderSide(color: Color(0xFF334155)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Recalibrate Gait'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
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
                Row(
                  children: [
                    const Icon(Icons.notifications, color: Color(0xFF06B6D4)),
                    const SizedBox(width: 12),
                    Text(
                      'Notifications',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SettingRow(
                  label: 'Push Notifications',
                  subtitle: 'Goal alerts & warnings',
                  value: _notificationsEnabled,
                  onChanged: (value) => setState(() => _notificationsEnabled = value),
                ),
                if (_notificationsEnabled) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      children: [
                        _SettingRow(
                          label: 'Goal achievements',
                          value: true,
                          onChanged: (value) {},
                        ),
                        const SizedBox(height: 8),
                        _SettingRow(
                          label: 'Low battery alerts',
                          value: true,
                          onChanged: (value) {},
                        ),
                        const SizedBox(height: 8),
                        _SettingRow(
                          label: 'Pressure warnings',
                          value: true,
                          onChanged: (value) {},
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
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
                Row(
                  children: [
                    const Icon(Icons.vibration, color: Color(0xFFA855F7)),
                    const SizedBox(width: 12),
                    Text(
                      'Haptic Feedback',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SettingRow(
                  label: 'Enable vibration alerts',
                  value: _hapticFeedback,
                  onChanged: (value) => setState(() => _hapticFeedback = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
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
                Row(
                  children: [
                    const Icon(Icons.psychology, color: Color(0xFFEC4899)),
                    const SizedBox(width: 12),
                    Text(
                      'AI Model',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _AIModelButton(
                        label: 'On-Device',
                        subtitle: 'Faster, private',
                        isSelected: _aiModelMode == 'on-device',
                        onTap: () => setState(() => _aiModelMode = 'on-device'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _AIModelButton(
                        label: 'Cloud',
                        subtitle: 'More accurate',
                        isSelected: _aiModelMode == 'cloud',
                        onTap: () => setState(() => _aiModelMode = 'cloud'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF334155).withOpacity(0.5),
              ),
            ),
            child: _SettingRow(
              label: 'Color Blind Mode',
              subtitle: 'Use patterns + numbers',
              value: _colorBlindMode,
              onChanged: (value) => setState(() => _colorBlindMode = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFF59E0B).withOpacity(0.1),
                  const Color(0xFFF97316).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF59E0B).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFFF59E0B)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Developer Mode',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: const Color(0xFFF59E0B),
                            ),
                      ),
                      Text(
                        'Advanced debugging & BLE packet inspection',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF94A3B8),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF334155).withOpacity(0.5),
              ),
            ),
            child: _SettingRow(
              label: 'Enable Developer Mode',
              value: _developerMode,
              onChanged: (value) => setState(() => _developerMode = value),
            ),
          ),
          if (_developerMode) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
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
                  Row(
                    children: [
                      const Icon(Icons.bluetooth, color: Color(0xFF06B6D4)),
                      const SizedBox(width: 12),
                      Text(
                        'BLE Connection Stats',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF22C55E)),
                        ),
                        child: Text(
                          'connected',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF22C55E),
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2,
                    children: [
                      _DevStatCard(label: 'RSSI', value: '-48 dBm', color: const Color(0xFF06B6D4)),
                      _DevStatCard(label: 'MTU Size', value: '512 bytes', color: const Color(0xFFA855F7)),
                      _DevStatCard(label: 'Packet Rate', value: '50 Hz', color: const Color(0xFFEC4899)),
                      _DevStatCard(label: 'Last Packet', value: '12ms ago', color: const Color(0xFF22C55E)),
                      _DevStatCard(label: 'Battery', value: '87%', color: const Color(0xFF22C55E)),
                      _DevStatCard(label: 'Firmware', value: 'v1.2.3', color: const Color(0xFF06B6D4)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
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
                  Text(
                    'Sampling Rate',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Rate',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF94A3B8),
                            ),
                      ),
                      Text(
                        '${_samplingRate.toInt()} Hz',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF06B6D4),
                            ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _samplingRate,
                    onChanged: (value) => setState(() => _samplingRate = value),
                    min: 20,
                    max: 100,
                    divisions: 8,
                    activeColor: const Color(0xFF06B6D4),
                    inactiveColor: const Color(0xFF334155),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '20 Hz',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF475569),
                            ),
                      ),
                      Text(
                        '100 Hz',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF475569),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Higher rates = more accurate, lower battery life',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF94A3B8),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF94A3B8),
                      side: const BorderSide(color: Color(0xFF334155)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Export Logs'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF94A3B8),
                      side: const BorderSide(color: Color(0xFF334155)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Firmware Update'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String defaultValue;

  const _InputField({
    required this.label,
    required this.defaultValue,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: defaultValue),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFF0F172A).withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
      ),
    );
  }
}

class _FootButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FootButton({
    required this.label,
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
              : const Color(0xFF0F172A).withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF06B6D4) : const Color(0xFF334155),
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

class _SettingRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingRow({
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF94A3B8),
                      ),
                ),
              ],
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF06B6D4),
        ),
      ],
    );
  }
}

class _AIModelButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _AIModelButton({
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF06B6D4).withOpacity(0.2)
              : const Color(0xFF0F172A).withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF06B6D4) : const Color(0xFF334155),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
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

class _DevStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DevStatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
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
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

