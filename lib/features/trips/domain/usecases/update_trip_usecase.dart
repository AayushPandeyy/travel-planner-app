import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/trip_entity.dart';
import '../entities/trip_params.dart';
import '../repositories/trip_repository.dart';

class UpdateTripUseCase implements UseCase<TripEntity, UpdateTripParams> {
  final TripRepository repository;
  const UpdateTripUseCase(this.repository);

  @override
  Future<Either<Failure, TripEntity>> call(UpdateTripParams params) {
    return repository.updateTrip(params);
  }
}
