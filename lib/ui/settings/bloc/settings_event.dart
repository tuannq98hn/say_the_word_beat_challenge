import 'package:equatable/equatable.dart';
import '../../../data/model/game_settings.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class SettingsInitialized extends SettingsEvent {
  const SettingsInitialized();
}

class SettingsUpdated extends SettingsEvent {
  final GameSettings settings;

  const SettingsUpdated(this.settings);

  @override
  List<Object> get props => [settings];
}

