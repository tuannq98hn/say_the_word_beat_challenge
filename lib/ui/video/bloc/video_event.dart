import 'package:equatable/equatable.dart';

abstract class VideoEvent extends Equatable {
  const VideoEvent();

  @override
  List<Object> get props => [];
}

class VideoInitialized extends VideoEvent {
  const VideoInitialized();
}

