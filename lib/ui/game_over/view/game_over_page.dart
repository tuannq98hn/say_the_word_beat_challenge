import 'package:flutter/material.dart';
import 'package:flutter_ads_native/index.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:say_word_challenge/services/interstitial_ads_controller.dart';
import 'package:say_word_challenge/services/remote_config_service.dart';
import 'package:share_plus/share_plus.dart';

import '../bloc/game_over_bloc.dart';
import '../bloc/game_over_event.dart';

class GameOverPage extends StatefulWidget {
  final VoidCallback onPlayAgain;

  const GameOverPage({super.key, required this.onPlayAgain});

  @override
  State<GameOverPage> createState() => _GameOverPageState();
}

class _GameOverPageState extends State<GameOverPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameOverBloc()..add(const GameOverInitialized()),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: Lottie.asset(
                'assets/lotties/game_completed.json',
                fit: BoxFit.cover,
                repeat: true,
              ),
            ),
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 100 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _NeonGradientText(
                            'Challenge\nComplete!',
                            fontSize: 64,
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'You conquered the beat! What\'s next?',
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFFD1D5DB),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              fontFamily: 'Inter',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            alignment: WrapAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _handleShowInter(
                                    onDone: () {
                                      widget.onPlayAgain.call();
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFACC15),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Play Again',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  try {
                                    await Share.share(
                                      'I just crushed the Word On Beat challenge!',
                                      subject: 'Word On Beat',
                                    );
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Share URL copied!'),
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    side: const BorderSide(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Share Score',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (RemoteConfigService.instance.configAdsDataByScreen(
                  "GameOverPage",
                ) !=
                null)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom,
                left: 0,
                right: 0,
                child: RemoteConfigService.instance.configAdsByScreen(
                  "GameOverPage",
                )!,
              ),
          ],
        ),
      ),
    );
  }

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
    if (!await InterstitialAdsController.instance.showInterstitialAd()) {
      InterstitialAds.onInterstitialClosed = origin_onInterstitialClosed;
      InterstitialAds.onInterstitialFailed = origin_onInterstitialFailed;
      InterstitialAds.onInterstitialShown = origin_onInterstitialShown;
      onDone();
    }
  }
}

class _NeonGradientText extends StatelessWidget {
  final String text;
  final double fontSize;

  const _NeonGradientText(this.text, {required this.fontSize});

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFFFF3DAF), Color(0xFFFF3D6E), Color(0xFFFF2D55)],
    );

    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Anton',
          fontSize: fontSize,
          height: 0.95,
          fontWeight: FontWeight.w400,
          letterSpacing: -1.2,
          color: Colors.white,
          shadows: [
            Shadow(
              color: const Color(0xFFFF2D8D).withOpacity(0.85),
              blurRadius: 26,
            ),
            Shadow(
              color: const Color(0xFFFF2D8D).withOpacity(0.55),
              blurRadius: 56,
            ),
            Shadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}
