import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wildlife_models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class PaywallModal extends StatefulWidget {
  final WildlifeVideo video;

  const PaywallModal({super.key, required this.video});

  @override
  State<PaywallModal> createState() => _PaywallModalState();
}

class _PaywallModalState extends State<PaywallModal> {
  String _selectedMethod = 'mpesa'; // 'mpesa', 'wallet', 'card'
  final TextEditingController _phoneController = TextEditingController(text: '+254 712 345 678');
  bool _isProcessing = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleCheckout(AppState appState) async {
    setState(() {
      _isProcessing = true;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    final success = appState.unlockVideo(widget.video.id, paymentMethod: _selectedMethod);

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.secondaryEmerald,
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Master 4K Pass Unlocked! 70% sent to rangers.'),
              ],
            ),
          ),
        );
        appState.setActiveVideo(widget.video);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppTheme.liveCrimson,
            content: Text('Insufficient Savannah Wallet balance. Top up or use M-Pesa.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final creator = appState.getCreatorById(widget.video.creatorId);
    final price = widget.video.exclusivePrice ?? 4.99;
    final kesPrice = (price * 130).round();

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Drag Handle
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Modal Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Unlock Cinematic Pass', style: Theme.of(context).textTheme.headlineMedium),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Event Summary Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border, width: 1),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.video.thumbnailUrl,
                      width: 80,
                      height: 55,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.video.title,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          creator != null ? 'Host: ${creator.name}' : 'Wildlife Ranger Special',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${price.toStringAsFixed(2)} USD (~$kesPrice KES)',
                          style: const TextStyle(
                            color: AppTheme.primaryAmber,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Transparent Revenue Split Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Transparent Revenue Split', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                Text('100% Verified Impact', style: TextStyle(color: AppTheme.secondaryEmeraldLight, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),

            // Dual Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Expanded(
                    flex: 70,
                    child: Container(
                      height: 16,
                      color: AppTheme.secondaryEmerald,
                      alignment: Alignment.center,
                      child: const Text(
                        '70% Rangers (\$3.49)',
                        style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 30,
                    child: Container(
                      height: 16,
                      color: AppTheme.primaryAmber,
                      alignment: Alignment.center,
                      child: const Text(
                        '30% Uplink (\$1.50)',
                        style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Impact Statement
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.secondaryEmerald.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.secondaryEmerald.withValues(alpha: 0.3), width: 0.5),
              ),
              child: Row(
                children: const [
                  Icon(Icons.shield_outlined, color: AppTheme.secondaryEmerald, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Direct Impact: 70% goes directly to ranger boots, fuel & GPS elephant collars.',
                      style: TextStyle(color: AppTheme.secondaryEmeraldLight, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Payment Methods
            Text('Select Payment Method', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 10),

            // Option 1: Safaricom M-Pesa
            _buildPaymentOption(
              id: 'mpesa',
              title: 'Safaricom M-Pesa (Kenya)',
              subtitle: 'Instant STK push notification sent to your phone',
              icon: Icons.phone_android,
              iconColor: AppTheme.secondaryEmerald,
              extraWidget: _selectedMethod == 'mpesa'
                  ? Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.border, width: 1),
                      ),
                      child: TextField(
                        controller: _phoneController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '+254 7XX XXX XXX',
                          labelText: 'M-Pesa Phone Number',
                          labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 10),

            // Option 2: Savannah Wallet
            _buildPaymentOption(
              id: 'wallet',
              title: 'Savannah Wallet (🪙 ${appState.currentUser.walletBalance.toInt()} SAV)',
              subtitle: '1-Click instant unlock (${(price * 10).toInt()} SAV)',
              icon: Icons.account_balance_wallet,
              iconColor: AppTheme.primaryAmber,
            ),
            const SizedBox(height: 10),

            // Option 3: Card / Stripe
            _buildPaymentOption(
              id: 'card',
              title: 'Credit / Debit Card (Stripe)',
              subtitle: 'Visa, MasterCard, Google Pay',
              icon: Icons.credit_card,
              iconColor: AppTheme.textPrimary,
            ),
            const SizedBox(height: 24),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryAmber,
                  foregroundColor: AppTheme.canvas,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isProcessing ? null : () => _handleCheckout(appState),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_outline, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _selectedMethod == 'mpesa'
                                ? 'Complete M-Pesa Checkout • \$${price.toStringAsFixed(2)} (KES $kesPrice)'
                                : 'Unlock Event Pass • \$${price.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Security Footnote
            const Center(
              child: Text(
                '🔒 256-Bit SSL Encrypted • Direct Safaricom Daraja API Bridge',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    Widget? extraWidget,
  }) {
    final isSelected = _selectedMethod == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.surfaceContainer : AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primaryAmber : AppTheme.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? AppTheme.primaryAmber : AppTheme.textSecondary,
                  size: 20,
                ),
              ],
            ),
            ?extraWidget,
          ],
        ),
      ),
    );
  }
}
