import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pakeeza_pos/core/theme/app_theme.dart';

/// Animated pizza-in-box illustration (scales for Small / Medium / Large).
class PizzaBoxVisual extends StatelessWidget {
  const PizzaBoxVisual({
    super.key,
    required this.scale,
    this.label,
    this.compact = false,
    this.animate = true,
  });

  final double scale;
  final String? label;
  final bool compact;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final base = compact ? 56.0 : 88.0;
        var size = base * scale.clamp(0.55, 1.0);
        final maxH = constraints.maxHeight;
        final bounded = maxH.isFinite && maxH > 0;
        final showLabel =
            label != null && label!.isNotEmpty && (!bounded || maxH > 62);

        if (bounded) {
          final labelSpace = showLabel ? (compact ? 26.0 : 34.0) : 0;
          final maxVisualH = maxH - labelSpace;
          if (size * 1.05 > maxVisualH) {
            size = (maxVisualH / 1.05).clamp(32.0, base);
          }
        }

        Widget visual = CustomPaint(
          size: Size(size * 1.15, size),
          painter: _PizzaBoxPainter(scale: scale),
        );

        if (animate) {
          visual = visual
              .animate(onPlay: (c) => c.repeat())
              .shimmer(
                duration: 2200.ms,
                color: AppColors.goldLight.withValues(alpha: 0.25),
              )
              .then()
              .moveY(
                begin: -2,
                end: 2,
                duration: 1800.ms,
                curve: Curves.easeInOut,
              )
              .then()
              .moveY(
                begin: 2,
                end: -2,
                duration: 1800.ms,
                curve: Curves.easeInOut,
              );
        }

        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: size * 1.2, height: size * 1.05, child: visual),
              if (showLabel) ...[
                SizedBox(height: compact ? 4 : 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    label!,
                    style: TextStyle(
                      fontSize: compact ? 10 : 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.goldLight,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PizzaBoxPainter extends CustomPainter {
  _PizzaBoxPainter({required this.scale});

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final boxW = w * 0.92;
    final boxH = h * 0.55;
    final boxLeft = (w - boxW) / 2;
    final boxTop = h - boxH - 4;

    final boxPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFD4A574),
          const Color(0xFF8B5A2B),
          const Color(0xFF5C3D1E),
        ],
      ).createShader(Rect.fromLTWH(boxLeft, boxTop, boxW, boxH));

    final boxRrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(boxLeft, boxTop, boxW, boxH),
      const Radius.circular(6),
    );
    canvas.drawRRect(boxRrect, boxPaint);

    canvas.drawRRect(
      boxRrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = AppColors.gold.withValues(alpha: 0.6),
    );

    final lidH = boxH * 0.35;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(boxLeft, boxTop - lidH * 0.35, boxW, lidH),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFFA67C52),
    );

    final pizzaR = (boxW * 0.38) * (0.85 + scale * 0.15);
    final cx = w / 2;
    final cy = boxTop - pizzaR * 0.15;

    canvas.drawCircle(
      Offset(cx, cy),
      pizzaR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFE4B5),
            const Color(0xFFE85D04),
            const Color(0xFFB33A00),
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: pizzaR)),
    );

    final cheese = Paint()..color = const Color(0xFFFFD700).withValues(alpha: 0.7);
    for (var i = 0; i < 5; i++) {
      final angle = i * math.pi * 2 / 5 - math.pi / 2;
      canvas.drawCircle(
        Offset(cx + math.cos(angle) * pizzaR * 0.45, cy + math.sin(angle) * pizzaR * 0.45),
        pizzaR * 0.1,
        cheese,
      );
    }

    if (scale >= 0.95) {
      final steamPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      for (var i = -1; i <= 1; i++) {
        final sx = cx + i * 12.0;
        canvas.drawArc(
          Rect.fromCenter(center: Offset(sx, cy - pizzaR - 8), width: 10, height: 14),
          math.pi * 0.2,
          math.pi * 0.6,
          false,
          steamPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PizzaBoxPainter old) => old.scale != scale;
}
