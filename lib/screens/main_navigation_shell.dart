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

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: Stack(
        children: [
          // Current Screen Indexed Stack (preserves scroll positions)
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
      bottomNavigationBar: Container(
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'Matrix',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore_rounded),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.workspace_premium_outlined),
              activeIcon: Icon(Icons.workspace_premium_rounded),
              label: 'Exclusives',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_input_antenna_outlined),
              activeIcon: Icon(Icons.settings_input_antenna_rounded),
              label: 'Studio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
