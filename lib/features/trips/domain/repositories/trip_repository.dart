import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/trip_entity.dart';
import '../entities/trip_params.dart';

abstract class TripRepository {
  Future<Either<Failure, List<TripEntity>>> getTrips();
  Future<Either<Failure, TripEntity>> createTrip(CreateTripParams params);
  Future<Either<Failure, TripEntity>> updateTrip(UpdateTripParams params);
  Future<Either<Failure, String>> deleteTrip(DeleteTripParams params);
}
