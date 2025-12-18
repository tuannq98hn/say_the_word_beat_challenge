import 'package:flutter/material.dart';

mixin LoadingMixin {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    _isLoading = loading;
  }

  Widget buildLoadingOverlay({required Widget child}) {
    return Stack(
      children: [
        child,
        if (_isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}

