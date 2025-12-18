import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../base/base_bloc.dart';
import '../../../data/model/challenge.dart';
import '../../../data/local/database_service.dart';
import 'custom_event.dart';
import 'custom_state.dart';

class CustomBloc extends BaseBloc<CustomEvent, CustomState> {
  final DatabaseService _databaseService = DatabaseService();

  CustomBloc() : super(const CustomState()) {
    on<CustomInitialized>(_onCustomInitialized);
    on<CustomChallengeSelected>(_onCustomChallengeSelected);
  }

  Future<void> _onCustomInitialized(
    CustomInitialized event,
    Emitter<CustomState> emit,
  ) async {
    setLoading(true);
    try {
      final challenges = await _databaseService.loadChallenges();
      emit(state.copyWith(customChallenges: challenges, isLoading: false));
    } catch (e) {
      setError(e.toString());
    }
  }

  void _onCustomChallengeSelected(
    CustomChallengeSelected event,
    Emitter<CustomState> emit,
  ) {
    // Handle challenge selection if needed
  }
}

