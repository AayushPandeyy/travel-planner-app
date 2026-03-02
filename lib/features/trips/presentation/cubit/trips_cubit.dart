import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/entities/trip_params.dart';
import '../../domain/usecases/create_trip_usecase.dart';
import '../../domain/usecases/delete_trip_usecase.dart';
import '../../domain/usecases/get_trips_usecase.dart';
import '../../domain/usecases/update_trip_usecase.dart';
import 'trips_state.dart';

class TripsCubit extends Cubit<TripsState> {
  final GetTripsUseCase getTripsUseCase;
  final CreateTripUseCase createTripUseCase;
  final UpdateTripUseCase updateTripUseCase;
  final DeleteTripUseCase deleteTripUseCase;

  TripsCubit({
    required this.getTripsUseCase,
    required this.createTripUseCase,
    required this.updateTripUseCase,
    required this.deleteTripUseCase,
  }) : super(const TripsInitial());

  List<TripEntity> get _currentTrips =>
      state is TripsLoaded ? (state as TripsLoaded).trips : [];

  Future<void> loadTrips() async {
    emit(const TripsLoading());
    final result = await getTripsUseCase(const NoParams());
    result.fold(
      (failure) => emit(TripsError(failure.message)),
      (trips) => emit(TripsLoaded(trips)),
    );
  }

  Future<void> createTrip(CreateTripParams params) async {
    final current = _currentTrips;
    emit(TripActionLoading(current));
    final result = await createTripUseCase(params);
    result.fold(
      (failure) => emit(
        TripActionFailure(message: failure.message, currentTrips: current),
      ),
      (newTrip) {
        final updated = [...current, newTrip];
        emit(
          TripActionSuccess(
            trips: updated,
            message: 'Trip created successfully!',
          ),
        );
        emit(TripsLoaded(updated));
      },
    );
  }

  Future<void> updateTrip(UpdateTripParams params) async {
    final current = _currentTrips;
    emit(TripActionLoading(current));
    final result = await updateTripUseCase(params);
    result.fold(
      (failure) => emit(
        TripActionFailure(message: failure.message, currentTrips: current),
      ),
      (updatedTrip) {
        final updated = current
            .map((t) => t.id == updatedTrip.id ? updatedTrip : t)
            .toList();
        emit(
          TripActionSuccess(
            trips: updated,
            message: 'Trip updated successfully!',
          ),
        );
        emit(TripsLoaded(updated));
      },
    );
  }

  Future<void> deleteTrip(String id) async {
    final current = _currentTrips;
    emit(TripActionLoading(current));
    final result = await deleteTripUseCase(DeleteTripParams(id));
    result.fold(
      (failure) => emit(
        TripActionFailure(message: failure.message, currentTrips: current),
      ),
      (_) {
        final updated = current.where((t) => t.id != id).toList();
        emit(
          TripActionSuccess(
            trips: updated,
            message: 'Trip deleted successfully!',
          ),
        );
        emit(TripsLoaded(updated));
      },
    );
  }
}
