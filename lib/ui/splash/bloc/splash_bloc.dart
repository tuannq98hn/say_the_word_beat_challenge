import 'dart:async';

import 'package:flutter_ads_native/interstitial_ads/interstitial_ads.dart';
import 'package:flutter_ads_native/rewarded_ads/rewarded_ads.dart';
import 'package:flutter_ads_native/rewarded_interstitial_ads/rewarded_interstitial_ads.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:say_word_challenge/common/utils/app_broadcast.dart';
import 'package:say_word_challenge/services/remote_config_service.dart';

import '../../../base/base_bloc.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends BaseBloc<SplashEvent, SplashState> {
  StreamSubscription? _appEvent;

  SplashBloc() : super(const SplashState()) {
    on<SplashInitialized>(_onSplashInitialized);
    on<OnCloseNative>(_onCloseNative);
    on<OnAppOpenAdEvent>(_onAppOpenAdEvent);
  }

  Future<void> _onSplashInitialized(
    SplashInitialized event,
    Emitter<SplashState> emit,
  ) async {
    _handleListenAppEvent(emit);
    // Init Remote Config (setDefaults + fetchAndActivate)
    final interstitialAdUnitIds = RemoteConfigService.instance
        .getInterstitialAdUnitIds();
    final rewardedAdUnitIds = RemoteConfigService.instance
        .getRewardedAdUnitIds();
    final rewardedInterstitialAdUnitIds = RemoteConfigService.instance
        .getRewardedInterstitialAdUnitIds();
    await InterstitialAds.init(interstitialAdUnitIds: interstitialAdUnitIds);
    await RewardedAds.init(rewardedAdUnitIds: rewardedAdUnitIds);
    await RewardedInterstitialAds.init(
      rewardedInterstitialAdUnitIds: rewardedInterstitialAdUnitIds,
    );
    emit(state.copyWith(isLoading: false));
  }

  void _handleListenAppEvent(Emitter<SplashState> emit) {
    _appEvent = AppBroadCast().listen((event) => _handleAppEvent(event));
  }

  @override
  Future<void> close() {
    _appEvent?.cancel();
    return super.close();
  }

  void _handleAppEvent(AppBroadCastData event) {
    switch (event) {
      case OnOpenAppSuccess _:
      case OnOpenAppLoadFailed _:
        add(OnAppOpenAdEvent()); // show native full screen
        break;
      default:
        break;
    }
  }

  Future<void> _onCloseNative(
    OnCloseNative event,
    Emitter<SplashState> emit,
  ) async {
    emit(state.copyWith(isCloseNative: true));
    await Future.delayed(Duration(seconds: 1));
    emit(state.copyWith(isCompleted: true));
  }

  FutureOr<void> _onAppOpenAdEvent(
    OnAppOpenAdEvent event,
    Emitter<SplashState> emit,
  ) {
    // emit(state.copyWith(isOpenAppSuccess: true));
    emit(state.copyWith(isCompleted: true));
  }
}
