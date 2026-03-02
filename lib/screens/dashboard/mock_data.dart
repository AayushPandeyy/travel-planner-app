import 'package:flutter/material.dart';
import '../../features/trips/domain/entities/trip_entity.dart';
// TripStatus is re-exported via trip_entity.dart (imported above)

/// Mock trip model
class MockTrip {
  final String id;
  final String name;
  final String destination;
  final String imageIcon;
  final DateTime startDate;
  final DateTime endDate;
  final double totalBudget;
  final double spentBudget;
  final int activitiesCount;
  final int pendingDocuments;
  final int pendingReminders;
  final TripStatus status;
  final Color color;

  const MockTrip({
    required this.id,
    required this.name,
    required this.destination,
    required this.imageIcon,
    required this.startDate,
    required this.endDate,
    required this.totalBudget,
    required this.spentBudget,
    required this.activitiesCount,
    required this.pendingDocuments,
    required this.pendingReminders,
    required this.status,
    required this.color,
  });

  int get daysLeft => startDate.difference(DateTime.now()).inDays;
  int get totalDays => endDate.difference(startDate).inDays;
  double get budgetPercent =>
      totalBudget > 0 ? (spentBudget / totalBudget).clamp(0.0, 1.0) : 0.0;
  bool get isOverBudget => spentBudget > totalBudget;

  /// Create a UI-ready MockTrip from a domain TripEntity.
  factory MockTrip.fromEntity(TripEntity entity) {
    return MockTrip(
      id: entity.id,
      name: entity.name,
      destination: entity.destination,
      imageIcon: entity.emoji,
      startDate: entity.startDate,
      endDate: entity.endDate,
      totalBudget: entity.totalBudget,
      spentBudget: entity.spentBudget,
      activitiesCount: entity.activitiesCount,
      pendingDocuments: entity.pendingDocuments,
      pendingReminders: entity.pendingReminders,
      status: entity.status,
      color: entity.displayColor,
    );
  }
}

/// Mock reminder model
class MockReminder {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final DateTime dueDate;
  final ReminderType type;

  const MockReminder({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.dueDate,
    required this.type,
  });

  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;
}

enum ReminderType { document, activity, checkin, budget }

/// Mock quick tip
class MockTip {
  final String title;
  final String description;
  final IconData icon;

  const MockTip({
    required this.title,
    required this.description,
    required this.icon,
  });
}

/// Mock activity
class MockActivity {
  final String id;
  final String title;
  final DateTime date;
  final String startTime;
  final int duration; // in minutes
  final String location;
  final IconData icon;
  final Color color;
  bool isDone;

  MockActivity({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.duration,
    required this.location,
    required this.icon,
    required this.color,
    this.isDone = false,
  });

  /// Formatted display string: "Jun 5 · 9:00 AM"
  String get displayTime {
    const months = [
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
    return '${months[date.month - 1]} ${date.day} · $startTime';
  }

  /// Duration formatted as "1h 30min", "2h", "45min"
  String get durationString {
    if (duration < 60) return '${duration}min';
    final h = duration ~/ 60;
    final m = duration % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}min';
  }
}

