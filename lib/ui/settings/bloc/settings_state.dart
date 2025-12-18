import '../../../base/base_bloc_state.dart';
import '../../../data/model/game_settings.dart';

class SettingsState extends BaseBlocState {
  final GameSettings settings;

  SettingsState({
    super.isLoading = false,
    super.error,
    GameSettings? settings,
  }) : settings = settings ?? GameSettings();

  @override
  SettingsState copyWith({
    bool? isLoading,
    String? error,
    bool removeError = false,
    GameSettings? settings,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      error: removeError ? null : (error ?? this.error),
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, settings];
}

