class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://192.168.1.7:5000/api';

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';

  // Trip endpoints
  static const String trips = '/trips';
  static String tripById(String id) => '/trips/$id';

  // Activity endpoints
  static String activities(String tripId) => '/trips/$tripId/activities';
  static String activityById(String tripId, String activityId) =>
      '/trips/$tripId/activities/$activityId';
}
