import 'package:flutter/material.dart';

class BottomWavyClipper extends CustomClipper<Path>{
  @override
  getClip(Size size) {
    Path path = Path();

    path.lineTo(0, 0);
    path.lineTo(0, size.height - 20);

    path.quadraticBezierTo(
      size.width / 4, size.height, // Control point and endpoint for the first curve
      size.width / 2, size.height - 15, // The peak of the wave
    );

    path.quadraticBezierTo(
      size.width * 3 / 4, size.height - 30, // Second wave curve
      size.width, size.height - 20, // Bottom-right curve
    );
    // path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return false;
  }

}