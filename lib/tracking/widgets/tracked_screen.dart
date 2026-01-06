import 'dart:async';

import 'package:flutter/widgets.dart';

import '../app_analytics.dart';

/// Simple wrapper to log screen usage once when the widget is inserted.
class TrackedScreen extends StatefulWidget {
  const TrackedScreen({
    super.key,
    required this.screenClass,
    required this.child,
    this.screenName,
  });

  final String screenClass;
  final String? screenName;
  final Widget child;

  @override
  State<TrackedScreen> createState() => _TrackedScreenState();
}

class _TrackedScreenState extends State<TrackedScreen> {
  bool _logged = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_logged) return;
    _logged = true;
    unawaited(
      AppAnalytics.logScreenView(
        screenClass: widget.screenClass,
        screenName: widget.screenName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}


