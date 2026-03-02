import 'package:flutter/material.dart';
import 'widgets/shared_widgets.dart';

class DocumentsTab extends StatelessWidget {
  const DocumentsTab({super.key});

  @override
  Widget build(BuildContext context) {
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
                  'Documents',
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
                child: Text(
                  'All your travel documents in one place',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverList(
              delegate: SliverChildListDelegate([
                _DocTile(
                  icon: Icons.flight_outlined,
                  title: 'Flight Tickets',
                  subtitle: 'Paris — CDG Airport',
                  trip: 'Paris Adventure',
                  color: const Color(0xFF4DD0E1),
                ),
                _DocTile(
                  icon: Icons.hotel_outlined,
                  title: 'Hotel Reservation',
                  subtitle: 'Le Marais Hotel, 7 nights',
                  trip: 'Paris Adventure',
                  color: const Color(0xFF6C63FF),
                ),
                _DocTile(
                  icon: Icons.badge_outlined,
                  title: 'Passport Copy',
                  subtitle: 'Expires Dec 2027',
                  trip: 'General',
                  color: const Color(0xFFFF6B6B),
                ),
                _DocTile(
                  icon: Icons.shield_outlined,
                  title: 'Travel Insurance',
                  subtitle: 'WorldCover Premium Plan',
                  trip: 'Tokyo Exploration',
                  color: const Color(0xFF00BFA5),
                ),
                _DocTile(
                  icon: Icons.confirmation_number_outlined,
                  title: 'Louvre Tickets',
                  subtitle: 'Skip-the-line, 2 adults',
                  trip: 'Paris Adventure',
                  color: const Color(0xFFFFB74D),
                ),
              ]),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.upload_file_outlined, size: 20),
                    label: const Text(
                      'Upload Document',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BCD4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _DocTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String trip;
  final Color color;

  const _DocTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trip,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                trip,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
