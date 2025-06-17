import 'package:flutter/material.dart';

class LoadingView {
  OverlayEntry? _progressOverlayEntry;

  void show(BuildContext context, {Color? color}) {
    _progressOverlayEntry = _createdProgressEntry(context, color);
    Overlay.of(context).insert(_progressOverlayEntry!);
  }

  void hide() {
    if (_progressOverlayEntry != null) {
      _progressOverlayEntry!.remove();
      _progressOverlayEntry = null;
    }
  }

  OverlayEntry _createdProgressEntry(BuildContext context, Color? color) => OverlayEntry(
      builder: (BuildContext context) => Stack(
        children: <Widget>[
          const Opacity(
            opacity: 0.3,
            child:
            ModalBarrier(dismissible: false, color: Colors.transparent),
          ),
          Positioned(
            top: screenHeight(context) / 2 - 12,
            left: screenWidth(context) / 2 - 12,
            child: CircularProgressIndicator(
              color: color,
            ),
          )
        ],
      ));

  double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
}
