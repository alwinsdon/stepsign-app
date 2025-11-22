import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WalletScreen extends StatefulWidget {
  final VoidCallback onBack;

  const WalletScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final double _stakedAmount = 250.0;
  final double _balance = 12.5;
  bool _isStaking = false;
  final TextEditingController _stakeController = TextEditingController();
  String _selectedTab = 'all';

  final List<Map<String, dynamic>> _transactions = [
    {'id': '0x1a2b...', 'type': 'reward', 'amount': 8.5, 'date': 'Nov 14, 2025', 'status': 'confirmed'},
    {'id': '0x3c4d...', 'type': 'penalty', 'amount': -2.0, 'date': 'Nov 12, 2025', 'status': 'confirmed'},
    {'id': '0x5e6f...', 'type': 'reward', 'amount': 12.0, 'date': 'Nov 11, 2025', 'status': 'confirmed'},
    {'id': '0x7g8h...', 'type': 'stake', 'amount': -250.0, 'date': 'Nov 10, 2025', 'status': 'confirmed'},
    {'id': '0x9i0j...', 'type': 'reward', 'amount': 6.2, 'date': 'Nov 9, 2025', 'status': 'pending'},
  ];

  @override
  void dispose() {
    _stakeController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _selectedTab == 'all'
        ? _transactions
        : _transactions.where((tx) => tx['type'] == _selectedTab).toList();

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
                          'Wallet',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          'STEP Token Management',
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

              // Wallet Address Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFF59E0B).withOpacity(0.1),
                      const Color(0xFFEC4899).withOpacity(0.1),
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
                        Icons.account_balance_wallet,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Wallet Address',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF94A3B8),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '0x742d...9A3f',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontFamily: 'monospace',
                                    ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _copyToClipboard('0x742d...9A3f'),
                                child: const Icon(
                                  Icons.copy,
                                  size: 16,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Balance Overview
              Row(
                children: [
                  Expanded(
                    child: Container(
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
                          const Icon(
                            Icons.lock,
                            color: Color(0xFFF59E0B),
                            size: 20,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Staked',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF94A3B8),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_stakedAmount STEP',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Locked 30 days',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFFF59E0B),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
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
                          const Icon(
                            Icons.account_balance_wallet,
                            color: Color(0xFF22C55E),
                            size: 20,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Available',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF94A3B8),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_balance STEP',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ready to claim',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF22C55E),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _isStaking = true),
                      icon: const Icon(Icons.lock),
                      label: const Text('Stake More'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download),
                      label: const Text('Withdraw'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF94A3B8),
                        side: const BorderSide(color: Color(0xFF334155)),
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stake Modal
              if (_isStaking) ...[
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Stake STEP Tokens',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          IconButton(
                            onPressed: () => setState(() => _isStaking = false),
                            icon: const Icon(Icons.close),
                            color: const Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _stakeController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Amount to Stake',
                          labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                          hintText: '0.00',
                          hintStyle: const TextStyle(color: Color(0xFF475569)),
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
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF334155).withOpacity(0.5),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Smart Contract Details:',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 12),
                            _DetailRow(label: 'Lock Period', value: '30 days'),
                            const SizedBox(height: 8),
                            _DetailRow(label: 'Gas Fee (est.)', value: '0.002 ETH'),
                            const SizedBox(height: 8),
                            _DetailRow(
                              label: 'Penalty for Early Withdrawal',
                              value: '10%',
                              valueColor: const Color(0xFFEF4444),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Confirm Stake'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Smart Contract Info
              Container(
                padding: const EdgeInsets.all(16),
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
                child: Row(
                  children: [
                    const Icon(
                      Icons.shield,
                      color: Color(0xFF06B6D4),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Smart Contract Verified',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: const Color(0xFF06B6D4),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Contract: 0x1a2b...3c4d',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF94A3B8),
                                  fontFamily: 'monospace',
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.open_in_new,
                      size: 16,
                      color: Color(0xFF06B6D4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Transaction Tabs
              Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: 'All',
                      isSelected: _selectedTab == 'all',
                      onTap: () => setState(() => _selectedTab = 'all'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TabButton(
                      label: 'Rewards',
                      isSelected: _selectedTab == 'reward',
                      onTap: () => setState(() => _selectedTab = 'reward'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TabButton(
                      label: 'Penalties',
                      isSelected: _selectedTab == 'penalty',
                      onTap: () => setState(() => _selectedTab = 'penalty'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Transaction History
              Text(
                'Transaction History',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ...List.generate(filteredTransactions.length, (index) {
                final tx = filteredTransactions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TransactionCard(transaction: tx, onCopy: _copyToClipboard),
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF94A3B8),
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: valueColor ?? Colors.white,
              ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
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

class _TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final Function(String) onCopy;

  const _TransactionCard({
    required this.transaction,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final type = transaction['type'] as String;
    final amount = transaction['amount'] as double;
    final isPositive = amount > 0;

    IconData icon;
    Color iconColor;

    switch (type) {
      case 'reward':
        icon = Icons.trending_up;
        iconColor = const Color(0xFF22C55E);
        break;
      case 'penalty':
        icon = Icons.trending_down;
        iconColor = const Color(0xFFEF4444);
        break;
      case 'stake':
        icon = Icons.lock;
        iconColor = const Color(0xFFF59E0B);
        break;
      default:
        icon = Icons.swap_horiz;
        iconColor = const Color(0xFF94A3B8);
    }

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
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type[0].toUpperCase() + type.substring(1),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      transaction['date'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF94A3B8),
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isPositive ? '+' : ''}$amount STEP',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: isPositive ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                        ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: transaction['status'] == 'confirmed'
                          ? const Color(0xFF22C55E).withOpacity(0.2)
                          : const Color(0xFFF59E0B).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: transaction['status'] == 'confirmed'
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFF59E0B),
                      ),
                    ),
                    child: Text(
                      transaction['status'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: transaction['status'] == 'confirmed'
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFF59E0B),
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                transaction['id'],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF475569),
                      fontFamily: 'monospace',
                    ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => onCopy(transaction['id']),
                child: const Icon(
                  Icons.copy,
                  size: 14,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.open_in_new,
                size: 14,
                color: Color(0xFF475569),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

