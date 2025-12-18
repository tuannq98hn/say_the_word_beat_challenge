import '../../../base/base_bloc_state.dart';
import '../../../data/model/tiktok_video.dart';

class VideoState extends BaseBlocState {
  final List<TikTokVideo> videos;

  const VideoState({
    super.isLoading = false,
    super.error,
    this.videos = const [],
  });

  @override
  VideoState copyWith({
    bool? isLoading,
    String? error,
    bool removeError = false,
    List<TikTokVideo>? videos,
  }) {
    return VideoState(
      isLoading: isLoading ?? this.isLoading,
      error: removeError ? null : (error ?? this.error),
      videos: videos ?? this.videos,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, videos];
}

