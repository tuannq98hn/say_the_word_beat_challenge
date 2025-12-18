import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import '../base/network/api_client.dart';
import '../data/remote/api_service.dart';
import '../data/local/local_datasource.dart';
import '../common/local_store/local_store.dart';
import 'injection_container.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => await getIt.init();

@module
abstract class AppModule {
  @lazySingleton
  Dio get dio => Dio();

  @lazySingleton
  ApiClient get apiClient => ApiClient(getIt<Dio>());

  @lazySingleton
  ApiService get apiService => ApiService(
        getIt<Dio>(),
        baseUrl: const String.fromEnvironment('BASE_URL', defaultValue: 'https://api.example.com'),
      );

  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @lazySingleton
  LocalStore get localStore => LocalStore(getIt<SharedPreferences>());

  @lazySingleton
  LocalDataSource get localDataSource => LocalDataSourceImpl(getIt<LocalStore>());
}

