import 'dart:async';

class AppBroadCast {
  static final AppBroadCast _instance = AppBroadCast._internal();
  final StreamController<AppBroadCastData> _streamController =
      StreamController.broadcast();

  AppBroadCast._internal();

  factory AppBroadCast() {
    return _instance;
  }

  void push(AppBroadCastData data) {
    _streamController.sink.add(data);
  }

  StreamSubscription<AppBroadCastData> listen(
    Function(AppBroadCastData event) onData,
  ) {
    return _streamController.stream.listen(onData);
  }
}

abstract class AppBroadCastData {}

class OnOpenAppSuccess implements AppBroadCastData {}

class OnOpenAppLoadFailed implements AppBroadCastData {}
