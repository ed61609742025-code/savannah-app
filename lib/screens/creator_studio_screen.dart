import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../data/mock_data.dart';
import '../models/wildlife_models.dart';
import '../theme/app_theme.dart';

class CreatorStudioScreen extends StatefulWidget {
  const CreatorStudioScreen({super.key});

  @override
  State<CreatorStudioScreen> createState() => _CreatorStudioScreenState();
}

class _CreatorStudioScreenState extends State<CreatorStudioScreen> with SingleTickerProviderStateMixin {
  bool _isBroadcasting = true;
  bool _obscureStreamKey = true;
  String _selectedLens = '600mm Prime';
  String _selectedProtocol = 'RTMP';
  double _availableBalanceKes = 630500.0;
  final List<PayoutRecord> _payouts = List.from(MockData.defaultPayouts);

  late AnimationController _vuController;

  final String _rtmpUrl = 'rtmp://ingest.savannah.live/live';
  final String _streamKey = 'live_sk_mara_9823f982a17bc';

  @override
  void initState() {
    super.initState();
    _vuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _vuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        backgroundColor: AppTheme.canvas,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryAmber.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.settings_input_antenna_rounded, color: AppTheme.primaryAmber, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ranger Creator Studio',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
                const Text(
                  'Ingest Telemetry, Viewfinder & M-Pesa Payouts',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 960;

          if (isDesktop) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Side: Live Broadcast Viewfinder & RTMP Ingest Credentials
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildViewfinderHUD(),
                            const SizedBox(height: 20),
                            _buildIngestCredentialsCard(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Right Side: Telemetry, M-Pesa Cashout & Payout Ledger
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAnalyticsRow(),
                            const SizedBox(height: 20),
                            _buildMpesaEarningsCard(),
                            const SizedBox(height: 20),
                            _buildPayoutLedger(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Live Broadcast Viewfinder Simulation HUD
                _buildViewfinderHUD(),
                const SizedBox(height: 16),

                // 2. Ingest Stream Credentials (RTMP / SRT)
                _buildIngestCredentialsCard(),
                const SizedBox(height: 16),

                // 3. Real-time Livestream Telemetry & Analytics
                _buildAnalyticsRow(),
                const SizedBox(height: 16),

                // 4. Safaricom M-Pesa Cashout & Earnings Card
                _buildMpesaEarningsCard(),
                const SizedBox(height: 16),

                // 5. Past Payout Ledger
                _buildPayoutLedger(),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildViewfinderHUD() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isBroadcasting ? AppTheme.liveCrimson.withValues(alpha: 0.7) : AppTheme.border,
          width: 1.5,
        ),
        boxShadow: _isBroadcasting
            ? [
                BoxShadow(
                  color: AppTheme.liveCrimson.withValues(alpha: 0.2),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // Viewfinder image background
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                'https://images.unsplash.com/photo-1516426122078-c23e76319801?w=900&fit=crop&q=80',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(color: const Color(0xFF141A16)),
              ),
            ),

            // Cinematic HUD Grid & Vignette
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Top HUD Bar: Status, Battery, Starlink, GPS
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _isBroadcasting = !_isBroadcasting),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _isBroadcasting ? AppTheme.liveCrimson : Colors.grey[800],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _isBroadcasting ? 'REC ● ON AIR' : 'STANDBY',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('4K 2160p 60fps', style: TextStyle(color: Colors.white70, fontSize: 10)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.satellite_alt_rounded, color: AppTheme.secondaryEmeraldLight, size: 14),
                      const SizedBox(width: 4),
                      const Text('Starlink 180M', style: TextStyle(color: Colors.white70, fontSize: 10)),
                      const SizedBox(width: 10),
                      const Icon(Icons.battery_charging_full, color: AppTheme.secondaryEmeraldLight, size: 16),
                      const Text('92%', style: TextStyle(color: Colors.white70, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),

            // Center crosshair / framing box
            Center(
              child: Container(
                width: 120,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.primaryAmber.withValues(alpha: 0.5), width: 1),
                ),
                child: Center(
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryAmber,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom HUD: Lens Switcher & Audio Meter
            Positioned(
              bottom: 10,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Lens angle selection
                  Row(
                    children: ['600mm Prime', '24-70mm', 'FLIR Thermal'].map((lens) {
                      final isSel = _selectedLens == lens;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedLens = lens),
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: isSel ? AppTheme.primaryAmber : Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isSel ? AppTheme.primaryAmber : Colors.white24,
                            ),
                          ),
                          child: Text(
                            lens,
                            style: TextStyle(
                              color: isSel ? AppTheme.canvas : Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Animated VU Meter
                  AnimatedBuilder(
                    animation: _vuController,
                    builder: (context, child) {
                      return Row(
                        children: [
                          const Icon(Icons.mic, color: AppTheme.primaryAmberLight, size: 14),
                          const SizedBox(width: 4),
                          Container(
                            width: 50,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: 0.4 + (_vuController.value * 0.5),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppTheme.secondaryEmeraldLight, AppTheme.primaryAmber, AppTheme.liveCrimson],
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngestCredentialsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.router_rounded, color: AppTheme.primaryAmberLight, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'FIELD INGEST CONFIGURATION',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              // Protocol Switcher
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.canvas,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedProtocol,
                    dropdownColor: AppTheme.surface,
                    style: const TextStyle(color: AppTheme.primaryAmberLight, fontSize: 11, fontWeight: FontWeight.bold),
                    items: ['RTMP', 'SRT Caller', 'WebRTC Low Latency'].map((p) {
                      return DropdownMenuItem(value: p, child: Text(p));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedProtocol = val);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Ingest Server URL
          _credentialField(
            label: 'SERVER URL',
            value: _rtmpUrl,
            onCopy: () {
              Clipboard.setData(ClipboardData(text: _rtmpUrl));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('RTMP URL copied to clipboard.')),
              );
            },
          ),
          const SizedBox(height: 10),

          // Stream Key Field
          _credentialField(
            label: 'STREAM KEY',
            value: _obscureStreamKey ? '••••••••••••••••••••••••' : _streamKey,
            obscured: _obscureStreamKey,
            onToggleObscure: () => setState(() => _obscureStreamKey = !_obscureStreamKey),
            onCopy: () {
              Clipboard.setData(ClipboardData(text: _streamKey));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Stream key copied to clipboard.')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _credentialField({
    required String label,
    required String value,
    bool? obscured,
    VoidCallback? onToggleObscure,
    required VoidCallback onCopy,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.canvas,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.border, width: 0.8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              if (onToggleObscure != null)
                IconButton(
                  icon: Icon(obscured! ? Icons.visibility_off : Icons.visibility, size: 16, color: AppTheme.textSecondary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onToggleObscure,
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.copy, size: 16, color: AppTheme.primaryAmberLight),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onCopy,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsRow() {
    return Row(
      children: [
        _analyticsTile('LIVE AUDIENCE', '2,840', '+18% today', AppTheme.secondaryEmeraldLight),
        const SizedBox(width: 10),
        _analyticsTile('SESSION TIPS', '\$840', 'KES 109.2K', AppTheme.primaryAmberLight),
        const SizedBox(width: 10),
        _analyticsTile('AVG WATCH', '38 min', '4K Bitrate 12M', AppTheme.textPrimary),
      ],
    );
  }

  Widget _analyticsTile(String title, String mainValue, String subValue, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(mainValue, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(subValue, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _buildMpesaEarningsCard() {
    final formatter = NumberFormat('#,###');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E3A2B), // Forest green Safaricom tint
            AppTheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.secondaryEmerald.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppTheme.secondaryEmerald,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.phone_android, color: AppTheme.canvas, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'SAFARICOM M-PESA B2C',
                    style: TextStyle(
                      color: AppTheme.secondaryEmeraldLight,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.canvas,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.secondaryEmerald.withValues(alpha: 0.4)),
                ),
                child: const Text('INSTANT CASHOUT', style: TextStyle(color: AppTheme.secondaryEmeraldLight, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('Available Creator Earnings', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'KES ${formatter.format(_availableBalanceKes)}',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '≈ \$${(_availableBalanceKes / 130).toStringAsFixed(2)} USD',
                style: const TextStyle(color: AppTheme.primaryAmberLight, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => _showMpesaCashoutModal(context),
            icon: const Icon(Icons.arrow_circle_up_rounded, size: 20),
            label: const Text('1-Click Payout to M-Pesa Phone'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryEmerald,
              foregroundColor: AppTheme.canvas,
              minimumSize: const Size(double.infinity, 46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutLedger() {
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SAFARICOM DISBURSEMENT LEDGER',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ..._payouts.map((payout) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.canvas,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border, width: 0.6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppTheme.secondaryEmeraldLight, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            payout.reference,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${payout.phone} • ${dateFormat.format(payout.date)}',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'KES ${NumberFormat('#,###').format(payout.amountKes)}',
                        style: const TextStyle(
                          color: AppTheme.secondaryEmeraldLight,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${payout.amountUsd.toStringAsFixed(2)} USD',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showMpesaCashoutModal(BuildContext context) {
    final phoneController = TextEditingController(text: '+254 712 345 678');
    final amountController = TextEditingController(text: '100000');
    bool isProcessing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryEmerald.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send_to_mobile, color: AppTheme.secondaryEmeraldLight, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Safaricom M-Pesa B2C Cashout', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('Instant disbursement to registered phone', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Phone Input
                  const Text('SAFARICOM PHONE NUMBER', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: phoneController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.canvas,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.border)),
                      prefixIcon: const Icon(Icons.phone, color: AppTheme.textSecondary, size: 18),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Amount Input
                  const Text('CASHOUT AMOUNT (KES)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.canvas,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.border)),
                      prefixText: 'KES ',
                      prefixStyle: const TextStyle(color: AppTheme.primaryAmberLight, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Preset chips
                  Row(
                    children: [50000, 100000, 250000].map((amt) {
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            amountController.text = amt.toString();
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.canvas,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Text(
                            'KES ${amt ~/ 1000}K',
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: isProcessing
                        ? null
                        : () async {
                            final kesAmount = double.tryParse(amountController.text) ?? 100000.0;
                            if (kesAmount > _availableBalanceKes) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Amount exceeds available balance!')),
                              );
                              return;
                            }

                            setModalState(() => isProcessing = true);
                            await Future.delayed(const Duration(seconds: 2));

                            setState(() {
                              _availableBalanceKes -= kesAmount;
                              _payouts.insert(
                                0,
                                PayoutRecord(
                                  id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
                                  amountUsd: kesAmount / 130,
                                  amountKes: kesAmount,
                                  phone: phoneController.text,
                                  status: 'Completed',
                                  date: DateTime.now(),
                                  reference: 'RF${math.Random().nextInt(900000) + 100000}TZ',
                                ),
                              );
                            });

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppTheme.surface,
                                  content: Text(
                                    'Disbursed KES ${NumberFormat('#,###').format(kesAmount)} to ${phoneController.text} via Safaricom Daraja B2C!',
                                    style: const TextStyle(color: AppTheme.secondaryEmeraldLight),
                                  ),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryEmerald,
                      foregroundColor: AppTheme.canvas,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: AppTheme.canvas, strokeWidth: 2),
                          )
                        : const Text('Execute Safaricom Daraja B2C Transfer', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
