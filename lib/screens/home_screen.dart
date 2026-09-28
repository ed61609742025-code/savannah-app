import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Sticky App Header with Search & Wallet
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  children: [
                    // Brand Row
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

                    // Search Field
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: AppTheme.textSecondary, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: const InputDecoration(
                                hintText: 'Search parks, predators, rangers...',
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
                              child: const Icon(Icons.close, size: 16, color: AppTheme.textSecondary),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Creator Stories Bar
            SliverToBoxAdapter(
              child: SizedBox(
                height: 86,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                              width: 58,
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
            ),

            // Hero 24/7 Featured Live Stream Card
            if (featuredLive != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Container(
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
                              Text(
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
                  ),
                ),
              ),

            // Category Filter Pills
            SliverToBoxAdapter(
              child: SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = appState.selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => appState.setCategory(cat),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryAmber : AppTheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryAmber : AppTheme.border,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppTheme.canvas : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Video Feed List
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
    );
  }
}
