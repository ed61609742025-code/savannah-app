import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wildlife_models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class VideoCard extends StatelessWidget {
  final WildlifeVideo video;

  const VideoCard({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final creator = appState.getCreatorById(video.creatorId);
    final park = appState.getParkById(video.parkId);
    final isUnlocked = appState.isVideoUnlocked(video.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Creator Header Row
          if (creator != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => appState.setSelectedCreator(creator),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.border,
                      backgroundImage: NetworkImage(creator.avatarUrl),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => appState.setSelectedCreator(creator),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                creator.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(width: 4),
                              if (creator.isVerified)
                                const Icon(
                                  Icons.verified,
                                  size: 14,
                                  color: AppTheme.primaryAmber,
                                ),
                            ],
                          ),
                          Text(
                            park != null ? '${park.name} • ${park.flag}' : creator.location,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 20, color: AppTheme.textSecondary),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

          // Video Thumbnail Viewport
          GestureDetector(
            onTap: () {
              if (video.isExclusive && !isUnlocked) {
                appState.setPaywallVideo(video);
              } else {
                appState.setActiveVideo(video);
              }
            },
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.zero,
                    child: Image.network(
                      video.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppTheme.surfaceContainer,
                        child: const Center(
                          child: Icon(Icons.landscape, color: AppTheme.textDisabled, size: 48),
                        ),
                      ),
                    ),
                  ),
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                ),
                // Live / Exclusive Status Badges
                Positioned(
                  top: 10,
                  left: 10,
                  child: Row(
                    children: [
                      if (video.isLive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.liveCrimson,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.fiber_manual_record, color: Colors.white, size: 10),
                              SizedBox(width: 4),
                              Text(
                                '24/7 LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (video.isExclusive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isUnlocked ? AppTheme.secondaryEmerald : AppTheme.primaryAmber,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isUnlocked ? Icons.check_circle : Icons.lock,
                                color: Colors.black,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isUnlocked ? 'UNLOCKED PASS' : 'PPV • \$${video.exclusivePrice?.toStringAsFixed(2) ?? "4.99"}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // Duration / Telemetry Badge
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.border, width: 0.5),
                    ),
                    child: Text(
                      video.duration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Play Button Indicator in center
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.canvas.withValues(alpha: 0.65),
                      border: Border.all(
                        color: video.isExclusive && !isUnlocked
                            ? AppTheme.primaryAmber
                            : Colors.white.withValues(alpha: 0.8),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      video.isExclusive && !isUnlocked ? Icons.lock : Icons.play_arrow,
                      color: video.isExclusive && !isUnlocked
                          ? AppTheme.primaryAmber
                          : Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  video.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                // Species Tags Row
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: video.species.map((s) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border, width: 0.5),
                      ),
                      child: Text(
                        '#$s',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.secondaryEmeraldLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppTheme.border),
                const SizedBox(height: 8),

                // Engagement Action Bar
                Row(
                  children: [
                    // Like button
                    InkWell(
                      onTap: () => appState.likeVideo(video.id),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.favorite_border, size: 18, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${video.likes}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Views
                    Row(
                      children: [
                        const Icon(Icons.visibility_outlined, size: 18, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${video.views}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Tip Ranger Pill Button
                    InkWell(
                      onTap: () {
                        appState.setActiveVideo(video);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryAmber.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.primaryAmber.withValues(alpha: 0.4), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.monetization_on, size: 14, color: AppTheme.primaryAmber),
                            SizedBox(width: 4),
                            Text(
                              'Tip Ranger',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryAmber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
