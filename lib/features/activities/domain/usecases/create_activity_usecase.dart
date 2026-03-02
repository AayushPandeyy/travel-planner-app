import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/activity_entity.dart';
import '../entities/activity_params.dart';
import '../repositories/activity_repository.dart';

class CreateActivityUseCase
    implements UseCase<ActivityEntity, CreateActivityParams> {
  final ActivityRepository repository;
  const CreateActivityUseCase(this.repository);

  @override
  Future<Either<Failure, ActivityEntity>> call(CreateActivityParams params) {
    return repository.createActivity(params);
  }
}
