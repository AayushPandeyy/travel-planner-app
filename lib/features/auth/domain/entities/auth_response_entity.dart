import 'package:equatable/equatable.dart';
import 'user_entity.dart';

class AuthResponseEntity extends Equatable {
  final String accessToken;
  final String refreshToken;
  final bool success;
  final String message;
  final UserEntity user;

  const AuthResponseEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.success,
    required this.message,
    required this.user,
  });

  @override
  List<Object?> get props => [
    accessToken,
    refreshToken,
    success,
    message,
    user,
  ];
}
