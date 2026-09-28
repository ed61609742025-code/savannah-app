import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wildlife_models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/video_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final featuredLive = appState.liveStreams.isNotEmpty ? appState.liveStreams.first : null;
    final categories = ['All', 'Live 24/7', 'Migration', 'Predators', 'Sanctuaries', 'Primates'];

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 850;
    // On desktop, account for the 250px left sidebar
    final availableWidth = isDesktop ? screenWidth - 250 : screenWidth;
    final crossAxisCount = availableWidth > 1150 ? 3 : 2;

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: CustomScrollView(
              slivers: [
                // Top Header / Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isDesktop ? 24 : 16,
                      isDesktop ? 20 : 12,
                      isDesktop ? 24 : 16,
                      12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // On Mobile show Brand Row; on Desktop show clean top bar
                        if (!isDesktop) ...[
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryAmber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.primaryAmber.withValues(alpha: 0.3), width: 1),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.pets, size: 14, color: AppTheme.primaryAmber),
                                    SizedBox(width: 4),
                                    Text(
                                      'SAVANNAH',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.primaryAmber,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Live Pulse Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.liveCrimson.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.fiber_manual_record, color: AppTheme.liveCrimson, size: 8),
                                    SizedBox(width: 4),
                                    Text(
                                      '8 CAMS LIVE',
                                      style: TextStyle(
                                        color: AppTheme.liveCrimson,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              // Wallet Balance Chip
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppTheme.border, width: 1),
                                ),
                                child: Row(
                                  children: [
                                    const Text('🪙', style: TextStyle(fontSize: 12)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${appState.currentUser.walletBalance.toInt()} SAV',
                                      style: const TextStyle(
                                        color: AppTheme.primaryAmber,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.notifications_none, color: AppTheme.textPrimary, size: 22),
                                onPressed: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Search Bar & Quick Actions
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 46,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.border, width: 1),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        style: const TextStyle(color: Colors.white, fontSize: 13),
                                        decoration: const InputDecoration(
                                          hintText: 'Search parks, predators, rangers, live streams...',
                                          hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                          border: InputBorder.none,
                                          isDense: true,
                                        ),
                                        onChanged: (val) => appState.setSearchQuery(val),
                                      ),
                                    ),
                                    if (appState.searchQuery.isNotEmpty)
                                      GestureDetector(
                                        onTap: () => appState.setSearchQuery(''),
                                        child: const Icon(Icons.close, size: 18, color: AppTheme.textSecondary),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            if (isDesktop) ...[
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.liveCrimson.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppTheme.liveCrimson.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.fiber_manual_record, color: AppTheme.liveCrimson, size: 8),
                                    SizedBox(width: 6),
                                    Text(
                                      '8 LIVE BROADCASTS',
                                      style: TextStyle(
                                        color: AppTheme.liveCrimson,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary),
                                tooltip: 'Refresh Feeds',
                                onPressed: () {},
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Creator Stories Bar
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isDesktop)
                        const Padding(
                          padding: EdgeInsets.fromLTRB(24, 6, 24, 10),
                          child: Text(
                            'FIELD RANGERS & RESEARCHERS',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      SizedBox(
                        height: 86,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
                          itemCount: appState.creators.length,
                          itemBuilder: (context, index) {
                            final creator = appState.creators[index];
                            return GestureDetector(
                              onTap: () => appState.setSelectedCreator(creator),
                              child: Container(
                                margin: const EdgeInsets.only(right: 14),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(2.5),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: index == 0 ? AppTheme.liveCrimson : AppTheme.primaryAmber,
                                          width: 2,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 24,
                                        backgroundImage: NetworkImage(creator.avatarUrl),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    SizedBox(
                                      width: 60,
                                      child: Text(
                                        creator.name.split(' ').first,
                                        style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Hero 24/7 Featured Live Stream Card
                if (featuredLive != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        isDesktop ? 24 : 16,
                        12,
                        isDesktop ? 24 : 16,
                        18,
                      ),
                      child: isDesktop
                          ? _buildDesktopFeaturedHero(context, appState, featuredLive)
                          : _buildMobileFeaturedHero(context, appState, featuredLive),
                    ),
                  ),

                // Category Filter Pills
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = appState.selectedCategory == cat;
                        return GestureDetector(
                          onTap: () => appState.setCategory(cat),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryAmber : AppTheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryAmber : AppTheme.border,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppTheme.canvas : AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 18)),

                // Video Feed: Responsive Multi-Column Grid on Desktop, Single-Column List on Mobile
                if (isDesktop)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        mainAxisExtent: 475,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final video = appState.filteredVideos[index];
                          return VideoCard(video: video);
                        },
                        childCount: appState.filteredVideos.length,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final video = appState.filteredVideos[index];
                          return VideoCard(video: video);
                        },
                        childCount: appState.filteredVideos.length,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 60)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Desktop Sleek Horizontal Hero Card
  Widget _buildDesktopFeaturedHero(BuildContext context, AppState appState, WildlifeVideo featuredLive) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryAmber.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryAmber.withValues(alpha: 0.08),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: 16:9 Video Preview with Play Target
          Expanded(
            flex: 6,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  featuredLive.thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(color: AppTheme.surfaceContainer),
                ),
                // Gradient Scrim
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        AppTheme.surface.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
                // Red Live Badge
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.liveCrimson,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.fiber_manual_record, color: Colors.white, size: 8),
                        SizedBox(width: 5),
                        Text(
                          '24/7 LIVE BROADCAST',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
                // Center Play Target
                Center(
                  child: GestureDetector(
                    onTap: () => appState.setActiveVideo(featuredLive),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.canvas.withValues(alpha: 0.8),
                        border: Border.all(color: AppTheme.primaryAmber, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryAmber.withValues(alpha: 0.3),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: AppTheme.primaryAmber, size: 40),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right: Feed Details, Viewers & Action
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryAmber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'FEATURED SANCTUARY FEED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryAmber,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.visibility, color: Colors.white70, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  '${featuredLive.views} watching',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        featuredLive.title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        featuredLive.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: featuredLive.species.map((s) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.border, width: 0.5),
                            ),
                            child: Text(
                              '#$s',
                              style: const TextStyle(fontSize: 10, color: AppTheme.secondaryEmeraldLight, fontWeight: FontWeight.w600),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.videocam_rounded, size: 20),
                      label: const Text('Watch Live Stream in 4K', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryAmber,
                        foregroundColor: AppTheme.canvas,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => appState.setActiveVideo(featuredLive),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Mobile Stacked Hero Card
  Widget _buildMobileFeaturedHero(BuildContext context, AppState appState, WildlifeVideo featuredLive) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryAmber.withValues(alpha: 0.4), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Viewport
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  featuredLive.thumbnailUrl,
                  fit: BoxFit.cover,
                ),
              ),
              // Red Live Badge
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.liveCrimson,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.fiber_manual_record, color: Colors.white, size: 8),
                      SizedBox(width: 4),
                      Text('24/7 LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              // Viewer Counter
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${featuredLive.views} watching',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              // Center Play Target
              Positioned.fill(
                child: Center(
                  child: GestureDetector(
                    onTap: () => appState.setActiveVideo(featuredLive),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.canvas.withValues(alpha: 0.7),
                        border: Border.all(color: AppTheme.primaryAmber, width: 2),
                      ),
                      child: const Icon(Icons.play_arrow, color: AppTheme.primaryAmber, size: 32),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Details & Jump into stream
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FEATURED SANCTUARY FEED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryAmber,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  featuredLive.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  featuredLive.description,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.videocam, size: 18),
                    label: const Text('Watch Live Stream'),
                    onPressed: () => appState.setActiveVideo(featuredLive),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
