import 'package:flutter/material.dart';

class GoalsScreen extends StatelessWidget {
  final VoidCallback onBack;

  const GoalsScreen({
    super.key,
    required this.onBack,
  });

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
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                    color: const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Goals & Progress',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          'Track your achievements',
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

              // Current Streak
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFF59E0B).withOpacity(0.2),
                      const Color(0xFFEC4899).withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Color(0xFFF59E0B),
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '14 Day Streak',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Keep it up! You\'re on fire 🔥',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF94A3B8),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Weight Goal
              Text(
                'Weight Goal',
                style: Theme.of(context).textTheme.titleLarge,
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF94A3B8),
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '185 lbs',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: const Color(0xFF06B6D4),
                                  ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.arrow_forward,
                          color: Color(0xFF94A3B8),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Target',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF94A3B8),
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '175 lbs',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: const Color(0xFF22C55E),
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: 0.65,
                        minHeight: 8,
                        backgroundColor: const Color(0xFF334155),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF22C55E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '65% Complete • 10 lbs to go',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF94A3B8),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Daily Steps Goal
              Text(
                'Daily Steps Goal',
                style: Theme.of(context).textTheme.titleLarge,
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '8,547 / 10,000 steps',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '85%',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: const Color(0xFFA855F7),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: 0.85,
                        minHeight: 8,
                        backgroundColor: const Color(0xFF334155),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFA855F7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // AI Verification Insights
              Text(
                'AI Verification Insights',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
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
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF06B6D4).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Verification Rate',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xFF94A3B8),
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '98.5%',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: const Color(0xFF22C55E),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFF334155)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _VerificationStat(
                          label: 'Verified',
                          value: '142',
                          color: const Color(0xFF22C55E),
                        ),
                        _VerificationStat(
                          label: 'Suspicious',
                          value: '2',
                          color: const Color(0xFFF59E0B),
                        ),
                        _VerificationStat(
                          label: 'Flagged',
                          value: '0',
                          color: const Color(0xFFEF4444),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Flagged Sessions
              Text(
                'Flagged Sessions',
                style: Theme.of(context).textTheme.titleLarge,
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
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF22C55E),
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No Flagged Sessions',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Keep up the honest work!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF94A3B8),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Achievement Badges
              Text(
                'Achievement Badges',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _AchievementBadge(
                    icon: Icons.directions_walk,
                    label: 'First Steps',
                    isUnlocked: true,
                  ),
                  _AchievementBadge(
                    icon: Icons.local_fire_department,
                    label: '7 Day Streak',
                    isUnlocked: true,
                  ),
                  _AchievementBadge(
                    icon: Icons.emoji_events,
                    label: '10K Steps',
                    isUnlocked: true,
                  ),
                  _AchievementBadge(
                    icon: Icons.verified,
                    label: '100% Verified',
                    isUnlocked: true,
                  ),
                  _AchievementBadge(
                    icon: Icons.fitness_center,
                    label: 'Weight Goal',
                    isUnlocked: false,
                  ),
                  _AchievementBadge(
                    icon: Icons.stars,
                    label: '30 Day Streak',
                    isUnlocked: false,
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

class _VerificationStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _VerificationStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
              ),
        ),
        const SizedBox(height: 4),
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

class _AchievementBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isUnlocked;

  const _AchievementBadge({
    required this.icon,
    required this.label,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked
            ? const Color(0xFF06B6D4).withOpacity(0.2)
            : const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked
              ? const Color(0xFF06B6D4)
              : const Color(0xFF334155).withOpacity(0.5),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isUnlocked ? const Color(0xFF06B6D4) : const Color(0xFF475569),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isUnlocked ? Colors.white : const Color(0xFF475569),
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

