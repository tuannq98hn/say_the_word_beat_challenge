import 'dart:async';
import 'package:flutter/services.dart';
import '../common/enums/music_style.dart';

class AudioService {
  Timer? _timer;
  bool _isPlaying = false;
  int _bpm = 138;
  final double _lookahead = 25.0;
  final double _scheduleAheadTime = 0.1;
  int _currentBeat = 0;
  int _currentSubBeat = 0;
  Function(int)? _onBeatCallback;
  MusicStyle _musicStyle = MusicStyle.funk;
  double _nextNoteTime = 0;
  DateTime? _startTime;

  void setBpm(int bpm) {
    _bpm = bpm;
  }

  void setMusicStyle(MusicStyle style) {
    _musicStyle = style;
  }

  void setOnBeatCallback(Function(int) callback) {
    _onBeatCallback = callback;
  }

  void init() {
    // Initialize audio context if needed
    // In Flutter, we don't need to initialize like in web AudioContext
  }

  void start() {
    if (_isPlaying) return;

    _isPlaying = true;
    _currentBeat = 0;
    _currentSubBeat = 0;
    _startTime = DateTime.now();
    _nextNoteTime = 0.1;

    _scheduler();
  }

  void stop() {
    _isPlaying = false;
    _timer?.cancel();
    _timer = null;
  }

  void _scheduler() {
    if (!_isPlaying) return;

    final now = DateTime.now().difference(_startTime!).inMilliseconds / 1000.0;

    while (_nextNoteTime < now + _scheduleAheadTime) {
      _scheduleNote(_currentSubBeat, _nextNoteTime);
      _nextNote();
    }

    if (_isPlaying) {
      _timer = Timer(Duration(milliseconds: _lookahead.round()), _scheduler);
    }
  }

  void _nextNote() {
    final secondsPerEighth = (60.0 / _bpm) / 2;
    _nextNoteTime += secondsPerEighth;

    _currentSubBeat++;
    if (_currentSubBeat == 8) {
      _currentSubBeat = 0;
    }

    if (_currentSubBeat % 2 == 0) {
      _currentBeat = _currentSubBeat ~/ 2;
    }
  }

  void _scheduleNote(int subBeat, double time) {
    final isDownBeat = subBeat % 2 == 0;
    final quarterBeat = subBeat ~/ 2;

    if (isDownBeat && _onBeatCallback != null) {
      final delay = (time - (DateTime.now().difference(_startTime!).inMilliseconds / 1000.0)) * 1000;
      if (delay >= 0) {
        Timer(Duration(milliseconds: delay.round()), () {
          if (_isPlaying && _onBeatCallback != null) {
            _onBeatCallback!(quarterBeat);
          }
        });
      }
    }

    _playSound(isDownBeat, quarterBeat);
  }

  void _playSound(bool isDownBeat, int quarterBeat) {
    double kickFreq = 150;
    double hiHatFreq = 3000;
    double snareFreq = 400;

    switch (_musicStyle) {
      case MusicStyle.synth:
        kickFreq = 120;
        snareFreq = 400;
        break;
      case MusicStyle.chill:
        kickFreq = 100;
        snareFreq = 200;
        break;
      case MusicStyle.funk:
      default:
        kickFreq = 150;
        snareFreq = 400;
        break;
    }

    if (isDownBeat) {
      if (quarterBeat == 1 || quarterBeat == 3) {
        SystemSound.play(SystemSoundType.alert);
      } else {
        SystemSound.play(SystemSoundType.click);
      }
    } else {
      SystemSound.play(SystemSoundType.alert);
    }
  }
}

final audioService = AudioService();
