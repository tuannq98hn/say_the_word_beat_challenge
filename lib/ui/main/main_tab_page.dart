import 'package:flutter/material.dart';
import 'package:say_word_challenge/ui/common/widgets/keep_alive_page.dart';

import '../../common/enums/app_tab.dart';
import '../../data/model/challenge.dart';
import '../../data/model/tiktok_video.dart';
import '../../services/gemini_service.dart' show GeminiService;
import '../custom/view/custom_tab_page.dart';
import '../settings/view/settings_page.dart';
import '../topic_list/view/topic_list_page.dart';
import '../video/view/video_tab_page.dart';
import 'components/bottom_nav.dart';

class MainTabPage extends StatefulWidget {
  final Future<void> Function(Challenge) onChallengeSelected;
  final void Function(TikTokVideo) onVideoSelected;

  const MainTabPage({
    super.key,
    required this.onChallengeSelected,
    required this.onVideoSelected,
  });

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> {
  AppTab _activeTab = AppTab.trending;
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: Column(
        children: [
          // Expanded(child: _buildTabContent()),
          Expanded(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: AppTab.values
                  .map((tab) => KeepAlivePage(child: _buildTabContent(tab)))
                  .toList(),
            ),
          ),
          BottomNav(
            currentTab: _activeTab,
            onTabChange: (tab) {
              setState(() {
                _activeTab = tab;
              });
              _pageController.jumpToPage(_activeTab.index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(AppTab tab) {
    switch (tab) {
      case AppTab.trending:
        return TopicListPage(
          key: ValueKey('trending'),
          topics: GeminiService.trendingTopicsList,
          tabName: 'Trending Challenge',
          onChallengeSelected: widget.onChallengeSelected,
        );
      case AppTab.featured:
        return TopicListPage(
          key: ValueKey('featured'),
          topics: GeminiService.featuredTopicsList,
          tabName: 'Featured Challenge',
          onChallengeSelected: widget.onChallengeSelected,
        );
      case AppTab.video:
        return VideoTabPage(onVideoClick: widget.onVideoSelected);
      case AppTab.custom:
        return CustomTabPage(
          key: ValueKey('custom'),
          onChallengeSelected: widget.onChallengeSelected,
        );
      case AppTab.settings:
        return const SettingsPage();
      default:
        return const SizedBox();
    }
  }
}
