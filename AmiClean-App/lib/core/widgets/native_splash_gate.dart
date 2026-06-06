import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

/// Drži native splash vidljivim najmanje [minDuration], pa prikazuje [child].
class NativeSplashGate extends StatefulWidget {
  const NativeSplashGate({
    super.key,
    required this.child,
    required this.startedAt,
    this.minDuration = const Duration(seconds: 2),
  });

  final Widget child;
  final DateTime startedAt;
  final Duration minDuration;

  @override
  State<NativeSplashGate> createState() => _NativeSplashGateState();
}

class _NativeSplashGateState extends State<NativeSplashGate> {
  @override
  void initState() {
    super.initState();
    _dismissNativeSplash();
  }

  Future<void> _dismissNativeSplash() async {
    final elapsed = DateTime.now().difference(widget.startedAt);
    if (elapsed < widget.minDuration) {
      await Future<void>.delayed(widget.minDuration - elapsed);
    }
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
