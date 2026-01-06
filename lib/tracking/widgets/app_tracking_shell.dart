import 'package:flutter/widgets.dart';

import '../ads_event_listener.dart';
import '../ads_session_tracker.dart';

/// Root widget to bootstrap tracking (ads session counters, lifecycle flush).
class AppTrackingShell extends StatefulWidget {
  const AppTrackingShell({super.key, required this.child});

  final Widget child;

  @override
  State<AppTrackingShell> createState() => _AppTrackingShellState();
}

class _AppTrackingShellState extends State<AppTrackingShell>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AdsEventListener.start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Flush on background/exit to capture "1 phiên dùng app" ad counts.
    if (state == AppLifecycleState.paused) {
      AdsSessionTracker.flush(reason: 'paused');
    } else if (state == AppLifecycleState.detached) {
      AdsSessionTracker.flush(reason: 'detached');
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}


