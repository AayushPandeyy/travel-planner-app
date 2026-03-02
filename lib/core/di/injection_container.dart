import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/cubit/login_cubit.dart';
import '../../features/auth/presentation/cubit/register_cubit.dart';
import '../../features/trips/data/datasources/trip_remote_data_source.dart';
import '../../features/trips/data/repositories/trip_repository_impl.dart';
import '../../features/trips/domain/repositories/trip_repository.dart';
import '../../features/trips/domain/usecases/create_trip_usecase.dart';
import '../../features/trips/domain/usecases/delete_trip_usecase.dart';
import '../../features/trips/domain/usecases/get_trips_usecase.dart';
import '../../features/trips/domain/usecases/update_trip_usecase.dart';
import '../../features/activities/data/datasources/activity_remote_data_source.dart';
import '../../features/activities/data/repositories/activity_repository_impl.dart';
import '../../features/activities/domain/repositories/activity_repository.dart';
import '../../features/activities/domain/usecases/create_activity_usecase.dart';
import '../../features/activities/domain/usecases/delete_activity_usecase.dart';
import '../../features/activities/domain/usecases/get_activities_usecase.dart';
import '../../features/activities/domain/usecases/toggle_activity_usecase.dart';
import '../../features/activities/presentation/cubit/activities_cubit.dart';
import '../../features/trips/presentation/cubit/trips_cubit.dart';
import '../network/api_client.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ──────────────── Core ────────────────
  // SharedPreferences must be registered before ApiClient
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<ApiClient>(() => ApiClient(prefs: sl()));

  // ──────────────── Auth: Data Sources ────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(prefs: sl()),
  );

  // ──────────────── Auth: Repositories ────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // ──────────────── Auth: Use Cases ────────────────
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));

  // ──────────────── Auth: Cubits ────────────────
  sl.registerFactory(() => RegisterCubit(registerUseCase: sl()));
  sl.registerFactory(() => LoginCubit(loginUseCase: sl()));

  // ──────────────── Trips: Data Sources ────────────────
  sl.registerLazySingleton<TripRemoteDataSource>(
    () => TripRemoteDataSourceImpl(apiClient: sl()),
  );

  // ──────────────── Trips: Repositories ────────────────
  sl.registerLazySingleton<TripRepository>(
    () => TripRepositoryImpl(remoteDataSource: sl()),
  );

  // ──────────────── Trips: Use Cases ────────────────
  sl.registerLazySingleton(() => GetTripsUseCase(sl()));
  sl.registerLazySingleton(() => CreateTripUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTripUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTripUseCase(sl()));

  // ──────────────── Trips: Cubits ────────────────
  sl.registerFactory(
    () => TripsCubit(
      getTripsUseCase: sl(),
      createTripUseCase: sl(),
      updateTripUseCase: sl(),
      deleteTripUseCase: sl(),
    ),
  );

  // ──────────────── Activities: Data Sources ────────────────
  sl.registerLazySingleton<ActivityRemoteDataSource>(
    () => ActivityRemoteDataSourceImpl(apiClient: sl()),
  );

  // ──────────────── Activities: Repositories ────────────────
  sl.registerLazySingleton<ActivityRepository>(
    () => ActivityRepositoryImpl(remoteDataSource: sl()),
  );

  // ──────────────── Activities: Use Cases ────────────────
  sl.registerLazySingleton(() => GetActivitiesUseCase(sl()));
  sl.registerLazySingleton(() => CreateActivityUseCase(sl()));
  sl.registerLazySingleton(() => ToggleActivityUseCase(sl()));
  sl.registerLazySingleton(() => DeleteActivityUseCase(sl()));

  // ──────────────── Activities: Cubits ────────────────
  sl.registerFactory(
    () => ActivitiesCubit(
      getActivitiesUseCase: sl(),
      createActivityUseCase: sl(),
      toggleActivityUseCase: sl(),
      deleteActivityUseCase: sl(),
    ),
  );
}
