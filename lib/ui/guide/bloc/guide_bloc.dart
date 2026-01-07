import 'dart:async';

import 'package:flutter/src/widgets/page_view.dart';
import 'package:flutter_ads_native/index.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:say_word_challenge/services/interstitial_ads_controller.dart';
import 'package:say_word_challenge/services/remote_config_service.dart';

import 'guide_event.dart';
import 'guide_state.dart';

class GuideBloc extends Bloc<GuideEvent, GuideState> {
  int get totalSteps =>
      RemoteConfigService.instance.configAdsDataByScreen("GuidePageFull") !=
          null
      ? 6
      : 4;

  PageController pageController = PageController();
  Timer? _countdownTimer;

  GuideBloc() : super(const GuideState()) {
    on<GuideInitialized>(_onInitialized);
    on<GuideNextPressed>(_onNextPressed);
    on<GuideCountdownTick>(_onGuideCountdownTick);
    on<GuideSkipPressed>(_onSkipPressed);
  }

  Future<void> _onInitialized(
    GuideInitialized event,
    Emitter<GuideState> emit,
  ) async {
    emit(
      const GuideState(
        currentStep: 0,
        isCompleted: false,
        isCountDowning: true,
        countdownValue: 5,
      ),
    );
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      add(const GuideCountdownTick());
    });
  }

  Future<void> _onNextPressed(
    GuideNextPressed event,
    Emitter<GuideState> emit,
  ) async {
    if (state.currentStep >= totalSteps - 1) {
      await _handleShowInter();
      emit(state.copyWith(isCompleted: true));
      return;
    }
    final currentPage = state.currentStep + 1;
    emit(state.copyWith(currentStep: currentPage));
  }

  void _onSkipPressed(GuideSkipPressed event, Emitter<GuideState> emit) {
    emit(state.copyWith(isCompleted: true));
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
        isShown = await InterstitialAdsController.instance.showInterstitialAd();
        if (!isShown) {
          finish();
        }
      }
    };

    isShown = await InterstitialAdsController.instance.showInterstitialAd();
    return completer.future;
  }

  FutureOr<void> _onGuideCountdownTick(event, Emitter<GuideState> emit) {
    if (state.countdownValue > 1) {
      emit(state.copyWith(countdownValue: state.countdownValue - 1));
    } else {
      _countdownTimer?.cancel();
      _countdownTimer = null;
      emit(state.copyWith(isCountDowning: false, countdownValue: 0));
    }
  }
}
