import 'dart:async';
import 'dart:io';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordingService {
  static final RecordingService _instance = RecordingService._internal();
  factory RecordingService() => _instance;
  RecordingService._internal();
  
  bool _isRecording = false;
  String? _videoName;

  bool get isRecording => _isRecording;

  Future<bool> hasScreenRecordingPermission() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('screen_recording_permission_granted') ?? false;
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final micStatus = await Permission.microphone.status;
      if (!micStatus.isGranted) {
        final result = await Permission.microphone.request();
        if (!result.isGranted) {
          return false;
        }
      }

      if (await Permission.videos.isDenied) {
        final result = await Permission.videos.request();
        if (!result.isGranted) {
          return false;
        }
      }
    }

    return true;
  }

  Future<bool> startRecording() async {
    if (_isRecording) return false;

    final hasPermission = await hasScreenRecordingPermission();
    if (!hasPermission) {
      return false;
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _videoName = 'game_recording_$timestamp';

      final started = await FlutterScreenRecording.startRecordScreenAndAudio(_videoName!);
      
      if (started) {
        _isRecording = true;
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    try {
      final path = await FlutterScreenRecording.stopRecordScreen;
      
      _isRecording = false;
      _videoName = null;

      return path;
    } catch (e) {
      _isRecording = false;
      _videoName = null;
      return null;
    }
  }
}
