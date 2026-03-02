import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../models/activity_model.dart';
import '../../domain/entities/activity_params.dart';

abstract class ActivityRemoteDataSource {
  Future<List<ActivityModel>> getActivities(String tripId);
  Future<ActivityModel> createActivity(CreateActivityParams params);
  Future<ActivityModel> toggleActivity(ToggleActivityParams params);
  Future<String> deleteActivity(DeleteActivityParams params);
}

class ActivityRemoteDataSourceImpl implements ActivityRemoteDataSource {
  final ApiClient apiClient;
  const ActivityRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ActivityModel>> getActivities(String tripId) async {
    try {
      final response = await apiClient.dio.get(ApiConstants.activities(tripId));
      final data = response.data;
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data['activities'] != null) {
        list = data['activities'] as List<dynamic>;
      } else if (data is Map && data['data'] != null) {
        list = data['data'] as List<dynamic>;
      } else {
        list = [];
      }
      return list
          .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ActivityModel> createActivity(CreateActivityParams params) async {
    try {
      final body = {
        'title': params.title,
        'date': params.date.toIso8601String(),
        'startTime': params.startTime,
        'duration': params.duration,
        'location': params.location,
        'icon': params.iconName,
        'color': params.colorHex,
        'isDone': false,
      };
      final response = await apiClient.dio.post(
        ApiConstants.activities(params.tripId),
        data: body,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json = data['activity'] ?? data['data'] ?? data;
        return ActivityModel.fromJson(json as Map<String, dynamic>);
      }
      throw const ServerException('Invalid response format');
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e));
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ActivityModel> toggleActivity(ToggleActivityParams params) async {
    try {
      final response = await apiClient.dio.patch(
        ApiConstants.activityById(params.tripId, params.activityId),
        data: {'isDone': params.isDone},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final json = data['activity'] ?? data['data'] ?? data;
        return ActivityModel.fromJson(json as Map<String, dynamic>);
      }
      throw const ServerException('Invalid response format');
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e));
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> deleteActivity(DeleteActivityParams params) async {
    try {
      await apiClient.dio.delete(
        ApiConstants.activityById(params.tripId, params.activityId),
      );
      return params.activityId;
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  String _extractMessage(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map) {
        return data['message']?.toString() ??
            data['error']?.toString() ??
            e.message ??
            'Server error';
      }
    } catch (_) {}
    return e.message ?? 'Server error';
  }
}
