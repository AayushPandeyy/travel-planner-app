import 'package:equatable/equatable.dart';
import '../../domain/entities/activity_entity.dart';

abstract class ActivitiesState extends Equatable {
  const ActivitiesState();
  @override
  List<Object?> get props => [];
}

class ActivitiesInitial extends ActivitiesState {
  const ActivitiesInitial();
}

class ActivitiesLoading extends ActivitiesState {
  const ActivitiesLoading();
}

class ActivitiesLoaded extends ActivitiesState {
  final List<ActivityEntity> activities;
  const ActivitiesLoaded(this.activities);

  int get doneCount => activities.where((a) => a.isDone).length;

  @override
  List<Object?> get props => [activities];
}

class ActivitiesError extends ActivitiesState {
  final String message;
  const ActivitiesError(this.message);
  @override
  List<Object?> get props => [message];
}

// Action states (create / toggle / delete)
class ActivityActionLoading extends ActivitiesState {
  final List<ActivityEntity> currentActivities;
  const ActivityActionLoading(this.currentActivities);
  @override
  List<Object?> get props => [currentActivities];
}

class ActivityActionSuccess extends ActivitiesState {
  final List<ActivityEntity> activities;
  final String message;
  const ActivityActionSuccess({
    required this.activities,
    this.message = 'Success',
  });
  @override
  List<Object?> get props => [activities, message];
}

class ActivityActionFailure extends ActivitiesState {
  final String message;
  final List<ActivityEntity> currentActivities;
  const ActivityActionFailure({
    required this.message,
    required this.currentActivities,
  });
  @override
  List<Object?> get props => [message, currentActivities];
}
