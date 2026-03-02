import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/trip_entity.dart';
import '../entities/trip_params.dart';
import '../repositories/trip_repository.dart';

class CreateTripUseCase implements UseCase<TripEntity, CreateTripParams> {
  final TripRepository repository;
  const CreateTripUseCase(this.repository);

  @override
  Future<Either<Failure, TripEntity>> call(CreateTripParams params) {
    return repository.createTrip(params);
  }
}
