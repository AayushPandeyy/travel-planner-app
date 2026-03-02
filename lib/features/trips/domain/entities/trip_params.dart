/// Parameters for creating a new trip.
class CreateTripParams {
  final String name;
  final String destination;
  final String emoji;
  final String colorHex;
  final DateTime startDate;
  final DateTime endDate;
  final double totalBudget;

  const CreateTripParams({
    required this.name,
    required this.destination,
    required this.emoji,
    required this.colorHex,
    required this.startDate,
    required this.endDate,
    required this.totalBudget,
  });
}

/// Parameters for updating an existing trip.
class UpdateTripParams {
  final String id;
  final String? name;
  final String? destination;
  final String? emoji;
  final String? colorHex;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? totalBudget;

  const UpdateTripParams({
    required this.id,
    this.name,
    this.destination,
    this.emoji,
    this.colorHex,
    this.startDate,
    this.endDate,
    this.totalBudget,
  });
}

/// Parameters for deleting a trip.
class DeleteTripParams {
  final String id;
  const DeleteTripParams(this.id);
}
