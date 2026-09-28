import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';
import 'creator_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _lowDataMode = false;
  String _streamQuality = '4K Ultra HD (HDR)';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final supabaseService = context.watch<SupabaseService>();
    final user = appState.currentUser;
    final unlockedVideos = appState.videos.where((v) => appState.isVideoUnlocked(v.id)).toList();
    final followedCreators = appState.creators.where((c) => appState.isFollowingCreator(c.id)).toList();

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        backgroundColor: AppTheme.canvas,
        elevation: 0,
        title: Text(
          'Explorer Profile & Wallet',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Profile Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundImage: NetworkImage(user.avatarUrl),
                        backgroundColor: AppTheme.surfaceHighlight,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.secondaryEmerald,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shield, color: AppTheme.canvas, size: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.verified, color: AppTheme.primaryAmber, size: 16),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.handle,
                          style: const TextStyle(color: AppTheme.primaryAmberLight, fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.canvas,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: const Text(
                            'SAVANNAH GUARDIAN MEMBER',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Supabase Cloud Sync & Account Status Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border, width: 0.8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: supabaseService.isAuthenticated ? AppTheme.secondaryEmeraldLight : AppTheme.primaryAmber,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            supabaseService.isAuthenticated ? 'SUPABASE CLOUD SYNCED' : 'LOCAL EXPLORER MODE',
                            style: TextStyle(
                              color: supabaseService.isAuthenticated ? AppTheme.secondaryEmeraldLight : AppTheme.primaryAmber,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            supabaseService.isAuthenticated ? 'Account: ${supabaseService.userDisplayName}' : 'Guest session (Saved locally)',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                    ),
                    icon: Icon(
                      supabaseService.isAuthenticated ? Icons.logout_rounded : Icons.login_rounded,
                      size: 14,
                      color: AppTheme.primaryAmber,
                    ),
                    label: Text(
                      supabaseService.isAuthenticated ? 'Sign Out' : 'Sign In / Sync',
                      style: const TextStyle(color: AppTheme.primaryAmber, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      if (supabaseService.isAuthenticated) {
                        supabaseService.signOut();
                      } else {
                        _showAuthModal(context, supabaseService, appState);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // SAV Wallet & Conservation Fund Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryAmber.withValues(alpha: 0.18),
                    AppTheme.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryAmber.withValues(alpha: 0.5)),
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
                              color: AppTheme.primaryAmber,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.account_balance_wallet, color: AppTheme.canvas, size: 16),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'SAV COIN WALLET',
                            style: TextStyle(
                              color: AppTheme.primaryAmberLight,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => _showTopUpModal(context, appState),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryAmber,
                          foregroundColor: AppTheme.canvas,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Top Up'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${user.walletBalance.toInt()} SAV',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '≈ \$${(user.walletBalance / 10).toStringAsFixed(2)} USD',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.canvas,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.border, width: 0.8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.eco_rounded, color: AppTheme.secondaryEmeraldLight, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$${user.conservationFundContribution.toStringAsFixed(2)} Funded to Field Patrols',
                                style: const TextStyle(
                                  color: AppTheme.secondaryEmeraldLight,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Generated from your unlocked passes and tips to rangers.',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 9),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Unlocked Passes Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Unlocked Master Passes',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                ),
                Text(
                  '${unlockedVideos.length} passes',
                  style: const TextStyle(color: AppTheme.primaryAmberLight, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (unlockedVideos.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('No unlocked passes yet.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ),
              )
            else
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: unlockedVideos.length,
                  itemBuilder: (context, index) {
                    final video = unlockedVideos[index];
                    return GestureDetector(
                      onTap: () => appState.setActiveVideo(video),
                      child: Container(
                        width: 170,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.secondaryEmerald.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                              child: Stack(
                                children: [
                                  Image.network(
                                    video.thumbnailUrl,
                                    height: 80,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(height: 80, color: AppTheme.surfaceHighlight),
                                  ),
                                  Positioned(
                                    top: 4,
                                    left: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.secondaryEmerald,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'UNLOCKED',
                                        style: TextStyle(color: AppTheme.canvas, fontSize: 8, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                video.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),

            // Followed Rangers Section
            Text(
              'Rangers You Follow (${followedCreators.length})',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
            ),
            const SizedBox(height: 10),
            ...followedCreators.map((creator) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(creator.avatarUrl),
                      backgroundColor: AppTheme.surfaceHighlight,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(creator.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(creator.location, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => CreatorProfileScreen(creator: creator)),
                        );
                      },
                      child: const Text('View Profile', style: TextStyle(color: AppTheme.primaryAmberLight, fontSize: 11)),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),

            // Preferences
            Text(
              'App & Stream Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: AppTheme.primaryAmber,
                    title: const Text('Starlink Low Data Saver', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Reduces stream bitrate when on cellular networks', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    value: _lowDataMode,
                    onChanged: (val) => setState(() => _lowDataMode = val),
                  ),
                  const Divider(color: AppTheme.border),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Default Stream Quality', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: Text(_streamQuality, style: const TextStyle(color: AppTheme.primaryAmberLight, fontSize: 11)),
                    trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.textSecondary, size: 14),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: AppTheme.surface,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                        builder: (context) {
                          return SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: ['4K Ultra HD (HDR)', '1080p 60fps Enhanced', '720p Mobile Fast'].map((q) {
                                return ListTile(
                                  title: Text(q, style: const TextStyle(color: AppTheme.textPrimary)),
                                  trailing: _streamQuality == q ? const Icon(Icons.check, color: AppTheme.primaryAmber) : null,
                                  onTap: () {
                                    setState(() => _streamQuality = q);
                                    Navigator.pop(context);
                                  },
                                );
                              }).toList(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showTopUpModal(BuildContext context, AppState appState) {
    int selectedAmount = 100;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Top Up SAV Coin Balance', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('1 SAV Coin = \$0.10 USD. Used for instant tipping and pass unlocks.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [50, 100, 250, 500].map((amt) {
                        final isSel = selectedAmount == amt;
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedAmount = amt),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSel ? AppTheme.primaryAmber : AppTheme.canvas,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSel ? AppTheme.primaryAmber : AppTheme.border),
                            ),
                            child: Column(
                              children: [
                                Text('$amt SAV', style: TextStyle(color: isSel ? AppTheme.canvas : AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                                Text('\$${(amt / 10).toStringAsFixed(2)}', style: TextStyle(color: isSel ? AppTheme.canvas : AppTheme.textSecondary, fontSize: 10)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        appState.currentUser.walletBalance += selectedAmount;
                        final supabase = Provider.of<SupabaseService>(context, listen: false);
                        supabase.updateCloudBalance(appState.currentUser.walletBalance);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppTheme.surface,
                            content: Text(
                              'Loaded $selectedAmount SAV Coins into your cloud wallet!',
                              style: const TextStyle(color: AppTheme.secondaryEmeraldLight),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryAmber,
                        foregroundColor: AppTheme.canvas,
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Confirm Top Up (+$selectedAmount SAV)', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAuthModal(BuildContext context, SupabaseService supabaseService, AppState appState) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();
    bool isSignUp = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isSignUp ? 'Create Savannah Account' : 'Sign In with Supabase',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Sync your SAV coin wallet, bookmarked feeds, and tier perks across all your devices.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  if (isSignUp) ...[
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Explorer Name',
                        labelStyle: const TextStyle(color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: AppTheme.canvas,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      labelStyle: const TextStyle(color: AppTheme.textSecondary),
                      filled: true,
                      fillColor: AppTheme.canvas,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: AppTheme.textSecondary),
                      filled: true,
                      fillColor: AppTheme.canvas,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryAmber,
                      foregroundColor: AppTheme.canvas,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();
                      if (email.isEmpty || password.isEmpty) return;

                      if (isSignUp) {
                        final name = nameController.text.trim().isEmpty ? 'Explorer' : nameController.text.trim();
                        await supabaseService.signUpWithEmail(email, password, name);
                        appState.currentUser.name = name;
                        appState.currentUser.handle = '@${name.toLowerCase().replaceAll(' ', '_')}';
                      } else {
                        await supabaseService.signInWithEmail(email, password);
                        appState.currentUser.name = supabaseService.userDisplayName;
                      }

                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppTheme.surface,
                            content: Text(
                              'Signed in as ${supabaseService.userDisplayName}! Cloud wallet synced.',
                              style: const TextStyle(color: AppTheme.secondaryEmeraldLight),
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      isSignUp ? 'Create Cloud Account' : 'Sign In',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () => setSheetState(() => isSignUp = !isSignUp),
                      child: Text(
                        isSignUp ? 'Already have an account? Sign In' : 'New to Savannah? Create an Account',
                        style: const TextStyle(color: AppTheme.primaryAmber, fontSize: 12),
                      ),
                    ),
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

