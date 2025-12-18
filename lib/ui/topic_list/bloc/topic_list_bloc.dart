import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../base/base_bloc.dart';
import '../../../data/model/challenge.dart';
import '../../../services/gemini_service.dart' show GeminiService;
import '../../../services/audio_service.dart';
import 'topic_list_event.dart';
import 'topic_list_state.dart';

class TopicListBloc extends BaseBloc<TopicListEvent, TopicListState> {
  TopicListBloc() : super(const TopicListState()) {
    on<TopicListInitialized>(_onTopicListInitialized);
    on<TopicSelected>(_onTopicSelected);
  }

  Future<void> _onTopicListInitialized(
    TopicListInitialized event,
    Emitter<TopicListState> emit,
  ) async {
    emit(state.copyWith(
      removeSelectedChallenge: true,
      removeLoadingTopicId: true,
      isLoading: false,
    ));
  }

  Future<void> _onTopicSelected(
    TopicSelected event,
    Emitter<TopicListState> emit,
  ) async {
    emit(state.copyWith(loadingTopicId: event.topic.id, isLoading: true));

    try {
      audioService.init();
      final challenge = await GeminiService().generateWordChallenge(
        event.topic.id,
        event.topic.prompt,
      );
      emit(state.copyWith(
        selectedChallenge: challenge,
        loadingTopicId: null,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        loadingTopicId: null,
        isLoading: false,
      ));
    }
  }
}

