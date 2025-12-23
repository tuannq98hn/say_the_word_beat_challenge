import 'package:equatable/equatable.dart';
import '../../../data/model/topic_metadata.dart';

abstract class TrendingEvent extends Equatable {
  const TrendingEvent();

  @override
  List<Object> get props => [];
}

class TrendingInitialized extends TrendingEvent {
  const TrendingInitialized();
}

class TrendingTopicSelected extends TrendingEvent {
  final TopicMetadata topic;

  const TrendingTopicSelected(this.topic);

  @override
  List<Object> get props => [topic];
}

