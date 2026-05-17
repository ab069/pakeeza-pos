import 'package:flutter/material.dart';

/// Visual style for menu items. Supports optional image assets — see [docs/PRODUCT_IMAGES.md].
class ProductVisualStyle {
  final String emoji;
  final List<Color> gradient;
  final bool isPizza;
  final String? assetPath;

  const ProductVisualStyle({
    required this.emoji,
    required this.gradient,
    this.isPizza = false,
    this.assetPath,
  });
}

class VariantVisualStyle {
  final double boxScale;
  final String label;
  final String? assetPath;

  const VariantVisualStyle({
    required this.boxScale,
    required this.label,
    this.assetPath,
  });
}

class ProductVisualCatalog {
  ProductVisualCatalog._();

  static const _pizzaGradient = [
    Color(0xFF8B2500),
    Color(0xFFE85D04),
    Color(0xFFD4A017),
  ];

  static ProductVisualStyle forCategory(int categoryId) {
    return switch (categoryId) {
      1 || 2 || 3 => const ProductVisualStyle(
          emoji: '🍕',
          gradient: _pizzaGradient,
          isPizza: true,
        ),
      4 => const ProductVisualStyle(
          emoji: '🍔',
          gradient: [Color(0xFF5C3D1E), Color(0xFFE85D04)],
        ),
      5 => const ProductVisualStyle(
          emoji: '🌯',
          gradient: [Color(0xFF6B4423), Color(0xFFD4A017)],
        ),
      6 => const ProductVisualStyle(
          emoji: '🍗',
          gradient: [Color(0xFF8B4513), Color(0xFFE85D04)],
        ),
      7 => const ProductVisualStyle(
          emoji: '🍟',
          gradient: [Color(0xFF4A3728), Color(0xFFD4A017)],
        ),
      8 => const ProductVisualStyle(
          emoji: '🥟',
          gradient: [Color(0xFF3D3D3D), Color(0xFF8B7500)],
        ),
      _ => const ProductVisualStyle(
          emoji: '🍽️',
          gradient: [Color(0xFF242424), Color(0xFF444444)],
        ),
    };
  }

  static ProductVisualStyle forProduct({
    required int categoryId,
    required int productId,
    required String productName,
  }) {
    final base = forCategory(categoryId);
    return ProductVisualStyle(
      emoji: base.emoji,
      gradient: base.gradient,
      isPizza: base.isPizza,
      assetPath: 'assets/images/products/c${categoryId}_p$productId.png',
    );
  }

  static VariantVisualStyle forVariant({
    required int categoryId,
    required String variantName,
    required int productId,
  }) {
    final lower = variantName.toLowerCase();
    final scale = switch (lower) {
      'small' => 0.62,
      'medium' => 0.82,
      'large' => 1.0,
      'regular' => 0.75,
      _ => 0.7,
    };

    return VariantVisualStyle(
      boxScale: scale,
      label: variantName,
      assetPath:
          'assets/images/products/c${categoryId}_p${productId}_$lower.png',
    );
  }

  static String categoryEmoji(int categoryId) =>
      forCategory(categoryId).emoji;

  static String? categoryAsset(int categoryId) =>
      'assets/images/categories/cat_$categoryId.png';
}
