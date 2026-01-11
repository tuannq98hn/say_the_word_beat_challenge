import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../ads_event_listener.dart';
import '../ads_session_tracker.dart';

/// Root widget to bootstrap tracking (ads session counters, lifecycle flush).
class AppTrackingShell extends StatefulWidget {
  const AppTrackingShell({super.key, required this.child});

  final Widget child;

  // 2. Hàm static trả về chính AppTrackingShellState
  static AppTrackingShellState of(BuildContext context) {
    final AppTrackingShellState? scope = context
        .findAncestorStateOfType<AppTrackingShellState>();
    assert(scope != null, 'No AppTrackingShell found in context');
    return scope!;
  }

  @override
  State<AppTrackingShell> createState() => AppTrackingShellState();
}

class AppTrackingShellState extends State<AppTrackingShell>
    with WidgetsBindingObserver {
  late StreamSubscription<List<ConnectivityResult>> _streamSubscription;
  Timer? _timer;
  bool isOffline = false;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _streamSubscription = Connectivity().onConnectivityChanged.listen((_) {
      _checkRealConnection();
    });
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkRealConnection();
    });
    AdsEventListener.start();
  }

  Future<void> _checkRealConnection() async {
    bool hasConnection = false;

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        hasConnection = false; // Tắt hẳn mạng
      } else {
        final result = await InternetAddress.lookup(
          'google.com',
        ).timeout(const Duration(seconds: 5));

        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          hasConnection = true;
        } else {
          hasConnection = false;
        }
      }
    } on SocketException catch (_) {
      hasConnection = false;
    } catch (e) {
      hasConnection = false;
    }
    if (mounted && isOffline == hasConnection) {
      setState(() {
        isOffline = !hasConnection;
      });
    }
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    _timer?.cancel();
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
  Widget build(BuildContext context) => Stack(
    children: [
      widget.child,
      if (isOffline)
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                color: Colors.transparent,
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: () {
                    _handleReCheckConnect();
                  },
                  child: Container(
                    margin: EdgeInsetsGeometry.only(
                      top: 16.h + MediaQuery.of(context).padding.top,
                      left: 16.w,
                      right: 16.w,
                    ),
                    padding: EdgeInsetsGeometry.symmetric(
                      vertical: 12.h,
                      horizontal: 16.w,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.red, width: 2.w),
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _isChecking
                                ? "Checking connection..."
                                : "Unstable connection. Tap to retry.",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        Icon(
                          _isChecking ? Icons.refresh_outlined : Icons.wifi_off,
                          color: Colors.red,
                          size: 16.w,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
    ],
  );

  Future<void> _handleReCheckConnect() async {
    setState(() {
      _isChecking = true;
    });
    await Future.delayed(Duration(seconds: 2));
    _checkRealConnection().then((value) {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    });
  }
}
