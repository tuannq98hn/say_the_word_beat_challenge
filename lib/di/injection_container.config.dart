// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:say_word_challenge/base/network/api_client.dart' as _i261;
import 'package:say_word_challenge/common/local_store/local_store.dart'
    as _i602;
import 'package:say_word_challenge/data/local/local_datasource.dart' as _i252;
import 'package:say_word_challenge/data/remote/api_service.dart' as _i937;
import 'package:say_word_challenge/data/repositories/example_repository.dart'
    as _i144;
import 'package:say_word_challenge/di/injection_container.dart' as _i652;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i361.Dio>(() => appModule.dio);
    gh.lazySingleton<_i261.ApiClient>(() => appModule.apiClient);
    gh.lazySingleton<_i937.ApiService>(() => appModule.apiService);
    gh.lazySingleton<_i602.LocalStore>(() => appModule.localStore);
    gh.lazySingleton<_i252.LocalDataSource>(() => appModule.localDataSource);
    gh.factory<_i144.ExampleRepository>(
      () => _i144.ExampleRepository(gh<_i937.ApiService>()),
    );
    return this;
  }
}

class _$AppModule extends _i652.AppModule {}
