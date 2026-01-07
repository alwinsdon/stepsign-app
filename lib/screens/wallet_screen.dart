import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

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
  // Default wallet address (can be overridden by user)
  static const String _defaultWalletAddress = '0x1dc9a65345a98cba3437f1b6c6ef8d81d6c7f3e24e6bd942e20f26c41d7c08f4';
  
  String _walletAddress = _defaultWalletAddress;
  String _shortAddress = '';
  
  double _balance = 0.0;
  double _totalEarned = 0.0;
  int _claimCount = 0;
  int _pendingClaims = 0;
  bool _isLoading = true;
  bool _hasError = false;
  String _selectedTab = 'all';
  List<dynamic> _claims = [];

  @override
  void initState() {
    super.initState();
    _loadWalletAddress();
  }

  Future<void> _loadWalletAddress() async {
    // Load saved wallet address or use default
    final savedAddress = StorageService.walletAddress;
    _walletAddress = savedAddress ?? _defaultWalletAddress;
    _updateShortAddress();
    await _loadWalletData();
  }

  void _updateShortAddress() {
    if (_walletAddress.length > 12) {
      _shortAddress = '${_walletAddress.substring(0, 8)}...${_walletAddress.substring(_walletAddress.length - 4)}';
    } else {
      _shortAddress = _walletAddress;
    }
  }

  Future<void> _loadWalletData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Fetch wallet info
      final walletInfo = await ApiService.getWalletInfo(_walletAddress);
      
      // Fetch claims
      final claims = await ApiService.getWalletClaims(_walletAddress);

      if (walletInfo != null) {
        setState(() {
          _balance = (walletInfo['balance'] ?? 0).toDouble();
          _totalEarned = (walletInfo['totalEarned'] ?? 0).toDouble();
          _claimCount = walletInfo['claimCount'] ?? 0;
          _pendingClaims = walletInfo['pendingClaims'] ?? 0;
          _claims = claims ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading wallet data: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _showEditWalletDialog() async {
    final controller = TextEditingController(text: _walletAddress);
    
    final newAddress = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Edit Wallet Address'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter Sui wallet address',
            hintStyle: TextStyle(color: Color(0xFF64748B)),
          ),
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    
    if (newAddress != null && newAddress.isNotEmpty && newAddress != _walletAddress) {
      await StorageService.setWalletAddress(newAddress);
      setState(() {
        _walletAddress = newAddress;
        _updateShortAddress();
      });
      await _loadWalletData();
    }
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

  List<dynamic> get _filteredClaims {
    if (_selectedTab == 'all') return _claims;
    if (_selectedTab == 'completed') {
      return _claims.where((c) => c['status'] == 'completed').toList();
    }
    if (_selectedTab == 'pending') {
      return _claims.where((c) => c['status'] == 'pending' || c['status'] == 'approved').toList();
    }
    return _claims;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadWalletData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                            'STEP Token Balance',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF94A3B8),
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _loadWalletData,
                      icon: _isLoading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                      color: const Color(0xFF06B6D4),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Error State
                if (_hasError && !_isLoading) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cannot connect to backend',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: const Color(0xFFEF4444),
                                    ),
                              ),
                              Text(
                                'Make sure backend is running on localhost:3000',
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
                  const SizedBox(height: 24),
                ],

                // Wallet Address Card
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
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF06B6D4).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/step_token_logo.png',
                            width: 48,
                            height: 48,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to icon if image not found
                              return Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF06B6D4),
                                      Color(0xFFA855F7),
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Sui Testnet',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: const Color(0xFF22C55E),
                                      ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF22C55E),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _shortAddress,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontFamily: 'monospace',
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _copyToClipboard(_walletAddress),
                                  child: const Icon(
                                    Icons.copy,
                                    size: 16,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: _showEditWalletDialog,
                                  child: const Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: Color(0xFF06B6D4),
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

                // Balance Cards
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF22C55E).withOpacity(0.1),
                              const Color(0xFF06B6D4).withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF22C55E).withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.asset(
                                      'assets/images/step_token_logo.png',
                                      width: 20,
                                      height: 20,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.account_balance_wallet,
                                          color: Color(0xFF22C55E),
                                          size: 20,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'STEP Balance',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: const Color(0xFF94A3B8),
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _isLoading
                                ? const SizedBox(
                                    height: 32,
                                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                  )
                                : Text(
                                    '${_balance.toStringAsFixed(0)} STEP',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          color: const Color(0xFF22C55E),
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                            const SizedBox(height: 4),
                            Text(
                              'Current Balance',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF94A3B8),
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
                            Row(
                              children: [
                                const Icon(
                                  Icons.receipt_long,
                                  color: Color(0xFFF59E0B),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Claims',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: const Color(0xFF94A3B8),
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _isLoading
                                ? const SizedBox(
                                    height: 32,
                                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                  )
                                : Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '$_claimCount',
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      if (_pendingClaims > 0) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF59E0B).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '$_pendingClaims pending',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: const Color(0xFFF59E0B),
                                                  fontSize: 10,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                            const SizedBox(height: 4),
                            Text(
                              'Completed',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF94A3B8),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Total Earned Row
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF334155).withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.trending_up,
                            color: Color(0xFFA855F7),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Total Earned (All Time)',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF94A3B8),
                                ),
                          ),
                        ],
                      ),
                      _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              '${_totalEarned.toStringAsFixed(0)} STEP',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: const Color(0xFFA855F7),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Token Info
                Container(
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
                      Text(
                        'STEP Token Details',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 12),
                      _DetailRow(label: 'Network', value: 'Sui Testnet'),
                      const SizedBox(height: 8),
                      _DetailRow(label: 'Symbol', value: 'STEP'),
                      const SizedBox(height: 8),
                      _DetailRow(label: 'Decimals', value: '6'),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Package',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF94A3B8),
                                ),
                          ),
                          GestureDetector(
                            onTap: () => _copyToClipboard('0x01067c18c1f73d0b7a37950899a36676144c9af18fd0c3a327db6d46fe950ea5'),
                            child: Row(
                              children: [
                                Text(
                                  '0x01067...0ea5',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontFamily: 'monospace',
                                        color: const Color(0xFF06B6D4),
                                      ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.copy, size: 12, color: Color(0xFF06B6D4)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Claims Tabs
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
                        label: 'Completed',
                        isSelected: _selectedTab == 'completed',
                        onTap: () => setState(() => _selectedTab = 'completed'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _TabButton(
                        label: 'Pending',
                        isSelected: _selectedTab == 'pending',
                        onTap: () => setState(() => _selectedTab = 'pending'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Claims History
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Claim History',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${_filteredClaims.length} claims',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF94A3B8),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_filteredClaims.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.inbox_outlined,
                          size: 48,
                          color: Color(0xFF475569),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No claims yet',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: const Color(0xFF94A3B8),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Complete a workout to earn STEP tokens!',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF64748B),
                              ),
                        ),
                      ],
                    ),
                  )
                else
                  ...List.generate(_filteredClaims.length, (index) {
                    final claim = _filteredClaims[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ClaimCard(claim: claim, onCopy: _copyToClipboard),
                    );
                  }),
                const SizedBox(height: 24),
              ],
            ),
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

