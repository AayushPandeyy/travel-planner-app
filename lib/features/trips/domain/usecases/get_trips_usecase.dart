import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/trip_entity.dart';
import '../repositories/trip_repository.dart';

class GetTripsUseCase implements UseCase<List<TripEntity>, NoParams> {
  final TripRepository repository;
  const GetTripsUseCase(this.repository);

  @override
  Future<Either<Failure, List<TripEntity>>> call(NoParams params) {
    return repository.getTrips();
  }
}
