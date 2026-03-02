import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_response_entity.dart';
import '../entities/register_params.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<AuthResponseEntity, RegisterParams> {
  final AuthRepository repository;

  const RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResponseEntity>> call(RegisterParams params) {
    return repository.register(params);
  }
}
