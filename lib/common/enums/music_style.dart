enum MusicStyle {
  funk,
  synth,
  chill,
}

extension MusicStyleExtension on MusicStyle {
  String get name {
    switch (this) {
      case MusicStyle.funk:
        return 'FUNK';
      case MusicStyle.synth:
        return 'SYNTH';
      case MusicStyle.chill:
        return 'CHILL';
    }
  }
}
