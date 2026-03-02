import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Base use case interface.
/// [Type] is the return type, [Params] is the input parameter type.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use when the use case doesn't need any parameters.
class NoParams {
  const NoParams();
}
