import 'package:equatable/equatable.dart';
import '../../../data/model/topic_metadata.dart';

abstract class TopicListEvent extends Equatable {
  const TopicListEvent();

  @override
  List<Object> get props => [];
}

class TopicListInitialized extends TopicListEvent {
  const TopicListInitialized();
}

class TopicSelected extends TopicListEvent {
  final TopicMetadata topic;

  const TopicSelected(this.topic);

  @override
  List<Object> get props => [topic];
}

