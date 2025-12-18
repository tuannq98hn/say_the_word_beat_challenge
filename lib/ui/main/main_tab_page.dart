import 'package:flutter/material.dart';
import 'components/bottom_nav.dart';
import '../topic_list/view/topic_list_page.dart';
import '../settings/view/settings_page.dart';
import '../custom/view/custom_tab_page.dart';
import '../video/view/video_tab_page.dart';
import '../../common/enums/app_tab.dart';
import '../../data/model/challenge.dart';
import '../../data/model/tiktok_video.dart';
import '../../services/gemini_service.dart' show GeminiService;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: Stack(
        children: [
          _buildTabContent(),
          BottomNav(
            currentTab: _activeTab,
            onTabChange: (tab) {
              setState(() {
                _activeTab = tab;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
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
        return VideoTabPage(
          onVideoClick: widget.onVideoSelected,
        );
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
