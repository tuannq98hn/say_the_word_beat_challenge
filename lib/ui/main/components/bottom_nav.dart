import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:say_word_challenge/services/remote_config_service.dart';
import '../../../common/enums/app_tab.dart';

class BottomNav extends StatelessWidget {
  final AppTab currentTab;
  final Function(AppTab) onTabChange;

  const BottomNav({
    super.key,
    required this.currentTab,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -40,
          left: 0,
          right: 0,
          height: 40,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black,
                ],
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(
                          context,
                          AppTab.trending,
                          'Trending',
                          Icons.trending_up,
                        ),
                        _buildNavItem(
                          context,
                          AppTab.featured,
                          'Featured',
                          Icons.star,
                        ),
                        _buildNavItem(
                          context,
                          AppTab.video,
                          'Video',
                          Icons.play_circle_outline,
                        ),
                        _buildNavItem(
                          context,
                          AppTab.custom,
                          'Custom',
                          Icons.add_circle_outline,
                        ),
                        _buildNavItem(
                          context,
                          AppTab.settings,
                          'Settings',
                          Icons.settings,
                        ),
                      ],
                    ),
                    if (RemoteConfigService.instance.configAdsDataByScreen(
                      "BottomNav",
                    ) !=
                        null) ...[
                      SizedBox.square(dimension: 5),
                      RemoteConfigService.instance.configAdsByScreen("BottomNav")!,
                      SizedBox(height: MediaQuery.of(context).padding.bottom),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    AppTab tab,
    String label,
    IconData icon,
  ) {
    final isActive = currentTab == tab;
    final isVideo = tab == AppTab.video;
    final activeColor = isVideo ? Colors.pink.shade500 : Colors.yellow.shade400;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChange(tab),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  transform: Matrix4.identity()
                    ..translate(0.0, isActive ? -4.0 : 0.0)
                    ..scale(isActive ? 1.1 : 1.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isActive)
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: activeColor.withOpacity(0.3),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: activeColor.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      Icon(
                        icon,
                        size: 24,
                        color: isActive
                            ? activeColor
                            : Colors.grey.shade500,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontFamily: 'Inter',
                    color: isActive
                        ? Colors.white
                        : Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive ? activeColor : Colors.transparent,
                    shape: BoxShape.circle,
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
