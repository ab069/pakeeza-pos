import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pakeeza_pos/features/pos/catalog/product_visual_catalog.dart';
import 'package:pakeeza_pos/features/pos/widgets/pizza_box_visual.dart';

class ProductVisual extends StatelessWidget {
  const ProductVisual({
    super.key,
    required this.style,
    this.variantStyle,
    this.height = 72,
    this.showLabel = false,
    this.animate = true,
  });

  final ProductVisualStyle style;
  final VariantVisualStyle? variantStyle;
  final double height;
  final bool showLabel;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    if (style.assetPath != null) {
      return _assetImage(style.assetPath!, height, _buildIllustration);
    }

    return _buildIllustration();
  }

  Widget _buildIllustration() {
    if (style.isPizza) {
      final vs = variantStyle;
      return PizzaBoxVisual(
        scale: vs?.boxScale ?? 0.78,
        label: showLabel ? vs?.label : null,
        compact: height < 70,
        animate: animate,
      );
    }

    return _emojiVisual();
  }

  Widget _assetImage(String path, double h, Widget Function() fallback) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        path,
        height: h,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback(),
      ),
    );
  }

  Widget _emojiVisual() {
    Widget child = Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: style.gradient,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        style.emoji,
        style: TextStyle(fontSize: height * 0.55),
      ),
    );

    if (animate) {
      child = child
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(0.96, 0.96),
            end: const Offset(1.04, 1.04),
            duration: 2000.ms,
            curve: Curves.easeInOut,
          );
    }

    return child;
  }
}
