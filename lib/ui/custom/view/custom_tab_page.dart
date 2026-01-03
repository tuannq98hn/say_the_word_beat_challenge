import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_ads_native/index.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:say_word_challenge/services/interstitial_ads_controller.dart';

import '../../../data/model/challenge.dart';
import '../../common/widgets/challenge_card.dart';
import '../../create_wizard/view/create_wizard_page.dart';
import '../bloc/custom_bloc.dart';
import '../bloc/custom_event.dart';
import '../bloc/custom_state.dart';

class CustomTabPage extends StatefulWidget {
  final Future<void> Function(Challenge)? onChallengeSelected;

  const CustomTabPage({super.key, required this.onChallengeSelected});

  @override
  State<CustomTabPage> createState() => _CustomTabPageState();
}

class _CustomTabPageState extends State<CustomTabPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CustomBloc()..add(const CustomInitialized()),
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
                    bottom: BorderSide(color: Colors.grey.shade800, width: 1),
                  ),
                ),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF60A5FA), Color(0xFFA78BFA)],
                      ).createShader(bounds),
                      child: const Text(
                        'CUSTOM DECK',
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
                child: BlocBuilder<CustomBloc, CustomState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _handleShowInter(
                                onDone: () {
                                  Navigator.of(context)
                                      .push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const CreateWizardPage(),
                                          fullscreenDialog: true,
                                        ),
                                      )
                                      .then((_) {
                                        if (mounted) {
                                          context.read<CustomBloc>().add(
                                            const CustomInitialized(),
                                          );
                                        }
                                      });
                                },
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey.shade900,
                                    Colors.grey.shade800,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade700,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.yellow.shade400,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.yellow.shade400
                                              .withOpacity(0.5),
                                          blurRadius: 15,
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '+',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'CREATE NEW',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          fontFamily: 'Anton',
                                          color: Colors.white,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      Text(
                                        'Make your own beat',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade500,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          state.customChallenges.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 40),
                                  child: Column(
                                    children: [
                                      Text(
                                        '🎹',
                                        style: TextStyle(
                                          fontSize: 64,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No custom challenges yet.\nTap above to start!',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade400,
                                          letterSpacing: 2,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    120,
                                  ),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                        childAspectRatio: 1.4,
                                      ),
                                  itemCount: state.customChallenges.length,
                                  itemBuilder: (context, index) {
                                    final challenge =
                                        state.customChallenges[index];
                                    final lastRound =
                                        challenge.rounds.isNotEmpty
                                        ? challenge.rounds.last
                                        : null;
                                    final previewImages = lastRound != null
                                        ? lastRound.items
                                              .map((item) => item.image)
                                              .where((img) => img != null)
                                              .take(8)
                                              .toList()
                                        : <String?>[];

                                    return ChallengeCard(
                                      icon: challenge.icon ?? '📷',
                                      label: challenge.topic,
                                      backgroundImages: previewImages
                                          .where(
                                            (img) =>
                                                img != null && img.isNotEmpty,
                                          )
                                          .cast<String>()
                                          .toList(),
                                      onTap: () => widget.onChallengeSelected
                                          ?.call(challenge),
                                    );
                                  },
                                ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleShowInter({required void Function() onDone}) async {
    final origin_onInterstitialClosed = InterstitialAds.onInterstitialClosed;
    final origin_onInterstitialFailed = InterstitialAds.onInterstitialFailed;
    final origin_onInterstitialShown = InterstitialAds.onInterstitialShown;
    InterstitialAds.onInterstitialClosed = () {
      InterstitialAds.onInterstitialClosed = origin_onInterstitialClosed;
      onDone();
    };
    InterstitialAds.onInterstitialFailed = (_) {
      InterstitialAds.onInterstitialFailed = origin_onInterstitialFailed;
      onDone();
    };
    InterstitialAds.onInterstitialShown = () {
      InterstitialAds.onInterstitialShown = origin_onInterstitialShown;
      // todo show native full screen ==> check policy
    };
    if (!await InterstitialAdsController.instance.showInterstitialAd()) {
      InterstitialAds.onInterstitialClosed = origin_onInterstitialClosed;
      InterstitialAds.onInterstitialFailed = origin_onInterstitialFailed;
      InterstitialAds.onInterstitialShown = origin_onInterstitialShown;
      onDone();
    }
  }
}
