import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../common/enums/difficulty.dart';
import '../../../common/enums/music_style.dart';
import '../../../routes/app_routes.dart';
import '../bloc/style_selection_bloc.dart';
import '../bloc/style_selection_event.dart';
import '../bloc/style_selection_state.dart';

class StyleSelectionPage extends StatefulWidget {
  final VoidCallback? onSelected;

  const StyleSelectionPage({super.key, this.onSelected});

  @override
  State<StyleSelectionPage> createState() => _StyleSelectionPageState();
}

class _StyleSelectionPageState extends State<StyleSelectionPage> {
  MusicStyle? _pressedStyle;

  static const _styles = <_StyleOption>[
    _StyleOption(
      style: MusicStyle.funk,
      difficulty: Difficulty.medium,
      name: 'Classic Funk',
      description: 'Standard 138 BPM. Fun and easy to follow.',
      icon: '🎸',
      borderColor: Color(0x80FACC15),
      backgroundColor: Color(0x1AFACC15),
    ),
    _StyleOption(
      style: MusicStyle.synth,
      difficulty: Difficulty.hard,
      name: 'Neon Hype',
      description: 'Fast 150 BPM. For pros who can say words at lightning speed.',
      icon: '🌃',
      borderColor: Color(0x80EC4899),
      backgroundColor: Color(0x1AEC4899),
    ),
    _StyleOption(
      style: MusicStyle.chill,
      difficulty: Difficulty.easy,
      name: 'Lo-fi Chill',
      description: 'Relaxed 120 BPM. Perfect for practicing your timing.',
      icon: '☁️',
      borderColor: Color(0x803B82F6),
      backgroundColor: Color(0x1A3B82F6),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StyleSelectionBloc()..add(const StyleSelectionInitialized()),
      child: BlocListener<StyleSelectionBloc, StyleSelectionState>(
        listenWhen: (p, c) => p.isCompleted != c.isCompleted,
        listener: (context, state) {
          if (!state.isCompleted) return;
          if (widget.onSelected != null) {
            widget.onSelected!();
            return;
          }
          context.go(AppRoutes.main);
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Positioned.fill(
                child: Container(color: Colors.black.withAlpha(242)),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: const SizedBox.expand(),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: BlocBuilder<StyleSelectionBloc, StyleSelectionState>(
                    builder: (context, state) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: constraints.maxHeight),
                              child: Align(
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Choose Your Style',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Anton',
                                        fontSize: 30,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Personalize your challenge experience',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.grey.shade500,
                                        letterSpacing: 3,
                                      ),
                                    ),
                                    const SizedBox(height: 28),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 390),
                                      child: Column(
                                        children: [
                                          for (final option in _styles) ...[
                                            _buildStyleButton(context, state, option),
                                            const SizedBox(height: 16),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      'You can change this anytime in Settings',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.grey.shade600,
                                        letterSpacing: 2.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (state.isLoading)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 18),
                                        child: SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyleButton(
    BuildContext context,
    StyleSelectionState state,
    _StyleOption option,
  ) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _pressedStyle = option.style;
        });
      },
      onTapUp: (_) {
        setState(() {
          _pressedStyle = null;
        });
      },
      onTapCancel: () {
        setState(() {
          _pressedStyle = null;
        });
      },
      onTap: state.isLoading
          ? null
          : () {
              context.read<StyleSelectionBloc>().add(
                    StyleSelected(style: option.style, difficulty: option.difficulty),
                  );
            },
      child: AnimatedScale(
        scale: _pressedStyle == option.style ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: option.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: option.borderColor, width: 2),
          ),
          child: Row(
            children: [
              Text(
                option.icon,
                style: const TextStyle(fontSize: 34),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.name,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      option.description,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        height: 1.25,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${option.difficulty.name} • ${option.style.name}',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: Colors.white.withAlpha(140),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StyleOption {
  final MusicStyle style;
  final Difficulty difficulty;
  final String name;
  final String description;
  final String icon;
  final Color borderColor;
  final Color backgroundColor;

  const _StyleOption({
    required this.style,
    required this.difficulty,
    required this.name,
    required this.description,
    required this.icon,
    required this.borderColor,
    required this.backgroundColor,
  });
}

