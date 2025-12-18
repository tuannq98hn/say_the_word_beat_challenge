import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/enums/difficulty.dart';
import '../../../common/enums/music_style.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc()..add(const SettingsInitialized()),
      child: Container(
        color: const Color(0xFF111111),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade800,
                      width: 1,
                    ),
                  ),
                ),
                child: const Text(
                  'SETTINGS',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Anton',
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        const Text(
                          'VISUALS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey,
                            letterSpacing: 4,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade800,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Show Text',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  context.read<SettingsBloc>().add(
                                    SettingsUpdated(
                                      state.settings.copyWith(
                                        showWordText: !state.settings.showWordText,
                                      ),
                                    ),
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 56,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: state.settings.showWordText
                                        ? Colors.green.shade500
                                        : Colors.grey.shade600,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Stack(
                                    children: [
                                      AnimatedPositioned(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        left: state.settings.showWordText ? 24.0 : 2.0,
                                        top: 2.0,
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.2),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'DIFFICULTY (SPEED)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey,
                            letterSpacing: 4,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade800,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildDifficultyButton(context, state, Difficulty.easy),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDifficultyButton(context, state, Difficulty.medium),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDifficultyButton(context, state, Difficulty.hard),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'MUSIC STYLE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey,
                            letterSpacing: 4,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade800,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildMusicStyleButton(context, state, MusicStyle.funk),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMusicStyleButton(context, state, MusicStyle.synth),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMusicStyleButton(context, state, MusicStyle.chill),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),
                        Center(
                          child: Text(
                            'Version 1.2.0 • Build 2024',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildDifficultyButton(
    BuildContext context,
    SettingsState state,
    Difficulty difficulty,
  ) {
    final isSelected = state.settings.difficulty == difficulty;
    return GestureDetector(
      onTap: () {
        context.read<SettingsBloc>().add(
          SettingsUpdated(
            state.settings.copyWith(difficulty: difficulty),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.yellow.shade500 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          difficulty.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : Colors.grey.shade500,
            fontFamily: 'Inter',
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildMusicStyleButton(
    BuildContext context,
    SettingsState state,
    MusicStyle style,
  ) {
    final isSelected = state.settings.musicStyle == style;
    return GestureDetector(
      onTap: () {
        context.read<SettingsBloc>().add(
          SettingsUpdated(
            state.settings.copyWith(musicStyle: style),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.shade500 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          style.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey.shade500,
            fontFamily: 'Inter',
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

