import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pakeeza_pos/core/theme/app_theme.dart';
import 'package:pakeeza_pos/data/models/models.dart';
import 'package:pakeeza_pos/features/pos/catalog/product_visual_catalog.dart';
import 'package:pakeeza_pos/features/pos/widgets/product_visual.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.categoryId,
    required this.onTap,
  });

  final ProductModel product;
  final int categoryId;
  final VoidCallback onTap;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final style = ProductVisualCatalog.forProduct(
      categoryId: widget.categoryId,
      productId: widget.product.id,
      productName: widget.product.name,
    );

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        child: Material(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return ProductVisual(
                        style: style,
                        height: constraints.maxHeight,
                        animate: !_pressed,
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                child: Text(
                  widget.product.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 280.ms, delay: (widget.product.sortOrder * 40).ms)
        .slideY(begin: 0.08, end: 0, duration: 280.ms);
  }
}
