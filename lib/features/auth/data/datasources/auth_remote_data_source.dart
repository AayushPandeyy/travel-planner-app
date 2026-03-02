import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> register(RegisterRequestModel request);
  Future<AuthResponseModel> login(LoginRequestModel request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  const AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.register,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          response.data['message'] ?? 'Registration failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkException(
          'Unable to connect to server. Check your connection.',
        );
      }

      final responseData = e.response?.data;
      String message = 'Something went wrong';
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('errors') &&
            responseData['errors'] is List) {
          final errors = responseData['errors'] as List;
          message = errors
              .map((e) => e['message'] ?? '')
              .where((m) => m.toString().isNotEmpty)
              .join('\n');
          if (message.isEmpty) message = 'Registration failed';
        } else if (responseData.containsKey('message')) {
          message = responseData['message'];
        }
      }
      throw ServerException(message, statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          response.data['message'] ?? 'Login failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkException(
          'Unable to connect to server. Check your connection.',
        );
      }

      final responseData = e.response?.data;
      String message = 'Something went wrong';
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('errors') &&
            responseData['errors'] is List) {
          final errors = responseData['errors'] as List;
          message = errors
              .map((e) => e['message'] ?? '')
              .where((m) => m.toString().isNotEmpty)
              .join('\n');
          if (message.isEmpty) message = 'Login failed';
        } else if (responseData.containsKey('message')) {
          message = responseData['message'];
        }
      }
      throw ServerException(message, statusCode: e.response?.statusCode);
    }
  }
}
