import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection_container.dart';
import '../../features/activities/domain/entities/activity_entity.dart';
import '../../features/activities/domain/entities/activity_params.dart';
import '../../features/activities/presentation/cubit/activities_cubit.dart';
import '../../features/activities/presentation/cubit/activities_state.dart';
import '../../features/trips/domain/entities/trip_entity.dart';
import '../../features/trips/presentation/cubit/trips_cubit.dart';
import '../../features/trips/presentation/cubit/trips_state.dart';
import '../dashboard/mock_data.dart';
import '../dashboard/widgets/shared_widgets.dart';
import 'add_activity_page.dart';

class TripDetailPage extends StatefulWidget {
  final MockTrip trip;
  const TripDetailPage({super.key, required this.trip});

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final ActivitiesCubit _activitiesCubit;

  MockTrip get trip => widget.trip;

  List<MockDocument> get _documents => mockDocumentsByTrip[trip.id] ?? [];

  List<MockReminder> get _reminders => mockReminders
      .where((r) => r.subtitle.contains(trip.name.split(' ')[0]))
      .toList();

  List<ActivityEntity> _activitiesFromState(ActivitiesState state) {
    if (state is ActivitiesLoaded) return state.activities;
    if (state is ActivityActionLoading) return state.currentActivities;
    if (state is ActivityActionFailure) return state.currentActivities;
    return [];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _activitiesCubit = sl<ActivitiesCubit>();
    _activitiesCubit.loadActivities(trip.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _activitiesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _activitiesCubit,
      child: BlocListener<ActivitiesCubit, ActivitiesState>(
        listener: (context, state) {
          if (state is ActivityActionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFFF6B6B),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        child: BlocListener<TripsCubit, TripsState>(
          listener: (context, state) {
            if (state is TripActionSuccess) {
              // If this trip was deleted (no longer in list), pop back
              final stillExists = state.trips.any((t) => t.id == trip.id);
              if (!stillExists && mounted) Navigator.pop(context);
            } else if (state is TripActionFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: const Color(0xFFFF6B6B),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          },
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: Scaffold(
              backgroundColor: const Color(0xFF0F2027),
              body: NestedScrollView(
                headerSliverBuilder: (context, _) => [_buildSliverHeader()],
                body: BlocBuilder<ActivitiesCubit, ActivitiesState>(
                  builder: (context, activitiesState) {
                    final activities = _activitiesFromState(activitiesState);
                    final isLoadingActivities =
                        activitiesState is ActivitiesLoading;
                    return Column(
                      children: [
                        _buildTabBar(),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _OverviewTab(
                                trip: trip,
                                reminders: _reminders,
                                activities: activities,
                              ),
                              _ActivitiesTab(
                                activities: activities,
                                isLoading: isLoadingActivities,
                                tripColor: trip.color,
                                onToggle: (id, newIsDone) => context
                                    .read<ActivitiesCubit>()
                                    .toggleActivity(
                                      ToggleActivityParams(
                                        tripId: trip.id,
                                        activityId: id,
                                        isDone: newIsDone,
                                      ),
                                    ),
                                onAddActivity: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(
                                        value: context.read<ActivitiesCubit>(),
                                        child: AddActivityPage(
                                          tripId: trip.id,
                                          tripColor: trip.color,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _DocumentsTab(
                                documents: _documents,
                                tripColor: trip.color,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverHeader() {
    final isUpcoming = trip.status == TripStatus.upcoming;
    final statusLabel = trip.status == TripStatus.upcoming
        ? '${trip.daysLeft} days left'
        : trip.status == TripStatus.ongoing
        ? 'Ongoing'
        : 'Completed';

    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: const Color(0xFF0F2027),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: Colors.white,
              size: 18,
            ),
            onPressed: () {},
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 8, right: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
              size: 18,
            ),
            onPressed: () => _showMoreMenu(context),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                trip.color.withValues(alpha: 0.55),
                const Color(0xFF0F2027),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Emoji
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: trip.color.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: trip.color.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            trip.imageIcon,
                            style: const TextStyle(fontSize: 36),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isUpcoming
                                    ? trip.color.withValues(alpha: 0.25)
                                    : Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isUpcoming
                                      ? trip.color
                                      : Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              trip.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 13,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    trip.destination,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Date strip
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_fmtDate(trip.startDate)}  →  ${_fmtDate(trip.endDate)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${trip.totalDays} nights',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFF0F2027),
      child: TabBar(
        controller: _tabController,
        indicatorColor: trip.color,
        indicatorWeight: 2.5,
        labelColor: trip.color,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.35),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Activities'),
          Tab(text: 'Documents'),
        ],
      ),
    );
  }

  void _showMoreMenu(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: const Color(0xFF1A2E38),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _SheetOption(
                icon: Icons.share_outlined,
                label: 'Share Trip',
                onTap: () => Navigator.pop(ctx),
              ),
              _SheetOption(
                icon: Icons.copy_outlined,
                label: 'Duplicate Trip',
                onTap: () => Navigator.pop(ctx),
              ),
              _SheetOption(
                icon: Icons.delete_outline_rounded,
                label: 'Delete Trip',
                color: const Color(0xFFFF6B6B),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2E38),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Trip',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${trip.name}"? This cannot be undone.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<TripsCubit>().deleteTrip(trip.id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Color(0xFFFF6B6B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }
}

// ── Overview Tab ──

class _OverviewTab extends StatelessWidget {
  final MockTrip trip;
  final List<MockReminder> reminders;
  final List<ActivityEntity> activities;
  const _OverviewTab({
    required this.trip,
    required this.reminders,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFF0F2027);
    final acts = activities;
    final doneCount = acts.where((a) => a.isDone).length;

    return Container(
      color: bgColor,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        physics: const BouncingScrollPhysics(),
        children: [
          // ── Stats strip ──
          Row(
            children: [
              _StatBox(
                value: trip.status == TripStatus.upcoming
                    ? '${trip.daysLeft}'
                    : trip.totalDays.toString(),
                label: trip.status == TripStatus.upcoming
                    ? 'Days Left'
                    : 'Total Days',
                color: trip.color,
              ),
              const SizedBox(width: 12),
              _StatBox(
                value: '${trip.activitiesCount}',
                label: 'Activities',
                color: const Color(0xFF6C63FF),
              ),
              const SizedBox(width: 12),
              _StatBox(
                value: '\$${trip.totalBudget.toInt()}',
                label: 'Budget',
                color: const Color(0xFF00BFA5),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Budget card ──
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Budget',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: trip.isOverBudget
                            ? const Color(0xFFFF6B6B).withValues(alpha: 0.15)
                            : const Color(0xFF00BFA5).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        trip.isOverBudget ? 'Over budget!' : 'On track',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: trip.isOverBudget
                              ? const Color(0xFFFF6B6B)
                              : const Color(0xFF00BFA5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _BudgetItem(
                      label: 'Spent',
                      value: '\$${trip.spentBudget.toInt()}',
                      color: const Color(0xFFFF6B6B),
                    ),
                    _BudgetItem(
                      label: 'Remaining',
                      value:
                          '\$${(trip.totalBudget - trip.spentBudget).clamp(0, double.infinity).toInt()}',
                      color: const Color(0xFF00BFA5),
                    ),
                    _BudgetItem(
                      label: 'Total',
                      value: '\$${trip.totalBudget.toInt()}',
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: trip.budgetPercent,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      trip.isOverBudget ? const Color(0xFFFF6B6B) : trip.color,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Add Expense'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: trip.color,
                      side: BorderSide(
                        color: trip.color.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Activity progress ──
          if (acts.isNotEmpty) ...[
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Activities',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '$doneCount / ${acts.length} done',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: acts.isEmpty ? 0 : doneCount / acts.length,
                      minHeight: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(trip.color),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...acts
                      .take(3)
                      .map(
                        (a) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Icon(
                                a.isDone
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                size: 18,
                                color: a.isDone
                                    ? const Color(0xFF00BFA5)
                                    : Colors.white.withValues(alpha: 0.3),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  a.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: a.isDone
                                        ? Colors.white.withValues(alpha: 0.4)
                                        : Colors.white,
                                    decoration: a.isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                    decorationColor: Colors.white.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                a.displayTime.split('·').first.trim(),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.35),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  if (acts.length > 3)
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        '+ ${acts.length - 3} more',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4DD0E1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Reminders ──
          if (reminders.isNotEmpty) ...[
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reminders',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...reminders.map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: r.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(r.icon, color: r.color, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  r.subtitle,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.45),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: r.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              r.daysUntilDue <= 0
                                  ? 'Today'
                                  : '${r.daysUntilDue}d',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: r.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatBox({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _BudgetItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}

// ── Activities Tab ──

class _ActivitiesTab extends StatelessWidget {
  final List<ActivityEntity> activities;
  final bool isLoading;
  final Color tripColor;
  final void Function(String id, bool newIsDone) onToggle;
  final VoidCallback onAddActivity;

  const _ActivitiesTab({
    required this.activities,
    required this.isLoading,
    required this.tripColor,
    required this.onToggle,
    required this.onAddActivity,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && activities.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4DD0E1),
          strokeWidth: 2.5,
        ),
      );
    }

    if (activities.isEmpty) {
      return _EmptyState(
        icon: Icons.event_note_outlined,
        message: 'No activities yet',
        sub: 'Add activities to plan your trip day-by-day.',
        color: tripColor,
        actionLabel: 'Add Activity',
        onAction: onAddActivity,
      );
    }

    return Container(
      color: const Color(0xFF0F2027),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        physics: const BouncingScrollPhysics(),
        itemCount: activities.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == activities.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: onAddActivity,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Activity'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: tripColor,
                    side: BorderSide(color: tripColor.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            );
          }
          final a = activities[index];
          return GestureDetector(
            onTap: () => onToggle(a.id, !a.isDone),
            child: GlassCard(
              color: a.isDone
                  ? Colors.white.withValues(alpha: 0.04)
                  : a.displayColor.withValues(alpha: 0.08),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: a.isDone
                          ? Colors.white.withValues(alpha: 0.06)
                          : a.displayColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      a.displayIcon,
                      color: a.isDone
                          ? Colors.white.withValues(alpha: 0.3)
                          : a.displayColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: a.isDone
                                ? Colors.white.withValues(alpha: 0.35)
                                : Colors.white,
                            decoration: a.isDone
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: Colors.white.withValues(
                              alpha: 0.35,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 11,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              a.displayTime,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 11,
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                a.location,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.35),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    a.isDone
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: a.isDone
                        ? const Color(0xFF00BFA5)
                        : Colors.white.withValues(alpha: 0.2),
                    size: 22,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Documents Tab ──

class _DocumentsTab extends StatelessWidget {
  final List<MockDocument> documents;
  final Color tripColor;

  const _DocumentsTab({required this.documents, required this.tripColor});

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return _EmptyState(
        icon: Icons.folder_outlined,
        message: 'No documents yet',
        sub: 'Upload your tickets, reservations, and insurance here.',
        color: tripColor,
      );
    }

    return Container(
      color: const Color(0xFF0F2027),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        physics: const BouncingScrollPhysics(),
        itemCount: documents.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == documents.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload_file_outlined, size: 18),
                  label: const Text('Upload Document'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: tripColor,
                    side: BorderSide(color: tripColor.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            );
          }
          final doc = documents[index];
          return GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: doc.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(doc.icon, color: doc.color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        doc.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.download_outlined,
                  size: 20,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Shared Helpers ──

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String sub;
  final Color color;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.sub,
    required this.color,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F2027),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                sub,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: color.withValues(alpha: 0.4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: c, size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: c,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
