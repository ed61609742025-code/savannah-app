import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wildlife_models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/video_card.dart';

class CreatorProfileScreen extends StatefulWidget {
  final Creator? creator;

  const CreatorProfileScreen({super.key, this.creator});

  @override
  State<CreatorProfileScreen> createState() => _CreatorProfileScreenState();
}

class _CreatorProfileScreenState extends State<CreatorProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final creator = widget.creator ?? appState.selectedCreator ?? appState.creators.first;
    final isFollowing = appState.isFollowingCreator(creator.id);
    final creatorVideos = appState.videos.where((v) => v.creatorId == creator.id).toList();

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              backgroundColor: AppTheme.canvas,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    appState.setSelectedCreator(null);
                  }
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ranger profile link copied to clipboard.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      creator.coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(color: AppTheme.surfaceHighlight),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            AppTheme.canvas.withValues(alpha: 0.95),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar & Actions Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: AppTheme.canvas,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.primaryAmber, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 38,
                            backgroundImage: NetworkImage(creator.avatarUrl),
                            backgroundColor: AppTheme.surfaceHighlight,
                          ),
                        ),
                        const Spacer(),
                        // Tip Button
                        OutlinedButton.icon(
                          onPressed: () => _showTipDialog(context, appState, creator),
                          icon: const Icon(Icons.volunteer_activism, size: 16, color: AppTheme.primaryAmberLight),
                          label: const Text('Tip Ranger', style: TextStyle(color: AppTheme.primaryAmberLight)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primaryAmber),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Follow Button
                        ElevatedButton(
                          onPressed: () => appState.toggleFollowCreator(creator.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFollowing ? AppTheme.surface : AppTheme.primaryAmber,
                            foregroundColor: isFollowing ? AppTheme.textPrimary : AppTheme.canvas,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: isFollowing ? AppTheme.border : Colors.transparent,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          child: Text(
                            isFollowing ? 'Following' : 'Follow',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Name, Handle, Verified Badge
                    Row(
                      children: [
                        Text(
                          creator.name,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                        ),
                        const SizedBox(width: 6),
                        if (creator.isVerified)
                          const Icon(Icons.verified, color: AppTheme.secondaryEmeraldLight, size: 18),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${creator.handle} • ${creator.role}',
                      style: const TextStyle(color: AppTheme.primaryAmberLight, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: AppTheme.textSecondary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${creator.location} • ${creator.conservancy}',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Bio
                    Text(
                      creator.bio,
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 16),

                    // Stats Grid Bar
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statItem('${(creator.followers / 1000).toStringAsFixed(1)}K', 'Followers'),
                          _divider(),
                          _statItem('${creator.backers}', 'Guardians'),
                          _divider(),
                          _statItem(creator.totalViews, 'Views'),
                          _divider(),
                          _statItem('\$${(creator.tipsRaised / 1000).toStringAsFixed(1)}K', 'Patrol Fund'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Guardian Tier Perks Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryAmber.withValues(alpha: 0.18),
                            AppTheme.surface,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.primaryAmber.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'GUARDIAN BACKER TIER',
                                    style: TextStyle(
                                      color: AppTheme.primaryAmberLight,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '\$${creator.tierPrice.toStringAsFixed(2)} / month',
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: AppTheme.surface,
                                      content: Text(
                                        'Joined ${creator.name}\'s Guardian Tier! Welcome to field comms.',
                                        style: const TextStyle(color: AppTheme.secondaryEmeraldLight),
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryAmber,
                                  foregroundColor: AppTheme.canvas,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Join Tier', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...creator.tierPerks.map((perk) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle, color: AppTheme.secondaryEmeraldLight, size: 14),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      perk,
                                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tab Bar
                    TabBar(
                      controller: _tabController,
                      indicatorColor: AppTheme.primaryAmber,
                      indicatorWeight: 3,
                      labelColor: AppTheme.primaryAmberLight,
                      unselectedLabelColor: AppTheme.textSecondary,
                      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      tabs: [
                        Tab(text: 'Broadcasts (${creatorVideos.length})'),
                        const Tab(text: 'Conservation Ledger'),
                        const Tab(text: 'Field Gear'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Broadcasts
            ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 32),
              itemCount: creatorVideos.length,
              itemBuilder: (context, index) {
                return VideoCard(video: creatorVideos[index]);
              },
            ),

            // Tab 2: Conservation Ledger
            _buildConservationLedgerTab(creator),

            // Tab 3: Field Gear
            _buildFieldGearTab(),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 24, color: AppTheme.border);
  }

  Widget _buildConservationLedgerTab(Creator creator) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Verified Field Impact (2025 - 2026)',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Every dollar tipped or subscribed directly funds verified patrol deployments in Maasai Mara & surrounding group ranches.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 16),
        _ledgerItem(
          icon: Icons.access_time_rounded,
          title: '1,420 Patrol Hours Logged',
          subtitle: 'Foot & vehicle reconnaissance conducted across high-risk boundary corridors.',
          stat: 'Verified KWS',
        ),
        _ledgerItem(
          icon: Icons.content_cut_rounded,
          title: '384 Wire Snares Decommissioned',
          subtitle: 'Active sweep operations clearing poacher traps near river watering spots.',
          stat: '384 Removed',
        ),
        _ledgerItem(
          icon: Icons.healing_rounded,
          title: '19 Wildlife Medical Interventions',
          subtitle: 'Rapid response alongside mobile vet units treating arrow and snare injuries.',
          stat: '100% Survived',
        ),
        _ledgerItem(
          icon: Icons.lightbulb_outline_rounded,
          title: '48 Predator Deterrent Lights',
          subtitle: 'Solar-powered strobe units installed around community Maasai bomas to prevent lion conflicts.',
          stat: '48 Bomas',
        ),
      ],
    );
  }

  Widget _ledgerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String stat,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.secondaryEmerald.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.secondaryEmeraldLight, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.canvas,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppTheme.secondaryEmerald.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        stat,
                        style: const TextStyle(color: AppTheme.secondaryEmeraldLight, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldGearTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Field Reconnaissance Hardware Rig',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'The specialized telemetry, optical sensors, and sat-uplink rigs used to stream live from the savannah.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 16),
        _gearCard(
          category: 'OPTICS & CAMERA RIG',
          name: 'Sony FX6 Cinema Camera + FE 600mm f/4 GM OSS',
          desc: 'High sensitivity full-frame 4K capture with fast animal eye-autofocus and gyro optical stabilization.',
        ),
        _gearCard(
          category: 'NOCTURNAL SENSORS',
          name: 'FLIR Boson 640 Thermal Long-Wave Sensor',
          desc: 'Detects body heat of predators through dense acacia brush up to 1.5km in total darkness.',
        ),
        _gearCard(
          category: 'SATELLITE INGEST',
          name: 'Starlink Flat High-Performance Marine Array',
          desc: 'Bonded 180 Mbps low-latency uplink mounted directly to the safari rig roof rack.',
        ),
        _gearCard(
          category: 'PATROL PLATFORM',
          name: 'Toyota Land Cruiser 79 Series Heavy Duty 4x4',
          desc: 'Equipped with dual 200Ah lithium power bank, solar trickle charger, and pneumatic camera jib.',
        ),
      ],
    );
  }

  Widget _gearCard({required String category, required String name, required String desc}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(category, style: const TextStyle(color: AppTheme.primaryAmberLight, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, height: 1.3)),
        ],
      ),
    );
  }

  void _showTipDialog(BuildContext context, AppState appState, Creator creator) {
    double tipAmount = 10.0;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(radius: 20, backgroundImage: NetworkImage(creator.avatarUrl)),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tip ${creator.name}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                            const Text('100% goes directly to ranger patrol support', style: TextStyle(color: AppTheme.secondaryEmeraldLight, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [5.0, 10.0, 25.0, 50.0].map((amt) {
                        final isSel = tipAmount == amt;
                        return GestureDetector(
                          onTap: () => setModalState(() => tipAmount = amt),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSel ? AppTheme.primaryAmber : AppTheme.canvas,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSel ? AppTheme.primaryAmber : AppTheme.border),
                            ),
                            child: Text(
                              '\$$amt',
                              style: TextStyle(
                                color: isSel ? AppTheme.canvas : AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        appState.tipCreator(creator.id, tipAmount);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppTheme.surface,
                            content: Text(
                              'Tip of \$$tipAmount sent to ${creator.name}! Asante sana!',
                              style: const TextStyle(color: AppTheme.primaryAmberLight),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryAmber,
                        foregroundColor: AppTheme.canvas,
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Confirm \$$tipAmount Tip (100% to Field)', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
