import 'package:equatable/equatable.dart';
import '../../domain/entities/trip_entity.dart';

abstract class TripsState extends Equatable {
  const TripsState();
  @override
  List<Object?> get props => [];
}

class TripsInitial extends TripsState {
  const TripsInitial();
}

class TripsLoading extends TripsState {
  const TripsLoading();
}

class TripsLoaded extends TripsState {
  final List<TripEntity> trips;
  const TripsLoaded(this.trips);

  List<TripEntity> get upcomingTrips =>
      trips
          .where(
            (t) =>
                t.status == TripStatus.upcoming ||
                t.status == TripStatus.ongoing,
          )
          .toList()
        ..sort((a, b) => a.startDate.compareTo(b.startDate));

  List<TripEntity> get pastTrips =>
      trips.where((t) => t.status == TripStatus.completed).toList()
        ..sort((a, b) => b.startDate.compareTo(a.startDate));

  @override
  List<Object?> get props => [trips];
}

class TripsError extends TripsState {
  final String message;
  const TripsError(this.message);
  @override
  List<Object?> get props => [message];
}

// Action states (create / update / delete)
class TripActionLoading extends TripsState {
  final List<TripEntity> currentTrips;
  const TripActionLoading(this.currentTrips);
  @override
  List<Object?> get props => [currentTrips];
}

class TripActionSuccess extends TripsState {
  final List<TripEntity> trips;
  final String message;
  const TripActionSuccess({required this.trips, this.message = 'Success'});
  @override
  List<Object?> get props => [trips, message];
}

class TripActionFailure extends TripsState {
  final String message;
  final List<TripEntity> currentTrips;
  const TripActionFailure({required this.message, required this.currentTrips});
  @override
  List<Object?> get props => [message, currentTrips];
}
