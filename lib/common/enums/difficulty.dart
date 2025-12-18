enum Difficulty {
  easy,
  medium,
  hard,
}

extension DifficultyExtension on Difficulty {
  int get bpm {
    switch (this) {
      case Difficulty.easy:
        return 120;
      case Difficulty.medium:
        return 138;
      case Difficulty.hard:
        return 150;
    }
  }

  String get name {
    switch (this) {
      case Difficulty.easy:
        return 'EASY';
      case Difficulty.medium:
        return 'MEDIUM';
      case Difficulty.hard:
        return 'HARD';
    }
  }
}
