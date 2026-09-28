import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/paywall_modal.dart';
import '../widgets/video_player_modal.dart';
import 'creator_profile_screen.dart';
import 'creator_studio_screen.dart';
import 'discovery_map_screen.dart';
import 'exclusives_screen.dart';
import 'home_screen.dart';
import 'live_cams_screen.dart';
import 'profile_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    LiveCamsScreen(),
    DiscoveryMapScreen(),
    ExclusivesScreen(),
    CreatorStudioScreen(),
    ProfileScreen(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(Icons.home_outlined, Icons.home_filled, 'Home'),
    _NavItem(Icons.grid_view_outlined, Icons.grid_view_rounded, 'Live Matrix'),
    _NavItem(Icons.explore_outlined, Icons.explore_rounded, 'Tactical Map'),
    _NavItem(Icons.workspace_premium_outlined, Icons.workspace_premium_rounded, 'Exclusives'),
    _NavItem(Icons.settings_input_antenna_outlined, Icons.settings_input_antenna_rounded, 'Creator Studio'),
    _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile & Wallet'),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDesktop = MediaQuery.of(context).size.width >= 850;

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: Stack(
        children: [
          if (isDesktop)
            Row(
              children: [
                // Desktop Left Sidebar
                _buildDesktopSidebar(context, appState),
                const VerticalDivider(width: 1, color: AppTheme.border),
                // Main Content
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _screens,
                  ),
                ),
              ],
            )
          else
            // Mobile Content
            IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),

          // Global Video Player Modal Overlay
          if (appState.activeVideo != null)
            Positioned.fill(
              child: VideoPlayerModal(video: appState.activeVideo!),
            ),

          // Global Paywall Modal Overlay
          if (appState.paywallVideo != null)
            Positioned.fill(
              child: PaywallModal(video: appState.paywallVideo!),
            ),

          // Global Creator Profile Modal Overlay
          if (appState.selectedCreator != null)
            Positioned.fill(
              child: CreatorProfileScreen(creator: appState.selectedCreator!),
            ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : _buildMobileBottomBar(),
    );
  }

  Widget _buildDesktopSidebar(BuildContext context, AppState appState) {
    return Container(
      width: 250,
      color: AppTheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryAmber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.primaryAmber.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.pets, size: 20, color: AppTheme.primaryAmber),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'SAVANNAH',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryAmber,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          'SERENGETI NOCTURNE',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Pulse status pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.liveCrimson.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.fiber_manual_record, color: AppTheme.liveCrimson, size: 8),
                      SizedBox(width: 6),
                      Text(
                        '8 BROADCASTS LIVE',
                        style: TextStyle(color: AppTheme.liveCrimson, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),

          // Nav Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = _currentIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _currentIndex = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryAmber.withValues(alpha: 0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryAmber.withValues(alpha: 0.4) : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected ? AppTheme.primaryAmberLight : AppTheme.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            item.label,
                            style: TextStyle(
                              color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                          if (isSelected) ...[
                            const Spacer(),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryAmber,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Sidebar Bottom Wallet Card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.canvas,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'SAV WALLET',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryAmber,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.monetization_on, color: AppTheme.canvas, size: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${appState.currentUser.walletBalance.toInt()} SAV',
                    style: const TextStyle(
                      color: AppTheme.primaryAmberLight,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '≈ \$${(appState.currentUser.walletBalance / 10).toStringAsFixed(2)} USD',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(
          top: BorderSide(color: AppTheme.border, width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.surface,
        selectedItemColor: AppTheme.primaryAmber,
        unselectedItemColor: AppTheme.textSecondary,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        elevation: 0,
        items: _navItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            activeIcon: Icon(item.activeIcon),
            label: item.label.split(' ').first,
          );
        }).toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem(this.icon, this.activeIcon, this.label);
}
