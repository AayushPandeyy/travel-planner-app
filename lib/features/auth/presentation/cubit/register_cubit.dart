import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/register_params.dart';
import '../../domain/usecases/register_usecase.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterUseCase _registerUseCase;

  RegisterCubit({required RegisterUseCase registerUseCase})
    : _registerUseCase = registerUseCase,
      super(const RegisterInitial());

  Future<void> register({
    required String username,
    required String name,
    required String email,
    required String password,
  }) async {
    emit(const RegisterLoading());

    final params = RegisterParams(
      username: username,
      name: name,
      email: email,
      password: password,
    );

    final result = await _registerUseCase(params);

    result.fold(
      (failure) => emit(RegisterFailure(failure.message)),
      (response) => emit(RegisterSuccess(response)),
    );
  }
}