class _ClaimCard extends StatelessWidget {
  final Map<String, dynamic> claim;
  final Function(String) onCopy;

  const _ClaimCard({
    required this.claim,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final status = claim['status'] as String;
    final steps = claim['steps'] as int;
    final rewardAmount = (claim['reward_amount'] as int) / 1000000; // Convert from base units
    final txDigest = claim['tx_digest'] as String?;
    final createdAt = claim['created_at'] as int;
    
    final date = DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);
    final dateStr = '${date.month}/${date.day}/${date.year}';

    IconData icon;
    Color iconColor;
    Color statusColor;

    switch (status) {
      case 'completed':
        icon = Icons.check_circle;
        iconColor = const Color(0xFF22C55E);
        statusColor = const Color(0xFF22C55E);
        break;
      case 'approved':
        icon = Icons.pending;
        iconColor = const Color(0xFF06B6D4);
        statusColor = const Color(0xFF06B6D4);
        break;
      case 'pending':
        icon = Icons.schedule;
        iconColor = const Color(0xFFF59E0B);
        statusColor = const Color(0xFFF59E0B);
        break;
      case 'rejected':
        icon = Icons.cancel;
        iconColor = const Color(0xFFEF4444);
        statusColor = const Color(0xFFEF4444);
        break;
      default:
        icon = Icons.help;
        iconColor = const Color(0xFF94A3B8);
        statusColor = const Color(0xFF94A3B8);
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
                      '$steps steps',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      dateStr,
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
                    '+${rewardAmount.toStringAsFixed(0)} STEP',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: const Color(0xFF22C55E),
                        ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      status,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: statusColor,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (txDigest != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'TX: ${txDigest.substring(0, 8)}...${txDigest.substring(txDigest.length - 6)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF475569),
                        fontFamily: 'monospace',
                      ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => onCopy(txDigest),
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
        ],
      ),
    );
  }
}
