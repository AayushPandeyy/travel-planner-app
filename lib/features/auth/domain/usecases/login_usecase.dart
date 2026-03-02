import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_response_entity.dart';
import '../entities/login_params.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase implements UseCase<AuthResponseEntity, LoginParams> {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResponseEntity>> call(LoginParams params) {
    return repository.login(params);
  }
}
