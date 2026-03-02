import '../../domain/entities/register_params.dart';

class RegisterRequestModel {
  final String username;
  final String name;
  final String email;
  final String password;

  const RegisterRequestModel({
    required this.username,
    required this.name,
    required this.email,
    required this.password,
  });

  factory RegisterRequestModel.fromParams(RegisterParams params) {
    return RegisterRequestModel(
      username: params.username,
      name: params.name,
      email: params.email,
      password: params.password,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'name': name,
      'email': email,
      'password': password,
    };
  }
}
