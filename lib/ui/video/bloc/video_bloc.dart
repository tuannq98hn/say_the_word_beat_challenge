import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../base/base_bloc.dart';
import '../../../data/model/tiktok_video.dart';
import '../../../services/video_service.dart';
import 'video_event.dart';
import 'video_state.dart';

class VideoBloc extends BaseBloc<VideoEvent, VideoState> {
  final VideoService _videoService = videoService;

  VideoBloc() : super(const VideoState()) {
    on<VideoInitialized>(_onVideoInitialized);
  }

  Future<void> _onVideoInitialized(
    VideoInitialized event,
    Emitter<VideoState> emit,
  ) async {
    setLoading(true);
    try {
      final videos = await _videoService.fetchTikTokVideos();
      emit(state.copyWith(videos: videos, isLoading: false));
    } catch (e) {
      setError(e.toString());
    }
  }
}

