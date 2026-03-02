import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/activity_params.dart';
import '../repositories/activity_repository.dart';

class DeleteActivityUseCase implements UseCase<String, DeleteActivityParams> {
  final ActivityRepository repository;
  const DeleteActivityUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(DeleteActivityParams params) {
    return repository.deleteActivity(params);
  }
}
