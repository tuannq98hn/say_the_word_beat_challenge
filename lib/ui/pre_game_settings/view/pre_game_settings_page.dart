import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/model/challenge.dart';
import '../../../data/model/game_settings.dart';
import '../../../routes/app_routes.dart';
import '../../../services/recording_service.dart';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreGameSettingsPage extends StatefulWidget {
  final Challenge challenge;

  const PreGameSettingsPage({
    super.key,
    required this.challenge,
  });

  @override
  State<PreGameSettingsPage> createState() => _PreGameSettingsPageState();
}

class _PreGameSettingsPageState extends State<PreGameSettingsPage> {
  bool _showWordText = false;
  bool _enableRecording = false;
  bool _enableCamera = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('game_settings');
    if (json != null) {
      final settings = GameSettings.fromJson(
        Map<String, dynamic>.from(jsonDecode(json)),
      );
      setState(() {
        _showWordText = settings.showWordText;
        _enableRecording = settings.enableRecording;
        _enableCamera = settings.enableCamera;
      });
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = GameSettings(
      showWordText: _showWordText,
      enableRecording: _enableRecording,
      enableCamera: _enableCamera,
    );
    await prefs.setString('game_settings', jsonEncode(settings.toJson()));
  }

  void _startGame() async {
    await _saveSettings();
    
    if (_enableRecording) {
      final recordingService = RecordingService();
      final hasPermission = await recordingService.requestPermissions();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Screen recording permission required. Please grant permission and try again.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }
      
      final permissionGranted = await _requestScreenRecordingPermission();
      if (!permissionGranted) {
        return;
      }
    }
    
    if (mounted) {
      context.pop();
      context.push(
        AppRoutes.game,
        extra: widget.challenge,
      );
    }
  }

  Future<bool> _requestScreenRecordingPermission() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final videoName = 'game_recording_$timestamp';
    
    try {
      final started = await FlutterScreenRecording.startRecordScreenAndAudio(videoName);
      
      if (started) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('screen_recording_permission_granted', true);
        await prefs.setString('recording_video_name', videoName);
        await prefs.setBool('recording_is_active', true);
        
        return true;
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('screen_recording_permission_granted', false);
      await prefs.setBool('recording_is_active', false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Screen recording permission required to continue.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return false;
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('screen_recording_permission_granted', false);
      await prefs.setBool('recording_is_active', false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to request screen recording permission.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Pre-Game Settings',
                style: TextStyle(
                  fontFamily: 'Anton',
                  fontSize: 32,
                  color: Colors.black87,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 40),
              _buildSettingOption(
                title: 'Show text below images',
                value: _showWordText,
                onChanged: (value) {
                  setState(() {
                    _showWordText = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              _buildSettingOption(
                title: 'Record screen and audio',
                value: _enableRecording,
                onChanged: (value) {
                  setState(() {
                    _enableRecording = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              _buildSettingOption(
                title: 'Enable camera',
                value: _enableCamera,
                onChanged: (value) {
                  setState(() {
                    _enableCamera = value;
                  });
                },
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.grey, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _startGame,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Start',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingOption({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue[600],
          ),
        ],
      ),
    );
  }
}
