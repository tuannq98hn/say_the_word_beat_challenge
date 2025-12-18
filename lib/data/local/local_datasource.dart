import '../../common/local_store/local_store.dart';

abstract class LocalDataSource {
  Future<void> saveData(String key, String value);
  String? getData(String key);
  Future<void> removeData(String key);
}

class LocalDataSourceImpl implements LocalDataSource {
  final LocalStore _localStore;

  LocalDataSourceImpl(this._localStore);

  @override
  Future<void> saveData(String key, String value) async {
    await _localStore.setString(key, value);
  }

  @override
  String? getData(String key) {
    return _localStore.getString(key);
  }

  @override
  Future<void> removeData(String key) async {
    await _localStore.remove(key);
  }
}

