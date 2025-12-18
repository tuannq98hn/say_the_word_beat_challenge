import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/topic_metadata.dart';
import '../../../data/model/challenge.dart';
import '../../../services/gemini_service.dart' show GeminiService;
import '../../common/widgets/challenge_card.dart';
import '../bloc/topic_list_bloc.dart';
import '../bloc/topic_list_event.dart';
import '../bloc/topic_list_state.dart';

class TopicListPage extends StatefulWidget {
  final List<TopicMetadata> topics;
  final String tabName;
  final Future<void> Function(Challenge)? onChallengeSelected;

  const TopicListPage({
    super.key,
    required this.topics,
    required this.tabName,
    required this.onChallengeSelected,
  });

  @override
  State<TopicListPage> createState() => _TopicListPageState();
}

class _TopicListPageState extends State<TopicListPage> {

  List<String> _getPreviewEmojis(String topicId) {
    final challenge = GeminiService.predefinedChallenges[topicId];
    if (challenge == null) {
      return List.filled(8, '❓');
    }

    final allItems = challenge.rounds.expand((r) => r.items).toList();
    final uniqueEmojis = allItems.map((i) => i.emoji).toSet().toList();
    final result = <String>[];
    for (int i = 0; i < 8; i++) {
      result.add(uniqueEmojis[i % uniqueEmojis.length]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TopicListBloc()..add(const TopicListInitialized()),
      child: BlocListener<TopicListBloc, TopicListState>(
        listener: (context, state) async {
          if (state.selectedChallenge != null && widget.onChallengeSelected != null) {
            final challenge = state.selectedChallenge!;
            context.read<TopicListBloc>().add(const TopicListInitialized());
            if (context.mounted) {
              await widget.onChallengeSelected!(challenge);
            }
          }
        },
      child: Container(
        color: const Color(0xFF111111),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111).withOpacity(0.9),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade800,
                      width: 1,
                    ),
                  ),
                ),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFFFFD700),
                          Color(0xFFFF6B35),
                        ],
                      ).createShader(bounds),
                      child: Text(
                        widget.tabName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Anton',
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<TopicListBloc, TopicListState>(
                  builder: (context, state) {
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.4,
                      ),
                      itemCount: widget.topics.length,
                      itemBuilder: (context, index) {
                        final topic = widget.topics[index];
                        final previewEmojis = _getPreviewEmojis(topic.id);
                        final isLoading = state.loadingTopicId == topic.id;
                        final isDisabled =
                            state.loadingTopicId != null && !isLoading;

                        return ChallengeCard(
                          icon: topic.icon,
                          label: topic.label,
                          backgroundEmojis: previewEmojis,
                          isLoading: isLoading,
                          isDisabled: isDisabled,
                          onTap: () {
                            context
                                .read<TopicListBloc>()
                                .add(TopicSelected(topic));
                          },
                        );
                      },
                    );
                  },
              ),
            ),
          ],
        ),
      ),
        ),
      ),
    );
  }
}

