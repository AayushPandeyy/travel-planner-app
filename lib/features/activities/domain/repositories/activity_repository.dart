import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/activity_entity.dart';
import '../entities/activity_params.dart';

abstract class ActivityRepository {
  Future<Either<Failure, List<ActivityEntity>>> getActivities(
    GetActivitiesParams params,
  );
  Future<Either<Failure, ActivityEntity>> createActivity(
    CreateActivityParams params,
  );
  Future<Either<Failure, ActivityEntity>> toggleActivity(
    ToggleActivityParams params,
  );
  Future<Either<Failure, String>> deleteActivity(DeleteActivityParams params);
}
