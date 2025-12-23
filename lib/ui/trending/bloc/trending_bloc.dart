import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../base/base_bloc.dart';
import '../../../services/trending_server_service.dart';
import '../../../services/audio_service.dart';
import 'trending_event.dart';
import 'trending_state.dart';

class TrendingBloc extends BaseBloc<TrendingEvent, TrendingState> {
  TrendingBloc() : super(const TrendingState()) {
    on<TrendingInitialized>(_onTrendingInitialized);
    on<TrendingTopicSelected>(_onTopicSelected);
  }

  Future<void> _onTrendingInitialized(
    TrendingInitialized event,
    Emitter<TrendingState> emit,
  ) async {
    emit(state.copyWith(
      removeSelectedChallenge: true,
      removeLoadingTopicId: true,
      isLoading: false,
    ));
  }

  Future<void> _onTopicSelected(
    TrendingTopicSelected event,
    Emitter<TrendingState> emit,
  ) async {
    emit(state.copyWith(loadingTopicId: event.topic.id, isLoading: true));

    try {
      audioService.init();
      final challenge = await trendingServerService.getChallenge(event.topic.id);
      if (challenge != null) {
        emit(state.copyWith(
          selectedChallenge: challenge,
          loadingTopicId: null,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(
          error: 'Challenge not found',
          loadingTopicId: null,
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        loadingTopicId: null,
        isLoading: false,
      ));
    }
  }
}

