import 'dart:ui';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/challenge.dart';
import '../../../data/model/game_settings.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamePage extends StatefulWidget {
  final Challenge challenge;
  final VoidCallback onBack;
  final VoidCallback onGameOver;

  const GamePage({
    super.key,
    required this.challenge,
    required this.onBack,
    required this.onGameOver,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with TickerProviderStateMixin {
  GameSettings? _settings;
  late AnimationController _countdownAnimationController;
  late AnimationController _feedbackAnimationController;

  static const List<Map<String, dynamic>> _decorations = [
    {'icon': '⭐', 'top': 0.15, 'left': 0.05},
    {'icon': '🎵', 'top': 0.10, 'right': 0.08},
    {'icon': '✨', 'bottom': 0.20, 'left': 0.08},
    {'icon': '💖', 'bottom': 0.15, 'right': 0.05},
    {'icon': '🌟', 'top': 0.50, 'left': -0.02},
    {'icon': '🚀', 'bottom': 0.24, 'right': -0.01},
  ];

  @override
  void initState() {
    super.initState();
    _countdownAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _feedbackAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('game_settings');
    if (!mounted) return;
    setState(() {
      _settings = json != null
          ? GameSettings.fromJson(
              Map<String, dynamic>.from(
                jsonDecode(json),
              ),
            )
          : GameSettings();
    });
  }

  @override
  void dispose() {
    _countdownAnimationController.dispose();
    _feedbackAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc()..add(GameInitialized(widget.challenge)),
      child: BlocListener<GameBloc, GameState>(
        listenWhen: (previous, current) {
          return previous.flashFeedback != current.flashFeedback ||
              previous.currentRoundIndex != current.currentRoundIndex ||
              previous.countdownValue != current.countdownValue;
        },
        listener: (context, state) {
          if (state.flashFeedback != null && state.tick >= 12 && state.tick < 15) {
            _feedbackAnimationController.reset();
            _feedbackAnimationController.forward();
          } else {
            _feedbackAnimationController.stop();
            _feedbackAnimationController.reset();
          }
          if (state.countdownValue > 0 && state.isCountingDown) {
            _countdownAnimationController.reset();
            _countdownAnimationController.forward();
          }
          if (!state.isCountingDown && state.challenge != null && !state.isLoading) {
            final nextRound = state.currentRoundIndex + 1;
            if (nextRound >= state.challenge!.rounds.length) {
              widget.onGameOver();
            }
          }
        },
      child: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          if (state.isCountingDown) {
            return _buildCountdown(state);
          }
          return _buildMainGame(state);
        },
      ),
      ),
    );
  }

  Widget _buildCountdown(GameState state) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    colors: [
                      Colors.yellow.shade600,
                      Colors.black,
                      Colors.black,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _countdownAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: Tween<double>(
                        begin: 3.0,
                        end: 1.0,
                      ).animate(CurvedAnimation(
                        parent: _countdownAnimationController,
                        curve: Curves.easeOutCubic,
                      )).value,
                      child: Opacity(
                        opacity: _countdownAnimationController.value,
                        child: Text(
                          '${state.countdownValue}',
                          key: ValueKey(state.countdownValue),
                          style: TextStyle(
                            fontSize: 150,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Anton',
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            shadows: [
                              Shadow(
                                color: Colors.yellow.withOpacity(0.5),
                                blurRadius: 50,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: const Text(
                          'GET READY',
                          style: TextStyle(
                            color: Color(0x80FFFFFF),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 16,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainGame(GameState state) {
    final currentRound = state.currentRound;
    if (currentRound == null) return const SizedBox();

    final bgColor = state.beatInBar == 0
        ? const Color(0xFF222222)
        : const Color(0xFF111111);

    return Scaffold(
      backgroundColor: bgColor,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 75),
        color: bgColor,
        child: Stack(
          children: [
            _buildDecorations(),
            SafeArea(
              child: Column(
                children: [
                  _buildTopBar(state),
                  Expanded(
                    child: _buildGameGrid(state, currentRound),
                  ),
                  Builder(
                    builder: (context) => _buildStopButton(context),
                  ),
                ],
              ),
            ),
            if (state.flashFeedback != null && 
                state.flashFeedback!.isNotEmpty && 
                state.tick >= 12 && 
                state.tick < 15)
              _buildFeedbackOverlay(state),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorations() {
    final screenSize = MediaQuery.of(context).size;
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: _decorations.map((deco) {
            return Positioned(
              top: deco['top'] != null
                  ? screenSize.height * (deco['top'] as double)
                  : null,
              bottom: deco['bottom'] != null
                  ? screenSize.height * (deco['bottom'] as double)
                  : null,
              left: deco['left'] != null
                  ? screenSize.width * (deco['left'] as double)
                  : null,
              right: deco['right'] != null
                  ? screenSize.width * (deco['right'] as double)
                  : null,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 2),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: 0.5 + (value * 0.5),
                    child: Text(
                      deco['icon'] as String,
                      style: const TextStyle(fontSize: 32),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTopBar(GameState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Topic',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade400,
                    letterSpacing: 2,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  state.challenge?.topic ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Anton',
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '${state.currentRoundIndex + 1}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Anton',
                  color: Colors.white,
                ),
              ),
              Text(
                '/${state.challenge?.rounds.length ?? 0}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Anton',
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          Row(
            children: List.generate(4, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 75),
                width: 12,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: state.beatInBar == i
                      ? Colors.yellow.shade400
                      : Colors.grey.shade700,
                  shape: BoxShape.circle,
                  boxShadow: state.beatInBar == i
                      ? [
                          BoxShadow(
                            color: Colors.yellow.shade400.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                transform: Matrix4.identity()
                  ..scale(state.beatInBar == i ? 1.25 : 1.0),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildGameGrid(GameState state, currentRound) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: 8,
          itemBuilder: (context, index) {
            final isRevealed = index < state.visibleCardsCount;
            if (!isRevealed) {
              return const SizedBox();
            }

            final item = currentRound.items[index];
            final isActive = index == state.activeCardIndex;

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 100 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 75),
                      decoration: BoxDecoration(
                        color: (item.image != null && item.image!.isNotEmpty)
                            ? Colors.transparent
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isActive
                              ? Colors.yellow.shade400
                              : Colors.black,
                          width: isActive ? 4 : 2,
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: Colors.yellow.shade400.withOpacity(0.8),
                                  blurRadius: 30,
                                  spreadRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                      transform: Matrix4.identity()
                        ..scale(isActive ? 1.05 : 1.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: item.image != null && item.image!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: item.image!.startsWith('data:image')
                                        ? Image.memory(
                                            _base64ToBytes(item.image!),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.white,
                                                child: Center(
                                                  child: AnimatedScale(
                                                    scale: isActive ? 1.1 : 1.0,
                                                    duration: const Duration(milliseconds: 75),
                                                    child: Text(
                                                      item.emoji,
                                                      style: const TextStyle(fontSize: 40),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : Image.network(
                                            item.image!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.white,
                                                child: Center(
                                                  child: AnimatedScale(
                                                    scale: isActive ? 1.1 : 1.0,
                                                    duration: const Duration(milliseconds: 75),
                                                    child: Text(
                                                      item.emoji,
                                                      style: const TextStyle(fontSize: 40),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                  )
                                : Center(
                                    child: AnimatedScale(
                                      scale: isActive ? 1.1 : 1.0,
                                      duration: const Duration(milliseconds: 75),
                                      child: Text(
                                        item.emoji,
                                        style: const TextStyle(fontSize: 40),
                                      ),
                                    ),
                                  ),
                          ),
                          if ((_settings?.showWordText ?? true))
                            Container(
                              height: 40,
                              width: double.infinity,
                              color: Colors.black,
                              child: Center(
                                child: Text(
                                  item.word.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'Anton',
                                    color: isActive
                                        ? Colors.yellow.shade400
                                        : Colors.grey.shade500,
                                    letterSpacing: 1,
                                  ),
                                ),
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
    );
  }

  Widget _buildFeedbackOverlay(GameState state) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.5,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      colors: [
                        Colors.yellow.shade600,
                        Colors.black,
                        Colors.black,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _feedbackAnimationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: Tween<double>(
                      begin: 0.5,
                      end: 1.0,
                    ).animate(CurvedAnimation(
                      parent: _feedbackAnimationController,
                      curve: Curves.easeOut,
                    )).value,
                    child: Transform.rotate(
                      angle: -0.087,
                      child: Text(
                        state.flashFeedback ?? '',
                        key: ValueKey(state.flashFeedback),
                        style: TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Anton',
                          color: Colors.green.shade400,
                          shadows: [
                            const Shadow(
                              color: Colors.black,
                              blurRadius: 10,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          context.read<GameBloc>().add(const GameStopped());
          widget.onBack();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.grey.shade800,
              width: 1,
            ),
          ),
          child: const Text(
            'STOP',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }

  Uint8List _base64ToBytes(String base64String) {
    final base64Data = base64String.split(',').last;
    return base64Decode(base64Data);
  }
}

