import 'package:flutter/material.dart';
import 'package:infantique/widgets/LoadingOverlay.dart';

class LoadingManager {
  static LoadingManager? _instance;

  factory LoadingManager() {
    _instance ??= LoadingManager._();
    return _instance!;
  }

  LoadingManager._();

  OverlayEntry? _overlayEntry;

  void showLoading(BuildContext context) {
    _overlayEntry = OverlayEntry(
      builder: (context) => LoadingOverlay(),
    );

    Overlay.of(context)?.insert(_overlayEntry!);
  }

  void hideLoading() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