/// Mock document
class MockDocument {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const MockDocument({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

// ──────────────── MOCK DATA ────────────────

final List<MockTrip> mockUpcomingTrips = [
  MockTrip(
    id: '1',
    name: 'Paris Adventure',
    destination: 'Paris, France',
    imageIcon: '🗼',
    startDate: DateTime.now().add(const Duration(days: 5)),
    endDate: DateTime.now().add(const Duration(days: 12)),
    totalBudget: 3500,
    spentBudget: 1200,
    activitiesCount: 8,
    pendingDocuments: 2,
    pendingReminders: 3,
    status: TripStatus.upcoming,
    color: const Color(0xFF6C63FF),
  ),
  MockTrip(
    id: '2',
    name: 'Tokyo Exploration',
    destination: 'Tokyo, Japan',
    imageIcon: '⛩️',
    startDate: DateTime.now().add(const Duration(days: 21)),
    endDate: DateTime.now().add(const Duration(days: 30)),
    totalBudget: 5000,
    spentBudget: 800,
    activitiesCount: 12,
    pendingDocuments: 4,
    pendingReminders: 5,
    status: TripStatus.upcoming,
    color: const Color(0xFFFF6B6B),
  ),
  MockTrip(
    id: '3',
    name: 'Bali Retreat',
    destination: 'Bali, Indonesia',
    imageIcon: '🏝️',
    startDate: DateTime.now().add(const Duration(days: 45)),
    endDate: DateTime.now().add(const Duration(days: 52)),
    totalBudget: 2800,
    spentBudget: 400,
    activitiesCount: 6,
    pendingDocuments: 1,
    pendingReminders: 2,
    status: TripStatus.upcoming,
    color: const Color(0xFF00BFA5),
  ),
];

final List<MockTrip> mockPastTrips = [
  MockTrip(
    id: '4',
    name: 'New York City',
    destination: 'New York, USA',
    imageIcon: '🗽',
    startDate: DateTime.now().subtract(const Duration(days: 30)),
    endDate: DateTime.now().subtract(const Duration(days: 23)),
    totalBudget: 4200,
    spentBudget: 3950,
    activitiesCount: 15,
    pendingDocuments: 0,
    pendingReminders: 0,
    status: TripStatus.completed,
    color: const Color(0xFFFF9800),
  ),
  MockTrip(
    id: '5',
    name: 'London Weekend',
    destination: 'London, UK',
    imageIcon: '🎡',
    startDate: DateTime.now().subtract(const Duration(days: 60)),
    endDate: DateTime.now().subtract(const Duration(days: 56)),
    totalBudget: 1800,
    spentBudget: 1650,
    activitiesCount: 7,
    pendingDocuments: 0,
    pendingReminders: 0,
    status: TripStatus.completed,
    color: const Color(0xFF5C6BC0),
  ),
];

final List<MockReminder> mockReminders = [
  MockReminder(
    id: '1',
    title: 'Passport expires soon',
    subtitle: 'Renew before Paris trip',
    icon: Icons.badge_outlined,
    color: const Color(0xFFFF6B6B),
    dueDate: DateTime.now().add(const Duration(days: 15)),
    type: ReminderType.document,
  ),
  MockReminder(
    id: '2',
    title: 'Flight check-in opens',
    subtitle: 'Paris → CDG Airport',
    icon: Icons.flight_outlined,
    color: const Color(0xFF4DD0E1),
    dueDate: DateTime.now().add(const Duration(days: 4)),
    type: ReminderType.checkin,
  ),
  MockReminder(
    id: '3',
    title: 'Louvre Museum tour',
    subtitle: 'Booked for Day 2 in Paris',
    icon: Icons.museum_outlined,
    color: const Color(0xFF6C63FF),
    dueDate: DateTime.now().add(const Duration(days: 6)),
    type: ReminderType.activity,
  ),
  MockReminder(
    id: '4',
    title: 'Budget alert',
    subtitle: 'Paris trip at 34% of budget',
    icon: Icons.account_balance_wallet_outlined,
    color: const Color(0xFFFFB74D),
    dueDate: DateTime.now(),
    type: ReminderType.budget,
  ),
  MockReminder(
    id: '5',
    title: 'Travel insurance',
    subtitle: 'Upload proof for Japan trip',
    icon: Icons.shield_outlined,
    color: const Color(0xFF00BFA5),
    dueDate: DateTime.now().add(const Duration(days: 10)),
    type: ReminderType.document,
  ),
];

final List<MockTip> mockTips = [
  const MockTip(
    title: 'Paris Weather',
    description: 'Expect 12-18°C. Pack layers and an umbrella!',
    icon: Icons.wb_cloudy_outlined,
  ),
  const MockTip(
    title: 'Pack Documents',
    description: 'Pack documents 3 days before your flight.',
    icon: Icons.inventory_2_outlined,
  ),
  const MockTip(
    title: 'Top Attraction',
    description: 'Skip-the-line tickets for Eiffel Tower recommended.',
    icon: Icons.star_outline_rounded,
  ),
];

// Per-trip activities keyed by trip id
final Map<String, List<MockActivity>> mockActivitiesByTrip = {
  '1': [
    MockActivity(
      id: 'a1',
      title: 'Eiffel Tower Visit',
      date: DateTime.now().add(const Duration(days: 5)),
      startTime: '10:00 AM',
      duration: 120,
      location: 'Champ de Mars, Paris',
      icon: Icons.photo_camera_outlined,
      color: const Color(0xFF6C63FF),
    ),
    MockActivity(
      id: 'a2',
      title: 'Louvre Museum Tour',
      date: DateTime.now().add(const Duration(days: 6)),
      startTime: '9:00 AM',
      duration: 180,
      location: 'Rue de Rivoli, Paris',
      icon: Icons.museum_outlined,
      color: const Color(0xFFFF6B6B),
    ),
    MockActivity(
      id: 'a3',
      title: 'Seine River Cruise',
      date: DateTime.now().add(const Duration(days: 6)),
      startTime: '7:00 PM',
      duration: 90,
      location: 'Pont de l\'Alma, Paris',
      icon: Icons.directions_boat_outlined,
      color: const Color(0xFF4DD0E1),
    ),
    MockActivity(
      id: 'a4',
      title: 'Montmartre & Sacré-Cœur',
      date: DateTime.now().add(const Duration(days: 7)),
      startTime: '11:00 AM',
      duration: 120,
      location: 'Montmartre, Paris',
      icon: Icons.church_outlined,
      color: const Color(0xFFFFB74D),
    ),
    MockActivity(
      id: 'a5',
      title: 'Palace of Versailles',
      date: DateTime.now().add(const Duration(days: 8)),
      startTime: '9:30 AM',
      duration: 180,
      location: 'Versailles, France',
      icon: Icons.account_balance_outlined,
      color: const Color(0xFF00BFA5),
      isDone: false,
    ),
    MockActivity(
      id: 'a6',
      title: 'Musée d\'Orsay',
      date: DateTime.now().add(const Duration(days: 9)),
      startTime: '2:00 PM',
      duration: 90,
      location: 'Rue de la Légion d\'Honneur',
      icon: Icons.art_track_outlined,
      color: const Color(0xFFAB47BC),
    ),
    MockActivity(
      id: 'a7',
      title: 'Farewell Dinner',
      date: DateTime.now().add(const Duration(days: 11)),
      startTime: '7:30 PM',
      duration: 120,
      location: 'Le Jules Verne, Paris',
      icon: Icons.restaurant_outlined,
      color: const Color(0xFFFF9800),
    ),
  ],
  '2': [
    MockActivity(
      id: 'b1',
      title: 'Senso-ji Temple',
      date: DateTime.now().add(const Duration(days: 21)),
      startTime: '9:00 AM',
      duration: 180,
      location: 'Asakusa, Tokyo',
      icon: Icons.temple_buddhist_outlined,
      color: const Color(0xFFFF6B6B),
    ),
    MockActivity(
      id: 'b2',
      title: 'Shibuya Crossing',
      date: DateTime.now().add(const Duration(days: 21)),
      startTime: '5:00 PM',
      duration: 60,
      location: 'Shibuya, Tokyo',
      icon: Icons.directions_walk_outlined,
      color: const Color(0xFF4DD0E1),
    ),
    MockActivity(
      id: 'b3',
      title: 'TeamLab Borderless',
      date: DateTime.now().add(const Duration(days: 22)),
      startTime: '10:00 AM',
      duration: 240,
      location: 'Odaiba, Tokyo',
      icon: Icons.light_mode_outlined,
      color: const Color(0xFF6C63FF),
    ),
    MockActivity(
      id: 'b4',
      title: 'Tsukiji Fish Market',
      date: DateTime.now().add(const Duration(days: 23)),
      startTime: '7:00 AM',
      duration: 120,
      location: 'Tsukiji, Tokyo',
      icon: Icons.set_meal_outlined,
      color: const Color(0xFFFFB74D),
    ),
  ],
  '3': [
    MockActivity(
      id: 'c1',
      title: 'Uluwatu Temple',
      date: DateTime.now().add(const Duration(days: 45)),
      startTime: '5:00 PM',
      duration: 60,
      location: 'Uluwatu, Bali',
      icon: Icons.temple_hindu_outlined,
      color: const Color(0xFF00BFA5),
    ),
    MockActivity(
      id: 'c2',
      title: 'Kecak Fire Dance',
      date: DateTime.now().add(const Duration(days: 45)),
      startTime: '6:30 PM',
      duration: 90,
      location: 'Uluwatu Amphitheatre',
      icon: Icons.local_fire_department_outlined,
      color: const Color(0xFFFF6B6B),
    ),
    MockActivity(
      id: 'c3',
      title: 'Ubud Rice Terraces',
      date: DateTime.now().add(const Duration(days: 47)),
      startTime: '8:00 AM',
      duration: 120,
      location: 'Tegallalang, Ubud',
      icon: Icons.landscape_outlined,
      color: const Color(0xFF4DD0E1),
    ),
  ],
  '4': [
    MockActivity(
      id: 'd1',
      title: 'Statue of Liberty',
      date: DateTime.now().subtract(const Duration(days: 30)),
      startTime: '10:00 AM',
      duration: 120,
      location: 'Liberty Island, NYC',
      icon: Icons.gavel_outlined,
      color: const Color(0xFFFF9800),
      isDone: true,
    ),
    MockActivity(
      id: 'd2',
      title: 'Central Park Walk',
      date: DateTime.now().subtract(const Duration(days: 29)),
      startTime: '9:00 AM',
      duration: 120,
      location: 'Central Park, NYC',
      icon: Icons.park_outlined,
      color: const Color(0xFF00BFA5),
      isDone: true,
    ),
    MockActivity(
      id: 'd3',
      title: 'Times Square',
      date: DateTime.now().subtract(const Duration(days: 29)),
      startTime: '8:00 PM',
      duration: 60,
      location: 'Midtown Manhattan',
      icon: Icons.theater_comedy_outlined,
      color: const Color(0xFF6C63FF),
      isDone: true,
    ),
  ],
  '5': [
    MockActivity(
      id: 'e1',
      title: 'Tower of London',
      date: DateTime.now().subtract(const Duration(days: 60)),
      startTime: '10:00 AM',
      duration: 150,
      location: 'Tower Hill, London',
      icon: Icons.castle_outlined,
      color: const Color(0xFF5C6BC0),
      isDone: true,
    ),
    MockActivity(
      id: 'e2',
      title: 'London Eye',
      date: DateTime.now().subtract(const Duration(days: 60)),
      startTime: '3:00 PM',
      duration: 90,
      location: 'South Bank, London',
      icon: Icons.panorama_outlined,
      color: const Color(0xFF4DD0E1),
      isDone: true,
    ),
  ],
};

// Per-trip documents keyed by trip id
final Map<String, List<MockDocument>> mockDocumentsByTrip = {
  '1': [
    const MockDocument(
      id: 'doc1',
      title: 'Flight Tickets',
      subtitle: 'CDG Airport · Round trip',
      icon: Icons.flight_outlined,
      color: Color(0xFF4DD0E1),
    ),
    const MockDocument(
      id: 'doc2',
      title: 'Hotel Reservation',
      subtitle: 'Le Marais Hotel · 7 nights',
      icon: Icons.hotel_outlined,
      color: Color(0xFF6C63FF),
    ),
    const MockDocument(
      id: 'doc3',
      title: 'Louvre Tickets',
      subtitle: 'Skip-the-line · 2 adults',
      icon: Icons.confirmation_number_outlined,
      color: Color(0xFFFFB74D),
    ),
  ],
  '2': [
    const MockDocument(
      id: 'doc4',
      title: 'Flight Tickets',
      subtitle: 'NRT Airport · Round trip',
      icon: Icons.flight_outlined,
      color: Color(0xFF4DD0E1),
    ),
    const MockDocument(
      id: 'doc5',
      title: 'Hotel Booking',
      subtitle: 'Shinjuku Grand Hotel · 9 nights',
      icon: Icons.hotel_outlined,
      color: Color(0xFFFF6B6B),
    ),
    const MockDocument(
      id: 'doc6',
      title: 'Travel Insurance',
      subtitle: 'WorldCover Premium · Japan',
      icon: Icons.shield_outlined,
      color: Color(0xFF00BFA5),
    ),
    const MockDocument(
      id: 'doc7',
      title: 'JR Pass',
      subtitle: '14-day unlimited rail pass',
      icon: Icons.train_outlined,
      color: Color(0xFF6C63FF),
    ),
  ],
  '3': [
    const MockDocument(
      id: 'doc8',
      title: 'Flight Tickets',
      subtitle: 'Ngurah Rai Airport · Round trip',
      icon: Icons.flight_outlined,
      color: Color(0xFF4DD0E1),
    ),
  ],
  '4': [],
  '5': [],
};
