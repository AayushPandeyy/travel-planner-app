import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/activity_entity.dart';
import '../../domain/entities/activity_params.dart';
import '../../domain/usecases/get_activities_usecase.dart';
import '../../domain/usecases/create_activity_usecase.dart';
import '../../domain/usecases/toggle_activity_usecase.dart';
import '../../domain/usecases/delete_activity_usecase.dart';
import 'activities_state.dart';

class ActivitiesCubit extends Cubit<ActivitiesState> {
  final GetActivitiesUseCase getActivitiesUseCase;
  final CreateActivityUseCase createActivityUseCase;
  final ToggleActivityUseCase toggleActivityUseCase;
  final DeleteActivityUseCase deleteActivityUseCase;

  ActivitiesCubit({
    required this.getActivitiesUseCase,
    required this.createActivityUseCase,
    required this.toggleActivityUseCase,
    required this.deleteActivityUseCase,
  }) : super(const ActivitiesInitial());

  List<ActivityEntity> get _current =>
      state is ActivitiesLoaded ? (state as ActivitiesLoaded).activities : [];

  Future<void> loadActivities(String tripId) async {
    emit(const ActivitiesLoading());
    final result = await getActivitiesUseCase(GetActivitiesParams(tripId));
    result.fold(
      (failure) => emit(ActivitiesError(failure.message)),
      (activities) => emit(ActivitiesLoaded(activities)),
    );
  }

  Future<void> createActivity(CreateActivityParams params) async {
    final current = _current;
    emit(ActivityActionLoading(current));
    final result = await createActivityUseCase(params);
    result.fold(
      (failure) => emit(
        ActivityActionFailure(
          message: failure.message,
          currentActivities: current,
        ),
      ),
      (newActivity) {
        final updated = [...current, newActivity];
        emit(
          ActivityActionSuccess(
            activities: updated,
            message: 'Activity added!',
          ),
        );
        emit(ActivitiesLoaded(updated));
      },
    );
  }

  Future<void> toggleActivity(ToggleActivityParams params) async {
    final current = _current;
    // Optimistic update: flip isDone immediately
    final optimistic = current.map((a) {
      return a.id == params.activityId ? a.copyWith(isDone: params.isDone) : a;
    }).toList();
    emit(ActivitiesLoaded(optimistic));

    final result = await toggleActivityUseCase(params);
    result.fold(
      (failure) {
        // Revert on failure
        emit(ActivitiesLoaded(current));
        emit(
          ActivityActionFailure(
            message: failure.message,
            currentActivities: current,
          ),
        );
      },
      (updated) {
        final finalList = optimistic
            .map((a) => a.id == updated.id ? updated : a)
            .toList();
        emit(ActivitiesLoaded(finalList));
      },
    );
  }

  Future<void> deleteActivity(DeleteActivityParams params) async {
    final current = _current;
    emit(ActivityActionLoading(current));
    final result = await deleteActivityUseCase(params);
    result.fold(
      (failure) => emit(
        ActivityActionFailure(
          message: failure.message,
          currentActivities: current,
        ),
      ),
      (_) {
        final updated = current
            .where((a) => a.id != params.activityId)
            .toList();
        emit(
          ActivityActionSuccess(
            activities: updated,
            message: 'Activity deleted.',
          ),
        );
        emit(ActivitiesLoaded(updated));
      },
    );
  }
}
