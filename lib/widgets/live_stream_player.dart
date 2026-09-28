import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../theme/app_theme.dart';

class LiveStreamPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String? cameraRig;
  final String? sensorMode;
  final bool isMuted;
  final bool autoPlay;
  final VoidCallback? onAudioToggle;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final bool showControls;

  const LiveStreamPlayer({
    super.key,
    required this.videoUrl,
    required this.title,
    this.cameraRig,
    this.sensorMode,
    this.isMuted = true,
    this.autoPlay = true,
    this.onAudioToggle,
    this.onTap,
    this.onDoubleTap,
    this.showControls = true,
  });

  @override
  State<LiveStreamPlayer> createState() => _LiveStreamPlayerState();
}

class _LiveStreamPlayerState extends State<LiveStreamPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(covariant LiveStreamPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller?.dispose();
      _initializeController();
    } else if (oldWidget.isMuted != widget.isMuted) {
      _controller?.setVolume(widget.isMuted ? 0.0 : 1.0);
    }
  }

  Future<void> _initializeController() async {
    setState(() {
      _isInitialized = false;
      _hasError = false;
    });

    try {
      final uri = Uri.parse(widget.videoUrl);
      _controller = VideoPlayerController.networkUrl(
        uri,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      await _controller!.initialize();
      await _controller!.setLooping(true);
      await _controller!.setVolume(widget.isMuted ? 0.0 : 1.0);
      if (widget.autoPlay) {
        await _controller!.play();
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('[LiveStreamPlayer] Error loading video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTap: widget.onDoubleTap,
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video Surface or Placeholder
            if (_isInitialized && _controller != null)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio > 0 ? _controller!.value.aspectRatio : 16 / 9,
                  child: VideoPlayer(_controller!),
                ),
              )
            else if (_hasError)
              Container(
                color: const Color(0xFF101411),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded, color: AppTheme.primaryAmber, size: 28),
                      const SizedBox(height: 6),
                      Text(
                        'Telemetry Signal Reconnecting',
                        style: TextStyle(
                          color: AppTheme.textSecondary.withValues(alpha: 0.8),
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextButton.icon(
                        onPressed: _initializeController,
                        icon: const Icon(Icons.refresh_rounded, size: 14, color: AppTheme.secondaryEmeraldLight),
                        label: const Text('RETRY', style: TextStyle(fontSize: 10, color: AppTheme.secondaryEmeraldLight)),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                color: const Color(0xFF0F1411),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondaryEmeraldLight),
                    ),
                  ),
                ),
              ),

            // Tactical Sensor HUD Overlay
            if (widget.showControls) ...[
              // Top Badges
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Row(
                  children: [
                    // LIVE Red Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Sensor Mode Badge
                    if (widget.sensorMode != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.secondaryEmeraldLight.withValues(alpha: 0.5), width: 0.5),
                        ),
                        child: Text(
                          widget.sensorMode!,
                          style: const TextStyle(
                            color: AppTheme.secondaryEmeraldLight,
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const Spacer(),

                    // Solo Audio Button
                    GestureDetector(
                      onTap: widget.onAudioToggle,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: widget.isMuted
                              ? Colors.black.withValues(alpha: 0.6)
                              : AppTheme.primaryAmber.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          widget.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                          color: widget.isMuted ? Colors.white70 : Colors.black,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Camera Rig info
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(color: Colors.black, blurRadius: 4),
                          ],
                        ),
                      ),
                    ),
                    if (widget.cameraRig != null)
                      Text(
                        widget.cameraRig!,
                        style: TextStyle(
                          color: AppTheme.textSecondary.withValues(alpha: 0.8),
                          fontSize: 8,
                          fontFamily: 'monospace',
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
