// lib/widgets/app_logo.dart
// Description: App logo widget — graduation cap icon + "Attendance System" text.

import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;

  const AppLogo({
    super.key,
    this.iconSize = 72,
    this.fontSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Modern icon with gradient-like circular background
        Container(
          width: iconSize * 1.5,
          height: iconSize * 1.5,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A237E).withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Icon(
            Icons.sensors_rounded,
            size: iconSize * 0.8,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Presence',
          style: TextStyle(
            fontSize: fontSize * 1.2,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1A237E),
            letterSpacing: -0.5,
          ),
        ),
        Text(
          'BY ILYASS MOKHTATIF',
          style: TextStyle(
            fontSize: fontSize * 0.4,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF00B8D4),
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }
}
