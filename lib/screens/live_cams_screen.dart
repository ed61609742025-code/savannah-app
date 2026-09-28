import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wildlife_models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/video_card.dart';
import '../widgets/live_stream_player.dart';

class LiveCamsScreen extends StatefulWidget {
  const LiveCamsScreen({super.key});

  @override
  State<LiveCamsScreen> createState() => _LiveCamsScreenState();
}

class _LiveCamsScreenState extends State<LiveCamsScreen> {
  bool _isMatrixView = true;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final liveVideos = appState.liveStreams;

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
                color: AppTheme.liveCrimson.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.videocam, color: AppTheme.liveCrimson, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Field Cams',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
                Text(
                  '${liveVideos.length} Broadcasts Active Across East & Southern Africa',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Toggle View Mode (Matrix vs List)
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border, width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: '2x2 Matrix View',
                  icon: Icon(
                    Icons.grid_view_rounded,
                    size: 20,
                    color: _isMatrixView ? AppTheme.primaryAmber : AppTheme.textSecondary,
                  ),
                  onPressed: () => setState(() => _isMatrixView = true),
                ),
                IconButton(
                  tooltip: 'Single Stream Feed',
                  icon: Icon(
                    Icons.view_agenda_rounded,
                    size: 20,
                    color: !_isMatrixView ? AppTheme.primaryAmber : AppTheme.textSecondary,
                  ),
                  onPressed: () => setState(() => _isMatrixView = false),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isMatrixView ? _buildMatrixView(context, appState) : _buildListView(context, appState, liveVideos),
    );
  }

  Widget _buildMatrixView(BuildContext context, AppState appState) {
    final matrixSlotIds = appState.matrixSlots;
    final audioSlot = appState.audioSoloSlot;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Matrix Header & Control Bar
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
                      decoration: const BoxDecoration(
                        color: AppTheme.liveCrimson,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'QUAD-CAM MATRIX (2x2)',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryAmber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.primaryAmber.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.volume_up_rounded, color: AppTheme.primaryAmberLight, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'AUDIO SOLO: CAM ${audioSlot + 1}',
                        style: const TextStyle(
                          color: AppTheme.primaryAmberLight,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 2x2 Video Matrix Grid
          AspectRatio(
            aspectRatio: 1.0, // Square 2x2 container
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                final videoId = index < matrixSlotIds.length ? matrixSlotIds[index] : '';
                final video = appState.getVideoById(videoId);
                final isSoloAudio = audioSlot == index;

                return _buildMatrixTile(
                  context: context,
                  slotIndex: index,
                  video: video,
                  isSoloAudio: isSoloAudio,
                  appState: appState,
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // Audio Solo Selector Pills
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ACTIVE SOUND MONITOR',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(4, (index) {
                    final isSolo = audioSlot == index;
                    final videoId = index < matrixSlotIds.length ? matrixSlotIds[index] : '';
                    final video = appState.getVideoById(videoId);
                    final park = video != null ? appState.getParkById(video.parkId) : null;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => appState.setAudioSoloSlot(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(right: index < 3 ? 6 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: isSolo ? AppTheme.primaryAmber.withValues(alpha: 0.2) : AppTheme.canvas,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSolo ? AppTheme.primaryAmber : AppTheme.border,
                              width: isSolo ? 1.5 : 0.8,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                isSolo ? Icons.graphic_eq_rounded : Icons.volume_mute_rounded,
                                color: isSolo ? AppTheme.primaryAmberLight : AppTheme.textSecondary,
                                size: 16,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'CAM ${index + 1}',
                                style: TextStyle(
                                  color: isSolo ? AppTheme.primaryAmberLight : AppTheme.textPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                park?.name.split(' ').first ?? 'Feed $index',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isSolo ? AppTheme.textPrimary : AppTheme.textSecondary,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Low-Latency Telemetry Strip
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.sensors_rounded, color: AppTheme.secondaryEmeraldLight, size: 16),
                        const SizedBox(width: 6),
                        const Text(
                          'FIELD TELEMETRY & SYNC',
                          style: TextStyle(
                            color: AppTheme.secondaryEmeraldLight,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'STARLINK HIGH-GAIN ARRAY',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _telemetryChip('INGEST PROTOCOL', 'RTMP / LL-HLS'),
                    _telemetryChip('GLASS LATENCY', '390 ms'),
                    _telemetryChip('AVG BITRATE', '6.8 Mbps'),
                    _telemetryChip('FRAME DROP', '0.01%'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Available Cameras to Swap
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Field Feeds',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
              ),
              const Text(
                'Tap to swap into matrix',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: appState.videos.length,
              itemBuilder: (context, index) {
                final vid = appState.videos[index];
                final isAlreadyInMatrix = matrixSlotIds.contains(vid.id);

                return Container(
                  width: 180,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isAlreadyInMatrix ? AppTheme.primaryAmber.withValues(alpha: 0.6) : AppTheme.border,
                      width: isAlreadyInMatrix ? 1.5 : 0.8,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      _showSwapSlotDialog(context, appState, vid.id);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                          child: Stack(
                            children: [
                              Image.network(
                                vid.thumbnailUrl,
                                height: 75,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(height: 75, color: AppTheme.surfaceHighlight),
                              ),
                              if (vid.isLive)
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.liveCrimson,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'LIVE',
                                      style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              if (isAlreadyInMatrix)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryAmber,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'SLOT ACTIVE',
                                      style: TextStyle(color: AppTheme.canvas, fontSize: 8, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(
                            vid.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
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
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMatrixTile({
    required BuildContext context,
    required int slotIndex,
    required WildlifeVideo? video,
    required bool isSoloAudio,
    required AppState appState,
  }) {
    if (video == null) {
      return Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border),
        ),
        child: const Center(
          child: Text('Empty Cam Slot', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        ),
      );
    }

    final creator = appState.getCreatorById(video.creatorId);

    return InkWell(
      onTap: () {
        // Tapping selects solo audio or opens in player modal
        if (!isSoloAudio) {
          appState.setAudioSoloSlot(slotIndex);
        } else {
          appState.setActiveVideo(video);
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSoloAudio ? AppTheme.primaryAmber : AppTheme.border,
            width: isSoloAudio ? 2.0 : 0.8,
          ),
          boxShadow: isSoloAudio
              ? [
                  BoxShadow(
                    color: AppTheme.primaryAmber.withValues(alpha: 0.25),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Live Camera Feed Stream Player
              LiveStreamPlayer(
                videoUrl: video.videoUrl,
                title: video.title,
                cameraRig: video.cameraRig,
                sensorMode: video.sensorMode,
                isMuted: !isSoloAudio,
                autoPlay: true,
                showControls: false,
              ),

              // Gradient protection overlays
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.65),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),

              // Top Bar: Cam label & Solo Audio indicator
              Positioned(
                top: 6,
                left: 6,
                right: 6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppTheme.liveCrimson,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'CAM ${slotIndex + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        if (isSoloAudio)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryAmber,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.volume_up, color: AppTheme.canvas, size: 10),
                          ),
                        const SizedBox(width: 4),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.fullscreen, color: Colors.white70, size: 16),
                          onPressed: () => appState.setActiveVideo(video),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Middle species detection tag
              if (video.species.isNotEmpty)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppTheme.secondaryEmeraldLight.withValues(alpha: 0.7), width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome, color: AppTheme.secondaryEmeraldLight, size: 10),
                        const SizedBox(width: 4),
                        Text(
                          video.species.first,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Bottom Info: Title & Ranger
              Positioned(
                bottom: 6,
                left: 6,
                right: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      video.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            creator?.name ?? 'Ranger',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 8),
                          ),
                        ),
                        Text(
                          '${video.viewersCount} watching',
                          style: const TextStyle(color: AppTheme.primaryAmberLight, fontSize: 8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _telemetryChip(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 8)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildListView(BuildContext context, AppState appState, List<WildlifeVideo> liveVideos) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 32),
      itemCount: liveVideos.length,
      itemBuilder: (context, index) {
        final video = liveVideos[index];
        return VideoCard(video: video);
      },
    );
  }

  void _showSwapSlotDialog(BuildContext context, AppState appState, String videoId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Matrix Slot to Assign',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose which quadrant of the 2x2 grid should switch to this live feed.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Row(
                  children: List.generate(4, (slotIndex) {
                    final currentVid = appState.getVideoById(appState.matrixSlots[slotIndex]);

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          appState.swapMatrixSlot(slotIndex, videoId);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppTheme.surface,
                              content: Text(
                                'Swapped Cam ${slotIndex + 1} feed successfully.',
                                style: const TextStyle(color: AppTheme.primaryAmberLight),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: slotIndex < 3 ? 8 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppTheme.canvas,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.tv_rounded, color: AppTheme.primaryAmber, size: 22),
                              const SizedBox(height: 6),
                              Text(
                                'Slot ${slotIndex + 1}',
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currentVid?.title.split(' ').first ?? 'Feed',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
