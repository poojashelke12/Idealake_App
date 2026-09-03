import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/repository/auth_repository.dart';
import '../../features/auth/view_model/auth_bloc.dart';
import '../../features/career/repository/career_repository.dart';
import '../../features/career/view_model/career_bloc.dart';
import '../../features/documents/repository/documents_repository.dart';
import '../../features/documents/view_model/documents_bloc.dart';
import '../../features/home/repository/home_repository.dart';
import '../../features/home/view_model/home_bloc.dart';
import '../../features/news/repository/news_repository.dart';
import '../../features/news/view_model/news_bloc.dart';
import '../../features/splash/view_model/splash_bloc.dart';
import '../network/base_api_service.dart';
import '../network/dio_client.dart';
import '../network/network_api_service.dart';

/// Global Dependency Injection container
final GetIt locator = GetIt.instance;

Future<void> setupServiceLocator() async {
  // 1. External Services & Local Storage
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // 2. Network Infrastructure
  locator.registerLazySingleton<DioClient>(() => DioClient(locator<SharedPreferences>()));
  locator.registerLazySingleton<BaseApiService>(() => NetworkApiService(locator<DioClient>()));

  // 3. Repositories (Model Layer)
  locator.registerLazySingleton<NewsRepository>(
    () => NewsRepository(locator<BaseApiService>(), locator<SharedPreferences>()),
  );
  locator.registerLazySingleton<CareerRepository>(
    () => CareerRepository(locator<BaseApiService>(), locator<SharedPreferences>()),
  );
  locator.registerLazySingleton<DocumentsRepository>(
    () => DocumentsRepository(locator<BaseApiService>(), locator<SharedPreferences>()),
  );
  locator.registerLazySingleton<HomeRepository>(
    () => HomeRepository(locator<BaseApiService>(), locator<SharedPreferences>()),
  );
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepository(locator<BaseApiService>(), locator<SharedPreferences>()),
  );

  // 4. ViewModels / BLoCs (ViewModel Layer)
  locator.registerFactory<SplashBloc>(() => SplashBloc(locator<SharedPreferences>()));
  locator.registerFactory<NewsBloc>(() => NewsBloc(locator<NewsRepository>()));
  locator.registerFactory<CareerBloc>(() => CareerBloc(locator<CareerRepository>()));
  locator.registerFactory<DocumentsBloc>(() => DocumentsBloc(locator<DocumentsRepository>()));
  locator.registerFactory<HomeBloc>(() => HomeBloc(locator<HomeRepository>()));
  locator.registerFactory<AuthBloc>(() => AuthBloc(locator<AuthRepository>()));
}
