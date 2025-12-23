import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
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
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMusicPlaying = false;

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

  Future<void> start([Duration delay = Duration.zero]) async {
    if (_isPlaying) return;

    _isPlaying = true;
    _currentBeat = 0;
    _currentSubBeat = 0;
    _startTime = DateTime.now();
    _nextNoteTime = 0.1;

    if (!_isMusicPlaying) {
      if (delay.inMilliseconds > 0) {
        await Future.delayed(delay);
      }
      try {
        await _audioPlayer.play(AssetSource('mp3/music2.mp3'));
        await _audioPlayer.setReleaseMode(ReleaseMode.release);
        _isMusicPlaying = true;
      } catch (e) {
        // Error playing music - silently fail
      }
    }

    _scheduler();
  }

  Future<void> stop() async {
    _isPlaying = false;
    _timer?.cancel();
    _timer = null;
    
    if (_isMusicPlaying) {
      await _audioPlayer.stop();
      _isMusicPlaying = false;
    }
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
    // Music is now played from mp3 file, no need for SystemSound
    // This method is kept for compatibility but does nothing
  }
  
  Future<void> dispose() async {
    await stop();
    await _audioPlayer.dispose();
  }
}

final audioService = AudioService();
