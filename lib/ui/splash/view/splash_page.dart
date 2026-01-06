import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_ads_native/ad_data.dart';
import 'package:flutter_ads_native/index.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:say_word_challenge/data/model/ads_model.dart';
import 'package:say_word_challenge/routes/app_routes.dart';
import 'package:say_word_challenge/services/remote_config_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/splash_bloc.dart';
import '../bloc/splash_event.dart';
import '../bloc/splash_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _bounceCtrl;
  late final AnimationController _introCtrl;

  late final Animation<double> _pulseScale;
  late final Animation<double> _loadingOpacity;

  late final Animation<double> _bounce;
  late final Animation<double> _introOpacity;
  late final Animation<Offset> _introOffset;

  @override
  void initState() {
    super.initState();

    // Pulse for center blob + loading text
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(
      begin: 0.92,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _loadingOpacity = Tween<double>(
      begin: 0.45,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Bounce for top-left blob (small delay)
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _bounce = Tween<double>(
      begin: -10,
      end: 18,
    ).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));

    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 120), () {
        if (mounted) _bounceCtrl.repeat(reverse: true);
      }),
    );

    // Intro slide-in-up for content
    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _introOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _introCtrl, curve: Curves.easeOutCubic));

    _introOffset = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _introCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _bounceCtrl.dispose();
    _introCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return BlocProvider(
      create: (context) => SplashBloc()..add(const SplashInitialized()),
      child: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state.isCompleted) {
            _navigateAfterSplash(context);
          }
        },
        child: Scaffold(
          body: SizedBox.expand(
            child: Container(
              color: Colors.black,
              child: ClipRect(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Abstract blurred blobs
                    Opacity(
                      opacity: 0.30,
                      child: Stack(
                        children: [
                          // Center-ish amber pulse blob
                          Center(
                            child: AnimatedBuilder(
                              animation: _pulseCtrl,
                              builder: (_, __) {
                                return Transform.scale(
                                  scale: _pulseScale.value,
                                  child: const _BlurCircle(
                                    diameter: 260,
                                    color: Color(0xFFFFC107),
                                    sigma: 100,
                                  ),
                                );
                              },
                            ),
                          ),

                          // Top-left red bounce blob
                          AnimatedBuilder(
                            animation: _bounceCtrl,
                            builder: (_, __) {
                              final top = size.height * 0.22 + _bounce.value;
                              final left = size.width * 0.22;
                              return Positioned(
                                top: top,
                                left: left,
                                child: const _BlurCircle(
                                  diameter: 260,
                                  color: Color(0xFFFF1744),
                                  sigma: 100,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Foreground content
                    Center(
                      child: FadeTransition(
                        opacity: _introOpacity,
                        child: SlideTransition(
                          position: _introOffset,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.music_note_rounded,
                                size: 74,
                                color: Colors.white.withOpacity(0.85),
                                shadows: [
                                  Shadow(
                                    color: const Color(
                                      0xFF00E5FF,
                                    ).withOpacity(0.25),
                                    blurRadius: 18,
                                  ),
                                  Shadow(
                                    color: Colors.white.withOpacity(0.18),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              _NeonGradientText(
                                'SAY THE WORD',
                                fontSize: _responsiveTitleSize(size.width),
                              ),

                              const SizedBox(height: 18),

                              AnimatedBuilder(
                                animation: _pulseCtrl,
                                builder: (_, __) {
                                  return Opacity(
                                    opacity: _loadingOpacity.value,
                                    child: const Text(
                                      'LOADING ASSETS....',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 6.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    BlocBuilder<SplashBloc, SplashState>(
                      builder: (ctx, state) {
                        final blank = SizedBox.shrink();
                        if (state.isLoading || state.isCloseNative)
                          return blank;
                        final adData = RemoteConfigService.instance
                            .configAdsDataByScreen("SplashPageFull");
                        if (state.isOpenAppSuccess &&
                            adData != null &&
                            adData is NativeModel) {
                          return Align(
                            child: NativeAdWidget(
                              data: AdNativeData(
                                adUnitId: adData.adUnitId!,
                                size: adData.size!,
                              ),
                              onCloseAd: () {
                                ctx.read<SplashBloc>().add(
                                  const OnCloseNative(),
                                );
                              },
                            ),
                          );
                        }
                        return blank;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _responsiveTitleSize(double w) {
    // Similar to text-6xl md:text-8xl
    if (w >= 900) return 88;
    if (w >= 600) return 78;
    return 64;
  }

  Future<void> _navigateAfterSplash(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenGuide = prefs.getBool('has_seen_guide') ?? false;
    if (!context.mounted) return;
    if (hasSeenGuide) {
      context.go(AppRoutes.main);
    } else {
      context.go(AppRoutes.guide);
    }
  }
}

class _BlurCircle extends StatelessWidget {
  final double diameter;
  final Color color;
  final double sigma;

  const _BlurCircle({
    required this.diameter,
    required this.color,
    required this.sigma,
  });

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.80),
        ),
      ),
    );
  }
}

class _NeonGradientText extends StatelessWidget {
  final String text;
  final double fontSize;

  const _NeonGradientText(this.text, {required this.fontSize});

  @override
  Widget build(BuildContext context) {
    // Pink neon similar to screenshot
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
          // tinh chỉnh -1.0..-2.0 nếu cần “tighter”
          color: Colors.white,
          // sẽ bị ShaderMask phủ
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
