import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/trips/domain/entities/trip_entity.dart';
import '../../features/trips/presentation/cubit/trips_cubit.dart';
import '../../features/trips/presentation/cubit/trips_state.dart';
import '../dashboard/mock_data.dart';
import 'widgets/shared_widgets.dart';
import '../trips/add_trip_page.dart';
import '../trips/trip_detail_page.dart';

class TripsTab extends StatefulWidget {
  const TripsTab({super.key});

  @override
  State<TripsTab> createState() => _TripsTabState();
}

class _TripsTabState extends State<TripsTab> {
  void _openAddTrip() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<TripsCubit>(),
          child: const AddTripPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripsCubit, TripsState>(
      builder: (context, state) {
        List<MockTrip> upcoming = [];
        List<MockTrip> past = [];
        bool isLoading = false;
        String? errorMessage;

        if (state is TripsLoading) {
          isLoading = true;
        } else if (state is TripsError) {
          errorMessage = state.message;
        } else if (state is TripsLoaded) {
          upcoming = state.upcomingTrips.map(MockTrip.fromEntity).toList();
          past = state.pastTrips.map(MockTrip.fromEntity).toList();
        } else if (state is TripActionLoading) {
          final trips = state.currentTrips;
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
          isLoading = true;
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
        } else if (state is TripActionFailure) {
          final trips = state.currentTrips;
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
          errorMessage = state.message;
        }

        final allTrips = [...upcoming, ...past];

        return DashboardGradient(
          child: SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'My Trips',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 6)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${upcoming.length} upcoming · ${past.length} past',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        GestureDetector(
                          onTap: _openAddTrip,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF4DD0E1,
                              ).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(
                                  0xFF4DD0E1,
                                ).withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.add_rounded,
                                  size: 16,
                                  color: Color(0xFF4DD0E1),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'New Trip',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4DD0E1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Error banner
                if (errorMessage != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFFF6B6B,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(
                              0xFFFF6B6B,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: Color(0xFFFF6B6B),
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                errorMessage,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFFF6B6B),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  context.read<TripsCubit>().loadTrips(),
                              child: const Icon(
                                Icons.refresh_rounded,
                                color: Color(0xFFFF6B6B),
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Loading indicator
                if (isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF4DD0E1),
                          strokeWidth: 2.5,
                        ),
                      ),
                    ),
                  ),

                // Empty state
                if (!isLoading && allTrips.isEmpty && errorMessage == null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 40,
                      ),
                      child: GlassCard(
                        child: Column(
                          children: [
                            const Text('✈️', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            const Text(
                              'No Trips Yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tap "New Trip" to start planning your adventure!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Trips list
                if (!isLoading && allTrips.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final trip = allTrips[index];
                      final isUpcoming =
                          trip.status == TripStatus.upcoming ||
                          trip.status == TripStatus.ongoing;
                      return GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<TripsCubit>(),
                              child: TripDetailPage(trip: trip),
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 6,
                          ),
                          child: GlassCard(
                            color: trip.color.withValues(alpha: 0.08),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Text(
                                  trip.imageIcon,
                                  style: const TextStyle(fontSize: 34),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        trip.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        trip.destination,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isUpcoming
                                        ? trip.color.withValues(alpha: 0.2)
                                        : Colors.white.withValues(alpha: 0.07),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isUpcoming
                                        ? '${trip.daysLeft}d left'
                                        : 'Completed',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isUpcoming
                                          ? trip.color
                                          : Colors.white.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }, childCount: allTrips.length),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        );
      },
    );
  }
}
