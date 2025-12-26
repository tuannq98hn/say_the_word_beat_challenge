import 'dart:async';

import 'package:flutter/services.dart';
import 'package:say_word_challenge/base/base_bloc.dart';
import 'package:say_word_challenge/common/utils/app_broadcast.dart';

import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends BaseBloc<AppEvent, AppState> {
  static const _appOpenAdEventChannel = EventChannel(
    "com.say.word.challenge.say_word_challenge/app_events",
  );
  StreamSubscription<dynamic>? _appOpenAdEventSubscription;

  AppBloc() : super(const AppState()) {
    _appOpenAdEventSubscription = _appOpenAdEventChannel
        .receiveBroadcastStream()
        .listen(_handleNativeEvent);
  }

  @override
  Future<void> close() {
    _appOpenAdEventSubscription?.cancel();
    return super.close();
  }

  void _handleNativeEvent(event) {
    if (event is Map) {
      final eventType = event['event'] as String?;

      if (eventType == "app_open_ad_closed") {
        AppBroadCast().push(OnOpenAppSuccess());
      }
      if (eventType == "app_open_ad_load_failed") {
        AppBroadCast().push(OnOpenAppLoadFailed());
      }
    }
  }
}
