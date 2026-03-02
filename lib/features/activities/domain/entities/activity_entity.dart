import 'package:flutter/material.dart';

class ActivityEntity {
  final String id;
  final String tripId;
  final String title;
  final DateTime date;
  final String startTime; // e.g. "9:00 AM"
  final int duration; // minutes
  final String location;
  final String iconName; // e.g. "monument", "museum"
  final String colorHex; // e.g. "#E24A4A"
  final bool isDone;

  const ActivityEntity({
    required this.id,
    required this.tripId,
    required this.title,
    required this.date,
    required this.startTime,
    required this.duration,
    required this.location,
    required this.iconName,
    required this.colorHex,
    this.isDone = false,
  });

  // ── Icon name → IconData map ──────────────────────────────────────────────
  static const Map<String, IconData> iconMap = {
    'photo': Icons.photo_camera_outlined,
    'museum': Icons.museum_outlined,
    'food': Icons.restaurant_outlined,
    'boat': Icons.directions_boat_outlined,
    'nature': Icons.landscape_outlined,
    'monument': Icons.account_balance_outlined,
    'temple': Icons.temple_buddhist_outlined,
    'beach': Icons.beach_access_outlined,
    'walk': Icons.directions_walk_outlined,
    'cafe': Icons.local_cafe_outlined,
    'nightlife': Icons.nightlife_outlined,
    'shopping': Icons.shopping_bag_outlined,
    'sports': Icons.sports_soccer_outlined,
    'spa': Icons.spa_outlined,
    'hiking': Icons.hiking_outlined,
    'bar': Icons.local_bar_outlined,
    'drive': Icons.directions_car_outlined,
    'flight': Icons.flight_outlined,
    'train': Icons.train_outlined,
    'event': Icons.confirmation_number_outlined,
  };

  // ── Computed display properties ───────────────────────────────────────────

  IconData get displayIcon =>
      iconMap[iconName.toLowerCase()] ?? Icons.event_note_outlined;

  Color get displayColor {
    try {
      final hex = colorHex.startsWith('#') ? colorHex.substring(1) : colorHex;
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF6C63FF);
    }
  }

  /// "Jun 5 · 9:00 AM"
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

  /// "2h", "1h 30min", "45min"
  String get durationString {
    if (duration < 60) return '${duration}min';
    final h = duration ~/ 60;
    final m = duration % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}min';
  }

  ActivityEntity copyWith({
    String? id,
    String? tripId,
    String? title,
    DateTime? date,
    String? startTime,
    int? duration,
    String? location,
    String? iconName,
    String? colorHex,
    bool? isDone,
  }) {
    return ActivityEntity(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      location: location ?? this.location,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      isDone: isDone ?? this.isDone,
    );
  }
}
