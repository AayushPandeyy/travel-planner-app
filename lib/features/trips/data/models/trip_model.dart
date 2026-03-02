import '../../domain/entities/trip_entity.dart';

class TripModel extends TripEntity {
  const TripModel({
    required super.id,
    required super.name,
    required super.destination,
    super.emoji,
    super.colorHex,
    required super.startDate,
    required super.endDate,
    required super.totalBudget,
    super.spentBudget,
    super.activitiesCount,
    super.pendingDocuments,
    super.pendingReminders,
    super.status,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    // Support both `id` and `_id` from MongoDB
    final String id = (json['_id'] ?? json['id'] ?? '').toString();

    final DateTime startDate = json['startDate'] != null
        ? DateTime.parse(json['startDate'].toString())
        : DateTime.now();
    final DateTime endDate = json['endDate'] != null
        ? DateTime.parse(json['endDate'].toString())
        : DateTime.now().add(const Duration(days: 7));

    final double totalBudget = (json['totalBudget'] ?? json['budget'] ?? 0)
        .toDouble();
    final double spentBudget = (json['spentBudget'] ?? 0).toDouble();

    TripStatus status = TripStatus.upcoming;
    if (json['status'] != null) {
      switch (json['status'].toString()) {
        case 'ongoing':
          status = TripStatus.ongoing;
          break;
        case 'completed':
          status = TripStatus.completed;
          break;
        default:
          status = TripStatus.upcoming;
      }
    } else {
      final now = DateTime.now();
      if (startDate.isAfter(now)) {
        status = TripStatus.upcoming;
      } else if (endDate.isBefore(now)) {
        status = TripStatus.completed;
      } else {
        status = TripStatus.ongoing;
      }
    }

    return TripModel(
      id: id,
      name: json['name']?.toString() ?? 'Unnamed Trip',
      destination: json['destination']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '✈️',
      colorHex: json['colorHex']?.toString() ?? '#6C63FF',
      startDate: startDate,
      endDate: endDate,
      totalBudget: totalBudget,
      spentBudget: spentBudget,
      activitiesCount: (json['activitiesCount'] ?? 0) as int,
      pendingDocuments: (json['pendingDocuments'] ?? 0) as int,
      pendingReminders: (json['pendingReminders'] ?? 0) as int,
      status: status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'destination': destination,
      'emoji': emoji,
      'colorHex': colorHex,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalBudget': totalBudget,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'destination': destination,
      'emoji': emoji,
      'colorHex': colorHex,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalBudget': totalBudget,
    };
  }
}
