import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ads_native/index.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:say_word_challenge/services/interstitial_ads_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/model/challenge.dart';
import '../../../data/model/game_settings.dart';
import '../../../services/audio_service.dart';
import '../../../services/camera_service.dart';
import '../../../services/recording_service.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../config/game_timing_config.dart';

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
    with TickerProviderStateMixin, WidgetsBindingObserver {
  GameSettings? _settings;
  GameBloc? _gameBloc;
  late AnimationController _countdownAnimationController;
  late AnimationController _feedbackAnimationController;
  final Map<String, Uint8List> _imageCache = {};
  final RecordingService _recordingService = RecordingService();
  final CameraService _cameraService = CameraService();
  bool _cameraInitialized = false;

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
    WidgetsBinding.instance.addObserver(this);
    _countdownAnimationController = AnimationController(
      vsync: this,
      duration: GameTimingConfig.countdownAnimationDuration,
    );
    _feedbackAnimationController = AnimationController(
      vsync: this,
      duration: GameTimingConfig.feedbackWordAnimationDuration,
    );
    _loadSettings();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final settings = await _getSettings();
    if (settings?.enableCamera == true) {
      final initialized = await _cameraService.initialize();
      if (mounted) {
        setState(() {
          _cameraInitialized = initialized;
        });
      }
    }
  }

  Future<GameSettings?> _getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('game_settings');
    if (json != null) {
      return GameSettings.fromJson(Map<String, dynamic>.from(jsonDecode(json)));
    }
    return GameSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('game_settings');
    if (!mounted) return;
    final newSettings = json != null
        ? GameSettings.fromJson(Map<String, dynamic>.from(jsonDecode(json)))
        : GameSettings();
    if (_settings?.showWordText != newSettings.showWordText) {
      setState(() {
        _settings = newSettings;
      });
    } else {
      _settings = newSettings;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      audioService.stop();
      _gameBloc?.add(const GameStopped());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    audioService.stop();
    _gameBloc?.add(const GameStopped());
    _stopRecording();
    _cameraService.dispose();
    _countdownAnimationController.dispose();
    _feedbackAnimationController.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
    _stopRecording();
  }

  Future<void> _stopRecording() async {
    final prefs = await SharedPreferences.getInstance();
    final isRecordingActive = prefs.getBool('recording_is_active') ?? false;

    if (isRecordingActive && _recordingService.isRecording) {
      await _recordingService.stopRecording();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('recording_is_active', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = GameBloc()..add(GameInitialized(widget.challenge));
        _gameBloc = bloc;
        return bloc;
      },
      child: BlocListener<GameBloc, GameState>(
        listenWhen: (previous, current) {
          final shouldListen =
              previous.flashFeedback != current.flashFeedback ||
              previous.currentRoundIndex != current.currentRoundIndex ||
              previous.countdownValue != current.countdownValue ||
              previous.isCountingDown != current.isCountingDown ||
              previous.isLoading != current.isLoading ||
              previous.tick != current.tick ||
              previous.isGameComplete != current.isGameComplete;
          return shouldListen;
        },
        listener: (context, state) {
          if (state.countdownValue > 0 && state.isCountingDown) {
            _countdownAnimationController.reset();
            _countdownAnimationController.forward();
          }
          if (state.isGameComplete) {
            _stopRecording();
            Future.delayed(GameTimingConfig.gameCompleteDelay, () {
              if (mounted) {
                widget.onGameOver();
              }
            });
          }
        },
        child: BlocBuilder<GameBloc, GameState>(
          buildWhen: (previous, current) {
            return previous.isCountingDown != current.isCountingDown ||
                previous.countdownValue != current.countdownValue ||
                previous.currentRoundIndex != current.currentRoundIndex ||
                previous.activeCardIndex != current.activeCardIndex ||
                previous.visibleCardsCount != current.visibleCardsCount ||
                previous.flashFeedback != current.flashFeedback ||
                previous.previewWords != current.previewWords;
          },
          builder: (context, state) {
            if (state.isCountingDown) {
              return _buildCountdown(state);
            }
            if (state.previewWords != null && state.previewWords!.isNotEmpty) {
              return _buildPreviewWordsScreen(state);
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
                      scale: Tween<double>(begin: 3.0, end: 1.0)
                          .animate(
                            CurvedAnimation(
                              parent: _countdownAnimationController,
                              curve: Curves.easeOutCubic,
                            ),
                          )
                          .value,
                      child: Opacity(
                        opacity: _countdownAnimationController.value,
                        child: Text(
                          '${state.countdownValue}',
                          key: ValueKey('countdown_${state.countdownValue}'),
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
                  duration: GameTimingConfig.previewWordsDisplayDuration,
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

    final hasCamera = _settings?.enableCamera == true && _cameraInitialized;

    return Scaffold(
      backgroundColor: hasCamera ? Colors.transparent : bgColor,
      body: Stack(
        children: [
          if (hasCamera && _cameraService.controller != null)
            Positioned.fill(child: CameraPreview(_cameraService.controller!))
          else
            Positioned.fill(
              child: Container(color: bgColor, child: _buildDecorations()),
            ),
          SafeArea(
            child: Column(
              children: [
                Builder(builder: (context) => _buildTopBar(context, state)),
                if (hasCamera) const Spacer(),
                Expanded(
                  flex: hasCamera ? 0 : 1,
                  child: _buildGameGrid(state, currentRound),
                ),
                Builder(builder: (context) => _buildStopButton(context)),
              ],
            ),
          ),
          if (state.previewWords != null && state.previewWords!.isNotEmpty)
            _buildPreviewWordsOverlay(state),
        ],
      ),
    );
  }

  Widget _buildDecorations() {
    final screenSize = MediaQuery.of(context).size;
    return IgnorePointer(
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
              duration: GameTimingConfig.decorationAnimationDuration,
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
    );
  }

  Widget _buildTopBar(BuildContext context, GameState state) {
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
          GestureDetector(
            onTap: () async {
              context.read<GameBloc>().add(const GameToggleShowText());
              await Future.delayed(GameTimingConfig.smallUIDelay);
              await _loadSettings();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    (_settings?.showWordText ?? true)
                        ? Icons.text_fields
                        : Icons.text_fields_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Switch(
                    value: _settings?.showWordText ?? true,
                    onChanged: (value) async {
                      context.read<GameBloc>().add(const GameToggleShowText());
                      await Future.delayed(GameTimingConfig.smallUIDelay);
                      await _loadSettings();
                    },
                    activeColor: Colors.yellow.shade400,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
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
                duration: GameTimingConfig.beatIndicatorAnimationDuration,
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
            childAspectRatio: 0.9,
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
              duration: GameTimingConfig.cardAppearanceDuration,
              curve: GameTimingConfig.cardAppearanceCurve,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 100 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: AnimatedContainer(
                      duration: GameTimingConfig.cardBorderAnimationDuration,
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
                                  color: Colors.yellow.shade400.withOpacity(
                                    0.8,
                                  ),
                                  blurRadius: 30,
                                  spreadRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                      transform: Matrix4.identity()
                        ..scale(isActive ? 1.05 : 1.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final size = constraints.maxWidth;
                                return SizedBox(
                                  width: size,
                                  height: size,
                                  child:
                                      item.image != null &&
                                          item.image!.isNotEmpty
                                      ? RepaintBoundary(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12),
                                            ),
                                            child:
                                                item.image!.startsWith(
                                                  'assets/',
                                                )
                                                ? Image.asset(
                                                    item.image!,
                                                    key: ValueKey(
                                                      'asset_${item.image!}_$index',
                                                    ),
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Container(
                                                        color: Colors.white,
                                                        child: Center(
                                                          child: AnimatedScale(
                                                            scale: isActive
                                                                ? 1.1
                                                                : 1.0,
                                                            duration:
                                                                GameTimingConfig
                                                                    .cardScaleAnimationDuration,
                                                            child: Text(
                                                              item.emoji,
                                                              style:
                                                                  const TextStyle(
                                                                    fontSize:
                                                                        40,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : item.image!.startsWith(
                                                    'data:image',
                                                  )
                                                ? Image.memory(
                                                    _getCachedImageBytes(
                                                      item.image!,
                                                    ),
                                                    key: ValueKey(
                                                      'img_${item.image!.hashCode}_$index',
                                                    ),
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return Container(
                                                            color: Colors.white,
                                                            child: Center(
                                                              child: AnimatedScale(
                                                                scale: isActive
                                                                    ? 1.1
                                                                    : 1.0,
                                                                duration:
                                                                    const Duration(
                                                                      milliseconds:
                                                                          75,
                                                                    ),
                                                                child: Text(
                                                                  item.emoji,
                                                                  style:
                                                                      const TextStyle(
                                                                        fontSize:
                                                                            40,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                  )
                                                : Image.network(
                                                    item.image!,
                                                    key: ValueKey(
                                                      'net_${item.image!}_$index',
                                                    ),
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return Container(
                                                            color: Colors.white,
                                                            child: Center(
                                                              child: AnimatedScale(
                                                                scale: isActive
                                                                    ? 1.1
                                                                    : 1.0,
                                                                duration:
                                                                    const Duration(
                                                                      milliseconds:
                                                                          75,
                                                                    ),
                                                                child: Text(
                                                                  item.emoji,
                                                                  style:
                                                                      const TextStyle(
                                                                        fontSize:
                                                                            40,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                  ),
                                          ),
                                        )
                                      : Container(
                                          color: Colors.white,
                                          child: Center(
                                            child: AnimatedScale(
                                              scale: isActive ? 1.1 : 1.0,
                                              duration: GameTimingConfig
                                                  .cardScaleAnimationDuration,
                                              child: Text(
                                                item.emoji,
                                                style: const TextStyle(
                                                  fontSize: 40,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                );
                              },
                            ),
                          ),
                          if ((_settings?.showWordText ?? true))
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  item.word.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'Anton',
                                    color: isActive
                                        ? Colors.yellow.shade400
                                        : Colors.grey.shade500,
                                    letterSpacing: 1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                    scale: Tween<double>(begin: 0.5, end: 1.0)
                        .animate(
                          CurvedAnimation(
                            parent: _feedbackAnimationController,
                            curve: Curves.easeOut,
                          ),
                        )
                        .value,
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
          audioService.stop();
          context.read<GameBloc>().add(const GameStopped());
          _handleShowInter(onDone: widget.onBack);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade800, width: 1),
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

  Uint8List _getCachedImageBytes(String base64String) {
    if (_imageCache.containsKey(base64String)) {
      return _imageCache[base64String]!;
    }
    final bytes = _base64ToBytes(base64String);
    _imageCache[base64String] = bytes;
    return bytes;
  }

  Widget _buildPreviewWordsScreen(GameState state) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.previewWords!.join(' - ').toUpperCase(),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Anton',
                  color: Colors.white,
                  letterSpacing: 4,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewWordsOverlay(GameState state) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.9),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.previewWords!.join(' - ').toUpperCase(),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Anton',
                  color: Colors.white,
                  letterSpacing: 4,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleShowInter({required void Function() onDone}) async {
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
