import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wildlife_models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class DiscoveryMapScreen extends StatefulWidget {
  const DiscoveryMapScreen({super.key});

  @override
  State<DiscoveryMapScreen> createState() => _DiscoveryMapScreenState();
}

class _DiscoveryMapScreenState extends State<DiscoveryMapScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  String? _selectedParkId;
  String _activeFilter = 'All';

  // Map viewport offsets
  double _scale = 1.0;
  Offset _panOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _selectedParkId = 'park_mara'; // Default selected
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final parks = appState.parks;
    final selectedPark = parks.firstWhere(
      (p) => p.id == _selectedParkId,
      orElse: () => parks.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF090D0B), // Deepest dark tactical canvas
      body: Stack(
        children: [
          // 1. Tactical Interactive Map View
          Positioned.fill(
            child: GestureDetector(
              onScaleUpdate: (details) {
                setState(() {
                  _scale = (_scale * details.scale).clamp(0.8, 3.0);
                  _panOffset += details.focalPointDelta;
                });
              },
              child: ClipRect(
                child: CustomPaint(
                  painter: _TacticalMapPainter(
                    pulseProgress: _pulseController.value,
                    scale: _scale,
                    panOffset: _panOffset,
                  ),
                  child: Stack(
                    children: parks.map((park) {
                      return _buildMapPin(park, selectedPark.id == park.id);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),

          // 2. Top Header & Reserve Selector
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.surface.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: const Icon(Icons.explore_rounded, color: AppTheme.primaryAmber, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tactical Discovery Map',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                            ),
                            const Text(
                              'Real-Time Transponders & Reserve Telemetry',
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      // Satellite GPS Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryEmerald.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.secondaryEmerald.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppTheme.secondaryEmeraldLight,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'GPS SYNCED',
                              style: TextStyle(
                                color: AppTheme.secondaryEmeraldLight,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Quick Reserve Filters
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildFilterChip('All Reserves', 'All'),
                      ...parks.map((p) => _buildFilterChip('${p.flag} ${p.name.split(" ").first}', p.id)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Map Controls (Zoom In/Out/Reset)
          Positioned(
            right: 16,
            top: 140,
            child: Column(
              children: [
                _buildMapControlBtn(
                  icon: Icons.add,
                  onPressed: () => setState(() => _scale = (_scale + 0.3).clamp(0.8, 3.0)),
                ),
                const SizedBox(height: 8),
                _buildMapControlBtn(
                  icon: Icons.remove,
                  onPressed: () => setState(() => _scale = (_scale - 0.3).clamp(0.8, 3.0)),
                ),
                const SizedBox(height: 8),
                _buildMapControlBtn(
                  icon: Icons.my_location_rounded,
                  onPressed: () => setState(() {
                    _scale = 1.0;
                    _panOffset = Offset.zero;
                  }),
                ),
              ],
            ),
          ),

          // 4. Park Inspector Card (Floating desktop widget vs sliding mobile sheet)
          if (MediaQuery.of(context).size.width >= 850)
            Positioned(
              right: 24,
              bottom: 24,
              width: 480,
              child: _buildParkInspectorCard(context, selectedPark, appState, isDesktop: true),
            )
          else
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildParkInspectorCard(context, selectedPark, appState, isDesktop: false),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String id) {
    final isSelected = (_activeFilter == id) || (_selectedParkId == id && _activeFilter != 'All');

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFilter = id;
          if (id != 'All') {
            _selectedParkId = id;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryAmber : AppTheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryAmber : AppTheme.border,
            width: 0.8,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.canvas : AppTheme.textPrimary,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapControlBtn({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.border),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppTheme.textPrimary, size: 18),
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }

  // Interactive Map Pin Widget
  Widget _buildMapPin(ParkLocation park, bool isSelected) {
    // Map coordinate to screen percentage
    final pinOffsets = {
      'park_mara': const Offset(0.68, 0.32),
      'park_serengeti': const Offset(0.65, 0.40),
      'park_bwindi': const Offset(0.48, 0.30),
      'park_okavango': const Offset(0.40, 0.62),
      'park_kruger': const Offset(0.60, 0.72),
    };

    final baseOffset = pinOffsets[park.id] ?? const Offset(0.5, 0.5);

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Apply scale & pan
        final x = (baseOffset.dx * screenWidth * _scale) + _panOffset.dx;
        final y = (baseOffset.dy * screenHeight * _scale) + _panOffset.dy;

        return Positioned(
          left: x - 40,
          top: y - 40,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedParkId = park.id;
              });
            },
            child: SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Animated radar pulse ring
                  if (isSelected || park.liveCamsCount > 0)
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 30 + (_pulseController.value * 34),
                          height: 30 + (_pulseController.value * 34),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: (isSelected ? AppTheme.primaryAmber : AppTheme.secondaryEmerald)
                                  .withValues(alpha: 1.0 - _pulseController.value),
                              width: 1.5,
                            ),
                          ),
                        );
                      },
                    ),

                  // Pin Core Marker
                  Container(
                    width: isSelected ? 36 : 28,
                    height: isSelected ? 36 : 28,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryAmber : AppTheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : AppTheme.primaryAmber,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isSelected ? AppTheme.primaryAmber : Colors.black).withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        park.flag,
                        style: TextStyle(fontSize: isSelected ? 16 : 12),
                      ),
                    ),
                  ),

                  // Label underneath
                  Positioned(
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryAmber : AppTheme.border,
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        park.name.split(' ').first,
                        style: TextStyle(
                          color: isSelected ? AppTheme.primaryAmberLight : AppTheme.textPrimary,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Sliding Bottom Inspector / Floating Desktop Widget
  Widget _buildParkInspectorCard(
    BuildContext context,
    ParkLocation park,
    AppState appState, {
    bool isDesktop = false,
  }) {
    final parkVideos = appState.videos.where((v) => v.parkId == park.id).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: isDesktop ? BorderRadius.circular(20) : const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppTheme.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDesktop ? 0.85 : 0.7),
            blurRadius: isDesktop ? 30 : 24,
            offset: Offset(0, isDesktop ? 4 : -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle on mobile only
          if (!isDesktop)
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            )
          else
            const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Park Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    park.imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(width: 70, height: 70, color: AppTheme.surfaceHighlight),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(park.flag, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              park.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${park.country} • ${park.weather}',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.liveCrimson.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppTheme.liveCrimson.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              '${park.liveCamsCount} ACTIVE CAMS',
                              style: const TextStyle(
                                color: AppTheme.liveCrimson,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.shield_outlined, color: AppTheme.secondaryEmeraldLight, size: 14),
                          const SizedBox(width: 3),
                          const Text(
                            'KWS Protected',
                            style: TextStyle(color: AppTheme.secondaryEmeraldLight, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Species tag list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: park.species.map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.canvas,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.border, width: 0.6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.pets, color: AppTheme.primaryAmberLight, size: 10),
                      const SizedBox(width: 4),
                      Text(
                        s,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 10),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Reserve Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              park.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.3),
            ),
          ),
          const SizedBox(height: 12),

          // Cams in this reserve carousel
          if (parkVideos.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'RESERVE BROADCASTS',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '${parkVideos.length} feeds',
                    style: const TextStyle(color: AppTheme.primaryAmberLight, fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: parkVideos.length,
                itemBuilder: (context, index) {
                  final video = parkVideos[index];
                  return GestureDetector(
                    onTap: () => appState.setActiveVideo(video),
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.canvas,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              video.thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(color: AppTheme.surfaceHighlight),
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.85),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                            if (video.isLive)
                              Positioned(
                                top: 4,
                                left: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppTheme.liveCrimson,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: const Text(
                                    'LIVE',
                                    style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            Positioned(
                              bottom: 4,
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
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${video.viewersCount} watching',
                                    style: const TextStyle(color: AppTheme.primaryAmberLight, fontSize: 8),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Tactical Map Canvas Painter
class _TacticalMapPainter extends CustomPainter {
  final double pulseProgress;
  final double scale;
  final Offset panOffset;

  _TacticalMapPainter({
    required this.pulseProgress,
    required this.scale,
    required this.panOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF0C120E);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final gridPaint = Paint()
      ..color = const Color(0xFF1B271F)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw tactical grid lines
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Stylized African continent topographical contour
    final continentPaint = Paint()
      ..color = const Color(0xFF162119)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF283B2F)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final path = Path();
    // Simplified elegant silhouette representing East & Southern Africa focus
    final w = size.width;
    final h = size.height;

    path.moveTo(w * 0.35, h * 0.15); // Mediterranean/North Africa
    path.quadraticBezierTo(w * 0.75, h * 0.18, w * 0.85, h * 0.32); // Horn of Africa
    path.quadraticBezierTo(w * 0.80, h * 0.50, w * 0.75, h * 0.65); // East Coast
    path.quadraticBezierTo(w * 0.70, h * 0.85, w * 0.55, h * 0.88); // Cape of Good Hope
    path.quadraticBezierTo(w * 0.40, h * 0.85, w * 0.35, h * 0.65); // West/Namib Coast
    path.quadraticBezierTo(w * 0.25, h * 0.45, w * 0.25, h * 0.35); // Gulf of Guinea
    path.quadraticBezierTo(w * 0.20, h * 0.20, w * 0.35, h * 0.15); // North West
    path.close();

    canvas.drawPath(path, continentPaint);
    canvas.drawPath(path, borderPaint);

    // Draw latitude rings / Great Rift Valley fault line
    final riftPaint = Paint()
      ..color = AppTheme.primaryAmber.withValues(alpha: 0.25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final riftPath = Path();
    riftPath.moveTo(w * 0.70, h * 0.22);
    riftPath.quadraticBezierTo(w * 0.62, h * 0.38, w * 0.55, h * 0.55);
    riftPath.quadraticBezierTo(w * 0.50, h * 0.65, w * 0.48, h * 0.78);
    canvas.drawPath(riftPath, riftPaint);

    // Compass rose indicator (tactical north)
    final compassPaint = Paint()
      ..color = AppTheme.textSecondary.withValues(alpha: 0.3)
      ..strokeWidth = 1.0;
    final center = Offset(w * 0.88, h * 0.12);
    canvas.drawLine(center.translate(0, -14), center.translate(0, 14), compassPaint);
    canvas.drawLine(center.translate(-14, 0), center.translate(14, 0), compassPaint);
  }

  @override
  bool shouldRepaint(covariant _TacticalMapPainter oldDelegate) {
    return oldDelegate.pulseProgress != pulseProgress ||
        oldDelegate.scale != scale ||
        oldDelegate.panOffset != panOffset;
  }
}
