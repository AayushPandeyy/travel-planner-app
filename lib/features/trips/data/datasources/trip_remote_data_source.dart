import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../models/trip_model.dart';
import '../../domain/entities/trip_params.dart';

abstract class TripRemoteDataSource {
  Future<List<TripModel>> getTrips();
  Future<TripModel> createTrip(CreateTripParams params);
  Future<TripModel> updateTrip(UpdateTripParams params);
  Future<String> deleteTrip(String id);
}

class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  final ApiClient apiClient;
  const TripRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<TripModel>> getTrips() async {
    try {
      final response = await apiClient.dio.get(ApiConstants.trips);
      final data = response.data;
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data['trips'] != null) {
        list = data['trips'] as List<dynamic>;
      } else if (data is Map && data['data'] != null) {
        list = data['data'] as List<dynamic>;
      } else {
        list = [];
      }
      return list
          .map((e) => TripModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TripModel> createTrip(CreateTripParams params) async {
    try {
      final body = {
        'name': params.name,
        'destination': params.destination,
        'emoji': params.emoji,
        'colorHex': params.colorHex,
        'startDate': params.startDate.toIso8601String(),
        'endDate': params.endDate.toIso8601String(),
        'totalBudget': params.totalBudget,
      };
      final response = await apiClient.dio.post(ApiConstants.trips, data: body);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final tripJson = data['trip'] ?? data['data'] ?? data;
        return TripModel.fromJson(tripJson as Map<String, dynamic>);
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
  Future<TripModel> updateTrip(UpdateTripParams params) async {
    try {
      final body = <String, dynamic>{};
      if (params.name != null) body['name'] = params.name;
      if (params.destination != null) body['destination'] = params.destination;
      if (params.emoji != null) body['emoji'] = params.emoji;
      if (params.colorHex != null) body['colorHex'] = params.colorHex;
      if (params.startDate != null) {
        body['startDate'] = params.startDate!.toIso8601String();
      }
      if (params.endDate != null) {
        body['endDate'] = params.endDate!.toIso8601String();
      }
      if (params.totalBudget != null) body['totalBudget'] = params.totalBudget;

      final response = await apiClient.dio.put(
        ApiConstants.tripById(params.id),
        data: body,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final tripJson = data['trip'] ?? data['data'] ?? data;
        return TripModel.fromJson(tripJson as Map<String, dynamic>);
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
  Future<String> deleteTrip(String id) async {
    try {
      await apiClient.dio.delete(ApiConstants.tripById(id));
      return id;
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
        return (data['message'] ?? data['error'] ?? e.message ?? 'Server error')
            .toString();
      }
    } catch (_) {}
    return e.message ?? 'Network error';
  }
}
