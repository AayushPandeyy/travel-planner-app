import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/login_params.dart';
import '../../domain/usecases/login_usecase.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase _loginUseCase;

  LoginCubit({required LoginUseCase loginUseCase})
    : _loginUseCase = loginUseCase,
      super(const LoginInitial());

  Future<void> login({required String email, required String password}) async {
    emit(const LoginLoading());

    final params = LoginParams(email: email, password: password);
    final result = await _loginUseCase(params);

    result.fold(
      (failure) => emit(LoginFailure(failure.message)),
      (response) => emit(LoginSuccess(response)),
    );
  }
}
