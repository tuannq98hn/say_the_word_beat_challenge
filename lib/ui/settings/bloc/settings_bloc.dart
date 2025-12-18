import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../base/base_bloc.dart';
import '../../../data/model/game_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends BaseBloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsState()) {
    on<SettingsInitialized>(_onSettingsInitialized);
    on<SettingsUpdated>(_onSettingsUpdated);
  }

  Future<void> _onSettingsInitialized(
    SettingsInitialized event,
    Emitter<SettingsState> emit,
  ) async {
    setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('game_settings');
      final settings = json != null
          ? GameSettings.fromJson(
              Map<String, dynamic>.from(
                jsonDecode(json),
              ),
            )
          : GameSettings();
      emit(state.copyWith(settings: settings, isLoading: false));
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> _onSettingsUpdated(
    SettingsUpdated event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(settings: event.settings));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('game_settings', jsonEncode(event.settings.toJson()));
    } catch (e) {
      setError(e.toString());
    }
  }
}

