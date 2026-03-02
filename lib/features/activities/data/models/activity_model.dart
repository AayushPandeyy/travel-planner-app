import '../../domain/entities/activity_entity.dart';

class ActivityModel extends ActivityEntity {
  const ActivityModel({
    required super.id,
    required super.tripId,
    required super.title,
    required super.date,
    required super.startTime,
    required super.duration,
    required super.location,
    required super.iconName,
    required super.colorHex,
    super.isDone,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    final String id = (json['_id'] ?? json['id'] ?? '').toString();
    final String tripId = (json['tripId'] ?? '').toString();
    final String title = json['title']?.toString() ?? '';

    final DateTime date = json['date'] != null
        ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
        : DateTime.now();

    final String startTime = json['startTime']?.toString() ?? '9:00 AM';
    final int duration = (json['duration'] ?? 60) is int
        ? json['duration'] as int
        : int.tryParse(json['duration'].toString()) ?? 60;
    final String location = json['location']?.toString() ?? '';
    final String iconName =
        json['icon']?.toString() ?? json['iconName']?.toString() ?? 'event';
    final String colorHex =
        json['color']?.toString() ?? json['colorHex']?.toString() ?? '#6C63FF';
    final bool isDone = json['isDone'] == true;

    return ActivityModel(
      id: id,
      tripId: tripId,
      title: title,
      date: date,
      startTime: startTime,
      duration: duration,
      location: location,
      iconName: iconName,
      colorHex: colorHex,
      isDone: isDone,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'date': date.toIso8601String(),
    'startTime': startTime,
    'duration': duration,
    'location': location,
    'icon': iconName,
    'color': colorHex,
    'isDone': isDone,
  };
}
