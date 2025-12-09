import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

/// GlassContainer is a reusable frosted-glass surface used across the UI.
///
/// It applies:
/// - Rounded clipping
/// - Backdrop blur (sigma ≈ 16)
/// - Soft translucent gradient
/// - Subtle white border
/// - Gentle drop shadow for depth
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double blurSigma;
  final Color? tintColor;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.blurSigma = 16,
    this.tintColor,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(24);
    final baseTint = tintColor ?? const Color(0xFF0F172A); // deep blue-grey
    final r = (baseTint.r * 255.0).round().clamp(0, 255);
    final g = (baseTint.g * 255.0).round().clamp(0, 255);
    final b = (baseTint.b * 255.0).round().clamp(0, 255);

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromRGBO(r, g, b, 0.20),
                  Color.fromRGBO(r, g, b, 0.10),
                  const Color.fromRGBO(255, 255, 255, 0.05),
                ],
              ),
              borderRadius: radius,
              border: Border.all(
                color: const Color.fromRGBO(255, 255, 255, 0.14),
                width: 1.1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.35),
                  blurRadius: 26,
                  offset: Offset(0, 18),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// AnimatedLiquidBackground renders 2–3 softly animated organic blobs behind the UI.
///
/// It is intended to sit at the bottom of a [Stack] so all content appears above
/// the animated liquid layer.
class AnimatedLiquidBackground extends StatefulWidget {
  const AnimatedLiquidBackground({super.key});

  @override
  State<AnimatedLiquidBackground> createState() => _AnimatedLiquidBackgroundState();
}

class _AnimatedLiquidBackgroundState extends State<AnimatedLiquidBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _LiquidPainter(progress: _controller.value),
            size: MediaQuery.of(context).size,
          );
        },
      ),
    );
  }
}

class _LiquidPainter extends CustomPainter {
  final double progress; // 0..1

  _LiquidPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height * 0.6;

    // Helper to create a smooth blob path using quadratic Bézier curves.
    Path buildBlob(Offset center, double baseRadius, double phase) {
      final segments = 32; // high enough for smooth edge
      final path = Path();
      for (int i = 0; i <= segments; i++) {
        final t = i / segments;
        final angle = t * 2 * math.pi;
        final wobble = math.sin(progress * 2 * math.pi + angle + phase) * 4;
        final r = baseRadius + wobble;
        final point = Offset(
          center.dx + r * math.cos(angle),
          center.dy + r * math.sin(angle),
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      return path;
    }

    final paint1 = Paint()
      ..color = const Color.fromRGBO(34, 211, 238, 0.18)
      ..style = PaintingStyle.fill;
    final paint2 = Paint()
      ..color = const Color.fromRGBO(56, 189, 248, 0.16)
      ..style = PaintingStyle.fill;
    final paint3 = Paint()
      ..color = const Color.fromRGBO(79, 70, 229, 0.14)
      ..style = PaintingStyle.fill;

    final blob1 = buildBlob(
      Offset(size.width * 0.15 + math.sin(progress * 2 * math.pi) * 30, centerY),
      size.width * 0.32,
      0,
    );
    final blob2 = buildBlob(
      Offset(size.width * 0.6 + math.sin(progress * 2 * math.pi + 1.4) * 40, centerY - 60),
      size.width * 0.28,
      1.1,
    );
    final blob3 = buildBlob(
      Offset(size.width * 0.9 + math.sin(progress * 2 * math.pi + 2.2) * 30, centerY + 40),
      size.width * 0.24,
      2.2,
    );

    canvas.drawPath(blob1, paint1);
    canvas.drawPath(blob2, paint2);
    canvas.drawPath(blob3, paint3);
  }

  @override
  bool shouldRepaint(covariant _LiquidPainter oldDelegate) =>
      !identical(progress, oldDelegate.progress);
}
