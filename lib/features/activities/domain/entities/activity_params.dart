class GetActivitiesParams {
  final String tripId;
  const GetActivitiesParams(this.tripId);
}

class CreateActivityParams {
  final String tripId;
  final String title;
  final DateTime date;
  final String startTime;
  final int duration;
  final String location;
  final String iconName;
  final String colorHex;

  const CreateActivityParams({
    required this.tripId,
    required this.title,
    required this.date,
    required this.startTime,
    required this.duration,
    required this.location,
    required this.iconName,
    required this.colorHex,
  });
}

class ToggleActivityParams {
  final String tripId;
  final String activityId;
  final bool isDone;

  const ToggleActivityParams({
    required this.tripId,
    required this.activityId,
    required this.isDone,
  });
}

class DeleteActivityParams {
  final String tripId;
  final String activityId;

  const DeleteActivityParams({required this.tripId, required this.activityId});
}
