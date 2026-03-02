import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/activity_entity.dart';
import '../entities/activity_params.dart';
import '../repositories/activity_repository.dart';

class ToggleActivityUseCase
    implements UseCase<ActivityEntity, ToggleActivityParams> {
  final ActivityRepository repository;
  const ToggleActivityUseCase(this.repository);

  @override
  Future<Either<Failure, ActivityEntity>> call(ToggleActivityParams params) {
    return repository.toggleActivity(params);
  }
}
