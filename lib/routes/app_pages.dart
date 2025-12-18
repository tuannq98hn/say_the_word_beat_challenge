import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../ui/splash/view/splash_page.dart';
import '../ui/main/main_tab_page.dart';
import '../ui/game/view/game_page.dart';
import '../ui/game_over/view/game_over_page.dart';
import '../ui/video/video_player_page.dart';
import '../data/model/challenge.dart';
import '../data/model/tiktok_video.dart';

class AppPages {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.main,
        builder: (context, state) => MainTabPage(
          onChallengeSelected: (challenge) {
            return context.push(
              AppRoutes.game,
              extra: challenge,
            );
          },
          onVideoSelected: (video) {
            context.push(
              AppRoutes.videoPlayer,
              extra: video,
            );
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.game,
        builder: (context, state) {
          final challenge = state.extra as Challenge?;
          if (challenge == null) {
            return const SizedBox();
          }
          return GamePage(
            challenge: challenge,
            onBack: () {
              context.pop();
            },
            onGameOver: () {
              context.go(AppRoutes.gameOver);
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.gameOver,
        builder: (context, state) => GameOverPage(
          onPlayAgain: () {
            context.go(AppRoutes.main);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.videoPlayer,
        builder: (context, state) {
          final video = state.extra as TikTokVideo?;
          if (video == null) {
            return const SizedBox();
          }
          return VideoPlayerPage(
            video: video,
            onBack: () {
              context.pop();
            },
          );
        },
      ),
    ],
  );
}
