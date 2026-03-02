import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection_container.dart';
import '../../features/trips/presentation/cubit/trips_cubit.dart';
import 'home_tab.dart';
import 'trips_tab.dart';
import 'expenses_tab.dart';
import 'documents_tab.dart';
import 'settings_tab.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  late final TripsCubit _tripsCubit;

  final List<Widget> _tabs = [
    const HomeTab(),
    const TripsTab(),
    const ExpensesTab(),
    const DocumentsTab(),
    const SettingsTab(),
  ];

  @override
  void initState() {
    super.initState();
    _tripsCubit = sl<TripsCubit>();
    _tripsCubit.loadTrips();
  }

  @override
  void dispose() {
    _tripsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _tripsCubit,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          body: IndexedStack(index: _currentIndex, children: _tabs),
          extendBody: true,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0F2027).withValues(alpha: 0.0),
                  const Color(0xFF0F2027).withValues(alpha: 0.95),
                  const Color(0xFF0F2027),
                ],
                stops: const [0.0, 0.35, 1.0],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      isActive: _currentIndex == 0,
                      onTap: () => _onTabTap(0),
                    ),
                    _NavItem(
                      icon: Icons.luggage_rounded,
                      label: 'Trips',
                      isActive: _currentIndex == 1,
                      onTap: () => _onTabTap(1),
                    ),
                    _NavItem(
                      icon: Icons.account_balance_wallet_rounded,
                      label: 'Expenses',
                      isActive: _currentIndex == 2,
                      onTap: () => _onTabTap(2),
                    ),
                    _NavItem(
                      icon: Icons.folder_rounded,
                      label: 'Docs',
                      isActive: _currentIndex == 3,
                      onTap: () => _onTabTap(3),
                    ),
                    _NavItem(
                      icon: Icons.settings_rounded,
                      label: 'Settings',
                      isActive: _currentIndex == 4,
                      onTap: () => _onTabTap(4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTabTap(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF00BCD4).withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive
                  ? const Color(0xFF4DD0E1)
                  : Colors.white.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? const Color(0xFF4DD0E1)
                    : Colors.white.withValues(alpha: 0.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
