import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wildlife_models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class ExclusivesScreen extends StatefulWidget {
  const ExclusivesScreen({super.key});

  @override
  State<ExclusivesScreen> createState() => _ExclusivesScreenState();
}

class _ExclusivesScreenState extends State<ExclusivesScreen> {
  String _selectedTab = 'All';

  final List<String> _tabs = ['All', 'Unlocked', 'Predator Hunts', 'River Crossings', 'Primate Encounters'];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final exclusiveVideos = appState.exclusiveVideos;
    final unlockedVideos = exclusiveVideos.where((v) => appState.isVideoUnlocked(v.id)).toList();

    List<WildlifeVideo> displayVideos;
    if (_selectedTab == 'Unlocked') {
      displayVideos = unlockedVideos;
    } else if (_selectedTab == 'Predator Hunts') {
      displayVideos = exclusiveVideos.where((v) => v.species.contains('Lion') || v.species.contains('Leopard')).toList();
    } else if (_selectedTab == 'River Crossings') {
      displayVideos = exclusiveVideos.where((v) => v.species.contains('Wildebeest') || v.title.contains('Crossing')).toList();
    } else if (_selectedTab == 'Primate Encounters') {
      displayVideos = exclusiveVideos.where((v) => v.species.contains('Mountain Gorilla')).toList();
    } else {
      displayVideos = exclusiveVideos;
    }

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
              child: const Icon(Icons.workspace_premium_rounded, color: AppTheme.primaryAmber, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exclusive Expeditions',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
                const Text(
                  'Direct Ranger PPV & Master 4K Archives',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width >= 850 ? 24 : 16,
              vertical: 8,
            ),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // 70/30 Ranger Split Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryAmber.withValues(alpha: 0.15),
                    AppTheme.secondaryEmerald.withValues(alpha: 0.12),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primaryAmber.withValues(alpha: 0.4), width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryAmber,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '70 / 30 CONSERVATION SPLIT',
                          style: TextStyle(
                            color: AppTheme.canvas,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.verified, color: AppTheme.secondaryEmeraldLight, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        'KWS & TANAPA Verified',
                        style: TextStyle(
                          color: AppTheme.secondaryEmeraldLight,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Direct Frontline Community Funding',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '70% of every pass purchase goes directly to the ranger unit in the field for thermal night gear, solar field comms, and anti-poaching patrol stipends.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.3),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _splitMetric(
                        icon: Icons.shield,
                        title: '70% Patrols',
                        subtitle: 'Vehicle fuel & rangers',
                        color: AppTheme.primaryAmberLight,
                      ),
                      const SizedBox(width: 16),
                      _splitMetric(
                        icon: Icons.satellite_alt,
                        title: '30% Infrastructure',
                        subtitle: 'Starlink & ingest servers',
                        color: AppTheme.secondaryEmeraldLight,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab Selector Chips
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  final tab = _tabs[index];
                  final isSelected = _selectedTab == tab;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedTab = tab),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryAmber : AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryAmber : AppTheme.border,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        tab == 'Unlocked' ? 'Unlocked (${unlockedVideos.length})' : tab,
                        style: TextStyle(
                          color: isSelected ? AppTheme.canvas : AppTheme.textPrimary,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Video Cards Grid / List
            if (displayVideos.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const Icon(Icons.lock_clock, size: 48, color: AppTheme.textSecondary),
                    const SizedBox(height: 12),
                    Text(
                      _selectedTab == 'Unlocked' ? 'No unlocked passes yet' : 'No exclusives found',
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Browse premium events below to unlock instant 4K master access.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              )
            else if (MediaQuery.of(context).size.width >= 850)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: (MediaQuery.of(context).size.width - 250) > 1150 ? 3 : 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  mainAxisExtent: 475,
                ),
                itemCount: displayVideos.length,
                itemBuilder: (context, index) {
                  final video = displayVideos[index];
                  final isUnlocked = appState.isVideoUnlocked(video.id);
                  final creator = appState.getCreatorById(video.creatorId);
                  return _buildExclusiveCard(context, video, creator, isUnlocked, appState, isGrid: true);
                },
              )
            else
              ...displayVideos.map((video) {
                final isUnlocked = appState.isVideoUnlocked(video.id);
                final creator = appState.getCreatorById(video.creatorId);

                return _buildExclusiveCard(context, video, creator, isUnlocked, appState);
              }),

            const SizedBox(height: 32),
          ],
        ),
      ),
    ),
  ),
);
  }

  Widget _splitMetric({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9)),
          ],
        ),
      ],
    );
  }

  Widget _buildExclusiveCard(
    BuildContext context,
    WildlifeVideo video,
    Creator? creator,
    bool isUnlocked,
    AppState appState, {
    bool isGrid = false,
  }) {
    final price = video.exclusivePrice ?? 4.99;
    final rangerShare = (price * 0.70).toStringAsFixed(2);

    return Container(
      margin: isGrid ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnlocked ? AppTheme.secondaryEmerald.withValues(alpha: 0.5) : AppTheme.border,
          width: isUnlocked ? 1.5 : 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail with overlay
          GestureDetector(
            onTap: () {
              if (isUnlocked) {
                appState.setActiveVideo(video);
              } else {
                appState.setPaywallVideo(video);
              }
            },
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      video.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(color: AppTheme.surfaceHighlight),
                    ),
                  ),

                  // Dark gradient
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.6),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // Status Tag (Top Left)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isUnlocked ? AppTheme.secondaryEmerald : AppTheme.primaryAmber,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                            color: AppTheme.canvas,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isUnlocked ? 'PASS UNLOCKED' : 'PREMIUM EXPEDITION',
                            style: const TextStyle(
                              color: AppTheme.canvas,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4K Badge (Top Right)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white24, width: 0.5),
                      ),
                      child: const Text(
                        '4K HDR MASTER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Play Button Center
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (isUnlocked ? AppTheme.secondaryEmerald : AppTheme.primaryAmber).withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isUnlocked ? Icons.play_arrow_rounded : Icons.lock_outline_rounded,
                          color: AppTheme.canvas,
                          size: 32,
                        ),
                      ),
                    ),
                  ),

                  // Bottom Duration / Resolution strip
                  Positioned(
                    bottom: 8,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        video.duration,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Details Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  video.title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                // Description
                Text(
                  video.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.3),
                ),
                const SizedBox(height: 10),

                // Creator & Ranger split pill
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: creator != null ? NetworkImage(creator.avatarUrl) : null,
                      backgroundColor: AppTheme.surfaceHighlight,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            creator?.name ?? 'Head Ranger',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            creator?.conservancy ?? 'Conservancy Team',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    // Direct Ranger share tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryEmerald.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.secondaryEmerald.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '+ \$$rangerShare to Ranger Fund',
                        style: const TextStyle(
                          color: AppTheme.secondaryEmeraldLight,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Action Bar
                Row(
                  children: [
                    if (!isUnlocked) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppTheme.primaryAmberLight,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Text(
                            'Or 50 SAV Coins',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => appState.setPaywallVideo(video),
                        icon: const Icon(Icons.lock_open_rounded, size: 16),
                        label: const Text('Unlock Pass'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryAmber,
                          foregroundColor: AppTheme.canvas,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ] else ...[
                      const Icon(Icons.check_circle_rounded, color: AppTheme.secondaryEmeraldLight, size: 18),
                      const SizedBox(width: 6),
                      const Text(
                        'Full 4K Access Active',
                        style: TextStyle(
                          color: AppTheme.secondaryEmeraldLight,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => appState.setActiveVideo(video),
                        icon: const Icon(Icons.play_arrow_rounded, size: 18),
                        label: const Text('Watch Master Replay'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryEmerald,
                          foregroundColor: AppTheme.canvas,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
