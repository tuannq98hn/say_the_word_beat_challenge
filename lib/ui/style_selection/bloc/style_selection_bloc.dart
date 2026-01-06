import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/model/game_settings.dart';
import 'style_selection_event.dart';
import 'style_selection_state.dart';

class StyleSelectionBloc extends Bloc<StyleSelectionEvent, StyleSelectionState> {
  StyleSelectionBloc() : super(const StyleSelectionState()) {
    on<StyleSelectionInitialized>(_onInitialized);
    on<StyleSelected>(_onStyleSelected);
  }

  Future<void> _onInitialized(
    StyleSelectionInitialized event,
    Emitter<StyleSelectionState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, removeError: true));
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('game_settings');
      final settings = json != null
          ? GameSettings.fromJson(Map<String, dynamic>.from(jsonDecode(json)))
          : const GameSettings();
      emit(state.copyWith(isLoading: false, settings: settings));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onStyleSelected(
    StyleSelected event,
    Emitter<StyleSelectionState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, removeError: true));
    try {
      final updated = state.settings.copyWith(
        musicStyle: event.style,
        difficulty: event.difficulty,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('game_settings', jsonEncode(updated.toJson()));
      emit(state.copyWith(isLoading: false, settings: updated, isCompleted: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}

