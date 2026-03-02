import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/trips/domain/entities/trip_entity.dart';
import '../../features/trips/presentation/cubit/trips_cubit.dart';
import '../../features/trips/presentation/cubit/trips_state.dart';
import 'mock_data.dart';
import 'widgets/shared_widgets.dart';
import 'widgets/dashboard_widgets.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  List<MockTrip> _filteredUpcoming(List<MockTrip> all) => all
      .where(
        (t) =>
            t.name.toLowerCase().contains(_searchQuery) ||
            t.destination.toLowerCase().contains(_searchQuery),
      )
      .toList();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripsCubit, TripsState>(
      builder: (context, state) {
        List<MockTrip> upcoming = [];
        List<MockTrip> past = [];

        if (state is TripsLoaded) {
          upcoming = state.upcomingTrips.map(MockTrip.fromEntity).toList();
          past = state.pastTrips.map(MockTrip.fromEntity).toList();
        } else if (state is TripActionSuccess) {
          final trips = state.trips;
          upcoming = trips
              .where(
                (t) =>
                    t.status == TripStatus.upcoming ||
                    t.status == TripStatus.ongoing,
              )
              .map(MockTrip.fromEntity)
              .toList();
          past = trips
              .where((t) => t.status == TripStatus.completed)
              .map(MockTrip.fromEntity)
              .toList();
        } else if (state is TripActionLoading || state is TripActionFailure) {
          final List<TripEntity> currentTrips;
          if (state is TripActionLoading) {
            currentTrips = state.currentTrips;
          } else {
            currentTrips = (state as TripActionFailure).currentTrips;
          }
          upcoming = currentTrips
              .where(
                (t) =>
                    t.status == TripStatus.upcoming ||
                    t.status == TripStatus.ongoing,
              )
              .map(MockTrip.fromEntity)
              .toList();
          past = currentTrips
              .where((t) => t.status == TripStatus.completed)
              .map(MockTrip.fromEntity)
              .toList();
        }

        final nextTrip = upcoming.isNotEmpty ? upcoming.first : null;

        return DashboardGradient(
          child: SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Top bar ──
                SliverToBoxAdapter(child: _buildTopBar()),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ── Search ──
                SliverToBoxAdapter(child: _buildSearchBar()),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // ── Next trip countdown ──
                if (nextTrip != null) ...[
                  SliverToBoxAdapter(child: NextTripCountdown(trip: nextTrip)),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                ],

                // ── Quick actions ──
                const SliverToBoxAdapter(
                  child: SectionHeader(title: 'Quick Actions'),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 14)),
                SliverToBoxAdapter(
                  child: QuickActions(onNewTripAdded: () => setState(() {})),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // ── Upcoming trips carousel ──
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Upcoming Trips',
                    onSeeAll: () {},
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 14)),
                SliverToBoxAdapter(child: _buildTripsCarousel(upcoming)),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // ── Reminders ──
                SliverToBoxAdapter(
                  child: SectionHeader(title: 'Reminders', onSeeAll: () {}),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        ReminderTile(reminder: mockReminders[index]),
                    childCount: mockReminders.length.clamp(0, 4),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // ── Past trips ──
                SliverToBoxAdapter(
                  child: SectionHeader(title: 'Past Trips', onSeeAll: () {}),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => PastTripTile(trip: past[index]),
                    childCount: past.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // ── Tips ──
                SliverToBoxAdapter(
                  child: SectionHeader(title: 'Travel Tips', onSeeAll: () {}),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 14)),
                SliverToBoxAdapter(child: _buildTipsRow()),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── SubWidgets ──

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Traveller ✈️',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const Spacer(),
          _TopBarIcon(
            icon: Icons.notifications_none_rounded,
            badge: mockReminders.length,
            onTap: () {},
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {},
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFF4DD0E1),
              child: Text(
                'T',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        borderRadius: 14,
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: Colors.white.withValues(alpha: 0.4),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search trips, places...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (val) =>
                    setState(() => _searchQuery = val.toLowerCase()),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchCtrl.clear();
                  setState(() => _searchQuery = '');
                },
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripsCarousel(List<MockTrip> allUpcoming) {
    final trips = _searchQuery.isEmpty
        ? allUpcoming
        : _filteredUpcoming(allUpcoming);

    if (trips.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GlassCard(
          child: Center(
            child: Text(
              'No trips match your search.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 175,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: trips.length,
        itemBuilder: (_, i) => TripSummaryCard(trip: trips[i]),
      ),
    );
  }

  Widget _buildTipsRow() {
    return SizedBox(
      height: 145,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: mockTips.length,
        itemBuilder: (_, i) => TipCard(tip: mockTips[i]),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}

// Small icon with optional badge
class _TopBarIcon extends StatelessWidget {
  final IconData icon;
  final int badge;
  final VoidCallback onTap;

  const _TopBarIcon({
    required this.icon,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 42,
        height: 42,
        child: Stack(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            if (badge > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6B6B),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      badge > 9 ? '9+' : '$badge',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
