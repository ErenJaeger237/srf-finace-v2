import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final double borderOpacity;
  final EdgeInsetsGeometry? padding;
  final bool showBlur;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 24.0,
    this.borderOpacity = 0.08,
    this.padding,
    this.showBlur = true,
  });

  @override
  Widget build(BuildContext context) {
    // Disable blur for troubleshooting
    const bool effectiveShowBlur = false;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E), // Solid surface fallback
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: borderOpacity),
              width: 1.0,
            ),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
