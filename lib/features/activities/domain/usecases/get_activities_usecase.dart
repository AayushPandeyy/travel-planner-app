import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/activity_entity.dart';
import '../entities/activity_params.dart';
import '../repositories/activity_repository.dart';

class GetActivitiesUseCase
    implements UseCase<List<ActivityEntity>, GetActivitiesParams> {
  final ActivityRepository repository;
  const GetActivitiesUseCase(this.repository);

  @override
  Future<Either<Failure, List<ActivityEntity>>> call(
    GetActivitiesParams params,
  ) {
    return repository.getActivities(params);
  }
}
