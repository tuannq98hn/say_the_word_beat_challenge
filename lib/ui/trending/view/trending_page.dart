import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/challenge.dart';
import '../../../services/trending_server_service.dart';
import '../../../services/data/trending_server_metadata.dart';
import '../../common/widgets/challenge_card.dart';
import '../bloc/trending_bloc.dart';
import '../bloc/trending_event.dart';
import '../bloc/trending_state.dart';

class TrendingPage extends StatefulWidget {
  final Future<void> Function(Challenge)? onChallengeSelected;

  const TrendingPage({
    super.key,
    required this.onChallengeSelected,
  });

  @override
  State<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TrendingBloc()..add(const TrendingInitialized()),
      child: BlocListener<TrendingBloc, TrendingState>(
        listener: (context, state) async {
          if (state.selectedChallenge != null && widget.onChallengeSelected != null) {
            final challenge = state.selectedChallenge!;
            context.read<TrendingBloc>().add(const TrendingInitialized());
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
                        child: const Text(
                          'Trending Challenge',
                          style: TextStyle(
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
                  child: BlocBuilder<TrendingBloc, TrendingState>(
                    builder: (context, state) {
                      return FutureBuilder<Map<String, Challenge>>(
                        future: trendingServerService.getAllChallengesMap(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final challengesMap = snapshot.data!;
                          
                          return GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.4,
                            ),
                            itemCount: trendingServerMetadata.length,
                            itemBuilder: (context, index) {
                              final topic = trendingServerMetadata[index];
                              
                              List<String> previewImages = [];
                              final challenge = challengesMap[topic.id];
                              if (challenge != null && challenge.rounds.isNotEmpty) {
                                final lastRound = challenge.rounds.last;
                                previewImages = lastRound.items
                                    .where((item) => item.image != null && item.image!.isNotEmpty)
                                    .map((item) => item.image!)
                                    .take(8)
                                    .toList();
                                while (previewImages.length < 8 && lastRound.items.isNotEmpty) {
                                  final item = lastRound.items[previewImages.length % lastRound.items.length];
                                  if (item.image != null && item.image!.isNotEmpty) {
                                    previewImages.add(item.image!);
                                  }
                                }
                              }
                              
                              final isLoading = state.loadingTopicId == topic.id;
                              final isDisabled =
                                  state.loadingTopicId != null && !isLoading;

                              return ChallengeCard(
                                icon: topic.icon,
                                label: topic.label,
                                backgroundEmojis: [],
                                backgroundImages: previewImages,
                                isLoading: isLoading,
                                isDisabled: isDisabled,
                                onTap: () {
                                  context
                                      .read<TrendingBloc>()
                                      .add(TrendingTopicSelected(topic));
                                },
                              );
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

