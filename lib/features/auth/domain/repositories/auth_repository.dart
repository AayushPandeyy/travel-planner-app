import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_response_entity.dart';
import '../entities/login_params.dart';
import '../entities/register_params.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponseEntity>> register(RegisterParams params);
  Future<Either<Failure, AuthResponseEntity>> login(LoginParams params);
}
