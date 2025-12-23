import 'dart:ui';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ChallengeCard extends StatelessWidget {
  final String icon;
  final String label;
  final List<String>? backgroundEmojis;
  final List<String>? backgroundImages;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback? onTap;

  const ChallengeCard({
    super.key,
    required this.icon,
    required this.label,
    this.backgroundEmojis,
    this.backgroundImages,
    this.isLoading = false,
    this.isDisabled = false,
    this.onTap,
  });

  Uint8List _base64ToBytes(String base64String) {
    final base64Data = base64String.split(',').last;
    return base64Decode(base64Data);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLoading
                ? Colors.yellow.shade400
                : Colors.grey.shade700,
            width: isLoading ? 4 : 1,
          ),
          boxShadow: isLoading
              ? [
                  BoxShadow(
                    color: Colors.yellow.shade400.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Opacity(
          opacity: isDisabled ? 0.3 : 1.0,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: _buildBackground(),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.65),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLoading)
                      const Text(
                        '💿',
                        style: TextStyle(fontSize: 32),
                      )
                    else
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Anton',
                          color: Colors.white,
                          letterSpacing: 1.2,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    if (backgroundImages != null && backgroundImages!.isNotEmpty) {
      return Opacity(
        opacity: 0.4,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
              ),
              itemCount: 8,
              itemBuilder: (context, idx) {
                final img = backgroundImages![idx % backgroundImages!.length];
                if (img.isEmpty) {
                  return Container(color: Colors.black);
                }
                if (img.startsWith('assets/')) {
                  return Image.asset(
                    img,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: Colors.black);
                    },
                  );
                } else if (img.startsWith('data:image')) {
                  return Image.memory(
                    _base64ToBytes(img),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: Colors.black);
                    },
                  );
                } else {
                  return Container(color: Colors.black);
                }
              },
            ),
          ),
        ),
      );
    } else if (backgroundEmojis != null && backgroundEmojis!.isNotEmpty) {
      return Opacity(
        opacity: 0.3,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 1,
              crossAxisSpacing: 1,
            ),
            itemCount: 8,
            itemBuilder: (context, idx) => Center(
              child: Text(
                backgroundEmojis![idx % backgroundEmojis!.length],
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
