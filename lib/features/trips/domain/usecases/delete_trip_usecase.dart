import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/trip_params.dart';
import '../repositories/trip_repository.dart';

class DeleteTripUseCase implements UseCase<String, DeleteTripParams> {
  final TripRepository repository;
  const DeleteTripUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(DeleteTripParams params) {
    return repository.deleteTrip(params);
  }
}
