import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_ads_native/ad_data.dart';
import 'package:flutter_ads_native/index.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:say_word_challenge/ui/common/widgets/keep_alive_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../routes/app_routes.dart';
import '../bloc/guide_bloc.dart';
import '../bloc/guide_event.dart';
import '../bloc/guide_state.dart';

class GuidePage extends StatefulWidget {
  final VoidCallback? onCompleted;

  const GuidePage({super.key, this.onCompleted});

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> with TickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  bool _isPrimaryPressed = false;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  Future<void> _completeGuide(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_guide', true);
    if (!context.mounted) return;
    if (widget.onCompleted != null) {
      widget.onCompleted!();
      return;
    }
    context.go(AppRoutes.styleSelection);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GuideBloc()..add(const GuideInitialized()),
      child: BlocListener<GuideBloc, GuideState>(
        listenWhen: (p, c) => p.isCompleted != c.isCompleted,
        listener: (context, state) {
          if (state.isCompleted) {
            _completeGuide(context);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: BlocBuilder<GuideBloc, GuideState>(
            buildWhen: (p, c) => p.currentStep != c.currentStep,
            builder: (context, state) {
              final children = [
                BlocBuilder<GuideBloc, GuideState>(
                  key: ValueKey(2),
                  buildWhen: (p, c) => p.currentStep != c.currentStep,
                  builder: (context, state) {
                    final isLast = state.currentStep == 5;
                    return Container(
                      color: Colors.black,
                      child: Column(
                        children: [
                          Expanded(
                            child: IndexedStack(
                              index: state.currentStep,
                              children: [
                                _buildCard(
                                  context,
                                  _GuideStep(
                                    title: 'Say On Beat',
                                    description:
                                        'Say the word out loud right when the card flashes on the beat.',
                                    gradient: [
                                      Color(0xFFFACC15),
                                      Color(0xFFF97316),
                                    ],
                                    gifAsset: 'assets/gif/say_on_beat.gif',
                                  ),
                                ),
                                Placeholder(),
                                _buildCard(
                                  context,
                                  _GuideStep(
                                    title: 'Watch The Flash',
                                    description:
                                        'Each round has 8 beats. Focus on the card with the glowing gold border.',
                                    gradient: [
                                      Color(0xFFEC4899),
                                      Color(0xFF7C3AED),
                                    ],
                                    gifAsset: 'assets/gif/flash.gif',
                                  ),
                                ),
                                _buildCard(
                                  context,
                                  _GuideStep(
                                    title: 'Increase Speed',
                                    description:
                                        'Challenge yourself with BPM from 120 (Easy) to 150 (Hard).',
                                    gradient: [
                                      Color(0xFF3B82F6),
                                      Color(0xFF06B6D4),
                                    ],
                                    gifAsset: 'assets/gif/speed.gif',
                                  ),
                                ),
                                Placeholder(),
                                _buildCard(
                                  context,
                                  _GuideStep(
                                    title: 'Create Yours',
                                    description:
                                        'Upload your own photos to create one-of-a-kind challenges!',
                                    gradient: [
                                      Color(0xFF4ADE80),
                                      Color(0xFF059669),
                                    ],
                                    gifAsset: 'assets/gif/create_your.gif',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (state.currentStep != 1 && state.currentStep != 4)
                            Row(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(6, (i) {
                                    final isActive = i == state.currentStep;
                                    return AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                      width: isActive ? 32 : 8,
                                      height: 6,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(99),
                                        color: isActive
                                            ? Colors.white
                                            : const Color(0xFF1F2937),
                                      ),
                                    );
                                  }),
                                ),
                                Spacer(),
                                if (!isLast)
                                  GestureDetector(
                                    onTap: () {
                                      context.read<GuideBloc>().add(
                                        const GuideNextPressed(),
                                      );
                                    },

                                    child: Padding(
                                      padding: EdgeInsetsGeometry.symmetric(
                                        horizontal: 12.w,
                                        vertical: 10.h,
                                      ),
                                      child: Text(
                                        "Next",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 3,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          if (isLast)
                            SizedBox(
                              width: double.infinity,
                              child: GestureDetector(
                                onTapDown: (_) {
                                  setState(() {
                                    _isPrimaryPressed = true;
                                  });
                                },
                                onTapUp: (_) {
                                  setState(() {
                                    _isPrimaryPressed = false;
                                  });
                                },
                                onTapCancel: () {
                                  setState(() {
                                    _isPrimaryPressed = false;
                                  });
                                },
                                onTap: () {
                                  context.read<GuideBloc>().add(
                                    const GuideNextPressed(),
                                  );
                                },
                                child: AnimatedScale(
                                  scale: _isPrimaryPressed ? 0.95 : 1.0,
                                  duration: const Duration(milliseconds: 120),
                                  curve: Curves.easeOut,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(999),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x4DFFFFFF),
                                          blurRadius: 20,
                                          offset: Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      "Let's Play!",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 3,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Padding(
                            padding: EdgeInsetsGeometry.symmetric(vertical: 10),
                            child: SizedBox(
                              height:
                                  state.currentStep != 1 &&
                                      state.currentStep != 4
                                  ? AdNativeSize
                                        .NATIVE_MEDIUM_RECTANGLE
                                        .adHeight
                                  : 0,
                              child: NativeAdWidget(
                                data: AdNativeData(
                                  adUnitId:
                                      "ca-app-pub-3940256099942544/1044960115",
                                  size: AdNativeSize.NATIVE_MEDIUM_RECTANGLE,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).padding.bottom + 32,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                BlocBuilder<GuideBloc, GuideState>(
                  key: ValueKey(1),
                  buildWhen: (p, c) => p.currentStep != c.currentStep,
                  builder: (context, state) => SizedBox(
                    height: double.infinity,
                    child: Stack(
                      children: [
                        Container(color: Colors.black),
                        NativeAdWidget(
                          data: AdNativeData(
                            adUnitId: "ca-app-pub-3940256099942544/1044960115",
                            size: AdNativeSize.FULL_SCREEN_GUIDE,
                          ),
                        ),
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 16.h,
                          right: 16.w,
                          child: _buttonNext(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
              return Stack(
                children: state.currentStep == 1 || state.currentStep == 4
                    ? children
                    : children.reversed.toList(),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, _GuideStep step) {
    return KeepAlivePage(
      child: SizedBox(
        key: ValueKey<String>('guide_step_${step.title}'),
        width: double.infinity,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Spacer(),
                AnimatedBuilder(
                  animation: _bounceCtrl,
                  builder: (context, child) {
                    final dy = lerpDouble(-8, 10, _bounceCtrl.value) ?? 0.0;
                    return Transform.translate(
                      offset: Offset(0, dy),
                      child: Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: step.gradient,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xAA000000),
                              blurRadius: 30,
                              offset: Offset(0, 18),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Image.asset(
                              step.gifAsset,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox.expand(),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
                Text(
                  step.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Anton',
                    fontSize: 36,
                    color: Colors.white,
                    height: 1.0,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  step.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    height: 1.5,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buttonNext(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<GuideBloc>().add(const GuideNextPressed());
      },
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          "Next",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class _GuideStep {
  final String title;
  final String description;
  final List<Color> gradient;
  final String gifAsset;

  const _GuideStep({
    required this.title,
    required this.description,
    required this.gradient,
    required this.gifAsset,
  });
}
