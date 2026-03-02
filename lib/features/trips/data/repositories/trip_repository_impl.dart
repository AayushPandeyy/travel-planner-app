import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/entities/trip_params.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_remote_data_source.dart';

class TripRepositoryImpl implements TripRepository {
  final TripRemoteDataSource remoteDataSource;
  const TripRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TripEntity>>> getTrips() async {
    try {
      final trips = await remoteDataSource.getTrips();
      return Right(trips);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TripEntity>> createTrip(
    CreateTripParams params,
  ) async {
    try {
      final trip = await remoteDataSource.createTrip(params);
      return Right(trip);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TripEntity>> updateTrip(
    UpdateTripParams params,
  ) async {
    try {
      final trip = await remoteDataSource.updateTrip(params);
      return Right(trip);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deleteTrip(DeleteTripParams params) async {
    try {
      final id = await remoteDataSource.deleteTrip(params.id);
      return Right(id);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
