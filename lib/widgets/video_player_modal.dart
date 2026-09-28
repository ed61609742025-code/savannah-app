import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wildlife_models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'live_stream_player.dart';

class VideoPlayerModal extends StatefulWidget {
  final WildlifeVideo video;

  const VideoPlayerModal({super.key, required this.video});

  @override
  State<VideoPlayerModal> createState() => _VideoPlayerModalState();
}

class _VideoPlayerModalState extends State<VideoPlayerModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final creator = appState.getCreatorById(widget.video.creatorId);
    final park = appState.getParkById(widget.video.parkId);

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: Column(
          children: [
            // Top Video Viewport Container
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: LiveStreamPlayer(
                    videoUrl: widget.video.videoUrl,
                    title: widget.video.title,
                    cameraRig: widget.video.cameraRig,
                    sensorMode: widget.video.sensorMode,
                    isMuted: false,
                    autoPlay: true,
                    showControls: false,
                  ),
                ),

                // Top Controls Bar (Close, Live count, Cast)
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 28),
                        onPressed: () => appState.setActiveVideo(null),
                      ),
                      const SizedBox(width: 4),
                      if (widget.video.isLive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.liveCrimson,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.fiber_manual_record, color: Colors.white, size: 8),
                              SizedBox(width: 4),
                              Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.video.views} watching',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.cast, color: Colors.white, size: 20),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white, size: 20),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // Bottom Video HUD telemetry
                Positioned(
                  bottom: 8,
                  left: 12,
                  right: 12,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.surface.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.border, width: 0.5),
                        ),
                        child: Text(
                          widget.video.cameraRig ?? 'CAM-01 [WIDE]',
                          style: const TextStyle(
                            color: AppTheme.secondaryEmeraldLight,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        park != null ? park.name : 'African Wildlife Reserve',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      const Spacer(),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.fullscreen, color: Colors.white, size: 22),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Video Title & Creator Row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.video.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (creator != null)
                          Text(
                            'Hosted by ${creator.name} • ${creator.role}',
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  // Quick Tip Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryAmber,
                      foregroundColor: AppTheme.canvas,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    icon: const Icon(Icons.monetization_on, size: 16),
                    label: const Text('Tip', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    onPressed: () => _showTipSheet(context, appState, creator),
                  ),
                ],
              ),
            ),

            // Tabs Bar: Chat, Species Intel, Field Audio
            TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primaryAmber,
              labelColor: AppTheme.primaryAmber,
              unselectedLabelColor: AppTheme.textSecondary,
              dividerColor: AppTheme.border,
              tabs: const [
                Tab(text: 'Live Chat'),
                Tab(text: 'Species Intel'),
                Tab(text: 'Audio & Telemetry'),
              ],
            ),

            // Tab View Body
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Live Chat
                  _buildChatTab(context, appState),

                  // Tab 2: Species Intel
                  _buildSpeciesTab(context, widget.video, park),

                  // Tab 3: Telemetry
                  _buildTelemetryTab(context, widget.video),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTab(BuildContext context, AppState appState) {
    return Column(
      children: [
        // Chat Messages List
        Expanded(
          child: ListView.builder(
            reverse: true,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: appState.comments.length,
            itemBuilder: (context, index) {
              final comment = appState.comments[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: comment.isRanger
                      ? AppTheme.primaryAmber.withValues(alpha: 0.08)
                      : (comment.tipAmount != null ? AppTheme.secondaryEmerald.withValues(alpha: 0.08) : Colors.transparent),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: comment.isRanger
                        ? AppTheme.primaryAmber.withValues(alpha: 0.3)
                        : (comment.tipAmount != null ? AppTheme.secondaryEmerald.withValues(alpha: 0.3) : Colors.transparent),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: NetworkImage(comment.avatarUrl),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                comment.author,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: comment.isRanger ? AppTheme.primaryAmber : AppTheme.textPrimary,
                                ),
                              ),
                              if (comment.isRanger) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryAmber,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'RANGER',
                                    style: TextStyle(fontSize: 8, color: Colors.black, fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ],
                              if (comment.tipAmount != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryEmerald,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'TIPPED \$${comment.tipAmount?.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 9, color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            comment.text,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Emoji Reactions Tray
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['🦁', '🔥', '🐘', '🌿', '👏', '❤️'].map((emoji) {
              return GestureDetector(
                onTap: () {
                  appState.addComment(widget.video.id, emoji);
                },
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              );
            }).toList(),
          ),
        ),

        // Chat Input Row
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border, width: 1),
                  ),
                  child: TextField(
                    controller: _chatController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Join safari radio chat...',
                      hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        appState.addComment(widget.video.id, val);
                        _chatController.clear();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: AppTheme.primaryAmber, size: 20),
                onPressed: () {
                  if (_chatController.text.trim().isNotEmpty) {
                    appState.addComment(widget.video.id, _chatController.text);
                    _chatController.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpeciesTab(BuildContext context, WildlifeVideo video, ParkLocation? park) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Species in Sight', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: video.species.map((sp) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.pets, size: 14, color: AppTheme.secondaryEmerald),
                  const SizedBox(width: 6),
                  Text(sp, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        if (park != null) ...[
          Text('Park Ecosystem', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(park.flag, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text(park.name, style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                const SizedBox(height: 6),
                Text(park.description, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.wb_sunny, size: 14, color: AppTheme.primaryAmber),
                    const SizedBox(width: 4),
                    Text(park.weather, style: Theme.of(context).textTheme.bodySmall),
                    const Spacer(),
                    const Icon(Icons.videocam, size: 14, color: AppTheme.secondaryEmerald),
                    const SizedBox(width: 4),
                    Text('${park.liveCamsCount} Live Cameras Online', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTelemetryTab(BuildContext context, WildlifeVideo video) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Camera Rig Specs & Telemetry', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        _telemetryRow('Ingest Server', 'AWS Africa (Nairobi Edge • 18ms)'),
        _telemetryRow('Camera Unit', video.cameraRig ?? 'Sony FX6 Cinema Rig'),
        _telemetryRow('Sensor Mode', video.sensorMode ?? '4K Ultra HDR 60fps'),
        _telemetryRow('Solar Power Reserve', '94% (Charging via Mara Array)'),
        _telemetryRow('Audio Channel', 'Binaural Ambisonic Field Mic'),
        _telemetryRow('Anti-Poaching Unit', 'Mara North Reconnaissance Patrol'),
      ],
    );
  }

  Widget _telemetryRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          Text(value, style: const TextStyle(color: AppTheme.primaryAmberLight, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showTipSheet(BuildContext context, AppState appState, Creator? creator) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tip ${creator?.name ?? "Field Ranger"}', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              const Text(
                '100% of micro-donations directly fund field patrol fuel, vehicle repairs, and ranger rations.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [2.0, 5.0, 10.0, 25.0].map((amount) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.surfaceContainer,
                      foregroundColor: AppTheme.primaryAmber,
                      side: const BorderSide(color: AppTheme.border, width: 1),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: () {
                      if (creator != null) {
                        appState.tipCreator(creator.id, amount);
                        appState.addComment(widget.video.id, 'Tipped \$$amount to support the patrol!', tipAmount: amount);
                      }
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Tipped \$$amount to ${creator?.name}! Thank you!'),
                          backgroundColor: AppTheme.secondaryEmerald,
                        ),
                      );
                    },
                    child: Text('\$$amount', style: const TextStyle(fontWeight: FontWeight.bold)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
