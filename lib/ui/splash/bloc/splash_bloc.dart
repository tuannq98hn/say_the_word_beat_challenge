import 'dart:async';

import 'package:flutter_ads_native/interstitial_ads/interstitial_ads.dart';
import 'package:flutter_ads_native/rewarded_ads/rewarded_ads.dart';
import 'package:flutter_ads_native/rewarded_interstitial_ads/rewarded_interstitial_ads.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:say_word_challenge/common/utils/app_broadcast.dart';
import 'package:say_word_challenge/services/interstitial_ads_controller.dart';
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
    await Future.delayed(Duration(milliseconds: 1500));
    await _handleShowInter();
    emit(state.copyWith(isLoading: false, isCompleted: true));
  }

  Future<void> _handleShowInter() async {
    final completer = Completer<void>(); // 1. Tạo Completer

    final origin_onInterstitialClosed = InterstitialAds.onInterstitialClosed;
    final origin_onInterstitialFailed = InterstitialAds.onInterstitialFailed;
    final origin_onInterstitialShown = InterstitialAds.onInterstitialShown;
    final origin_onInterstitialLoaded = InterstitialAds.onInterstitialLoaded;
    bool isShown = false;
    void finish() {
      InterstitialAds.onInterstitialClosed = origin_onInterstitialClosed;
      InterstitialAds.onInterstitialFailed = origin_onInterstitialFailed;
      InterstitialAds.onInterstitialShown = origin_onInterstitialShown;
      InterstitialAds.onInterstitialLoaded = origin_onInterstitialLoaded;
      if (!completer.isCompleted) {
        completer.complete();
      }
    }

    InterstitialAds.onInterstitialClosed = () {
      finish();
    };

    InterstitialAds.onInterstitialFailed = (_) {
      finish();
    };

    InterstitialAds.onInterstitialShown = () {};
    InterstitialAds.onInterstitialLoaded = () async {
      // show inter nếu action isShown = false
      if (!isShown) {
        isShown = await InterstitialAdsController.instance.showInterstitialAd(
          callerFunction: "SplashBloc._handleShowInter",
          screenClass: "SplashBloc",
        );
        if (!isShown) {
          finish();
        }
      }
    };

    isShown = await InterstitialAdsController.instance.showInterstitialAd(
      callerFunction: "SplashBloc._handleShowInter",
      screenClass: "SplashBloc",
    );
    return completer.future;
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
    // emit(state.copyWith(isCompleted: true));
  }
}
