extension StringExtensions on String {
  bool get isNullOrEmpty => isEmpty;

  bool get isNotNullOrEmpty => !isEmpty;

  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get capitalizeFirstOfEach {
    if (isEmpty) return this;
    return split(' ').map((str) => str.capitalize).join(' ');
  }
}

