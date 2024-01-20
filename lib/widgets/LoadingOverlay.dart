import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
