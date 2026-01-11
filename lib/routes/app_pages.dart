import 'package:flutter/material.dart';
import 'package:flutter_ads_native/interstitial_ads/interstitial_ads.dart';
import 'package:go_router/go_router.dart';
import 'package:say_word_challenge/services/interstitial_ads_controller.dart';
import 'package:say_word_challenge/tracking/app_analytics.dart';

import '../data/model/challenge.dart';
import '../data/model/tiktok_video.dart';
import '../tracking/widgets/tracked_screen.dart';
import '../ui/game/view/game_page.dart';
import '../ui/game_over/view/game_over_page.dart';
import '../ui/guide/view/guide_page.dart';
import '../ui/main/main_tab_page.dart';
import '../ui/pre_game_settings/view/pre_game_settings_page.dart';
import '../ui/splash/view/splash_page.dart';
import '../ui/style_selection/view/style_selection_page.dart';
import '../ui/video/video_player_page.dart';
import 'app_routes.dart';

class AppPages {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) =>
            TrackedScreen(screenClass: 'SplashPage', child: SplashPage()),
      ),
      GoRoute(
        path: AppRoutes.main,
        builder: (context, state) => TrackedScreen(
          screenClass: 'MainTabPage',
          child: MainTabPage(
            onChallengeSelected: (challenge) async {
              AppAnalytics.logButtonClick(
                screenClass: 'MainTabPage',
                buttonName: 'select_challenge',
                action: 'open_pre_game_settings',
              );
              _handleShowInter(
                onDone: () {
                  if (context.mounted == true) {
                    context.push(AppRoutes.preGameSettings, extra: challenge);
                  }
                },
              );
            },
            onVideoSelected: (video) {
              AppAnalytics.logButtonClick(
                screenClass: 'MainTabPage',
                buttonName: 'select_video',
                action: 'open_video_player',
              );
              _handleShowInter(
                onDone: () {
                  if (context.mounted == true) {
                    context.push(AppRoutes.videoPlayer, extra: video);
                  }
                },
              );
            },
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.guide,
        builder: (context, state) => const GuidePage(),
      ),
      GoRoute(
        path: AppRoutes.styleSelection,
        builder: (context, state) => const StyleSelectionPage(),
      ),
      GoRoute(
        path: AppRoutes.preGameSettings,
        builder: (context, state) {
          final challenge = state.extra as Challenge?;
          if (challenge == null) {
            return const SizedBox();
          }
          return TrackedScreen(
            screenClass: 'PreGameSettingsPage',
            child: PreGameSettingsPage(challenge: challenge),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.game,
        builder: (context, state) {
          Challenge? challenge;
          try {
            challenge = state.extra as Challenge?;
          } catch (e) {
            challenge = null;
          }
          if (challenge == null) {
            return const SizedBox();
          }
          return TrackedScreen(
            screenClass: 'GamePage',
            child: GamePage(
              challenge: challenge,
              onBack: () {
                context.go(AppRoutes.main);
              },
              onGameOver: () {
                context.go(AppRoutes.gameOver);
              },
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.gameOver,
        builder: (context, state) => TrackedScreen(
          screenClass: 'GameOverPage',
          child: GameOverPage(
            onPlayAgain: () {
              AppAnalytics.logButtonClick(
                screenClass: 'GameOverPage',
                buttonName: 'play_again',
                action: 'go_main',
              );
              context.go(AppRoutes.main);
            },
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.videoPlayer,
        builder: (context, state) {
          final video = state.extra as TikTokVideo?;
          if (video == null) {
            return const SizedBox();
          }
          return TrackedScreen(
            screenClass: 'VideoPlayerPage',
            child: VideoPlayerPage(
              video: video,
              onBack: () {
                context.pop();
              },
            ),
          );
        },
      ),
    ],
  );

  static Future<void> _handleShowInter({
    required void Function() onDone,
  }) async {
    final origin_onInterstitialClosed = InterstitialAds.onInterstitialClosed;
    final origin_onInterstitialFailed = InterstitialAds.onInterstitialFailed;
    final origin_onInterstitialShown = InterstitialAds.onInterstitialShown;
    InterstitialAds.onInterstitialClosed = () {
      InterstitialAds.onInterstitialClosed = origin_onInterstitialClosed;
      onDone();
    };
    InterstitialAds.onInterstitialFailed = (_) {
      InterstitialAds.onInterstitialFailed = origin_onInterstitialFailed;
      onDone();
    };
    InterstitialAds.onInterstitialShown = () {
      InterstitialAds.onInterstitialShown = origin_onInterstitialShown;
      // todo show native full screen ==> check policy
    };
    if (!await InterstitialAdsController.instance.showInterstitialAd(
      screenClass: 'MainTabPage',
      callerFunction: 'AppPages._handleShowInter',
    )) {
      InterstitialAds.onInterstitialClosed = origin_onInterstitialClosed;
      InterstitialAds.onInterstitialFailed = origin_onInterstitialFailed;
      InterstitialAds.onInterstitialShown = origin_onInterstitialShown;
      onDone();
    }
  }
}
