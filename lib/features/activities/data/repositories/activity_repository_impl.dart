import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/activity_entity.dart';
import '../../domain/entities/activity_params.dart';
import '../../domain/repositories/activity_repository.dart';
import '../datasources/activity_remote_data_source.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityRemoteDataSource remoteDataSource;
  const ActivityRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ActivityEntity>>> getActivities(
    GetActivitiesParams params,
  ) async {
    try {
      final models = await remoteDataSource.getActivities(params.tripId);
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ActivityEntity>> createActivity(
    CreateActivityParams params,
  ) async {
    try {
      final model = await remoteDataSource.createActivity(params);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ActivityEntity>> toggleActivity(
    ToggleActivityParams params,
  ) async {
    try {
      final model = await remoteDataSource.toggleActivity(params);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deleteActivity(
    DeleteActivityParams params,
  ) async {
    try {
      final id = await remoteDataSource.deleteActivity(params);
      return Right(id);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
