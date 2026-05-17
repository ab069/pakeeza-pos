import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pakeeza_pos/core/theme/app_theme.dart';
import 'package:pakeeza_pos/core/utils/currency_format.dart';
import 'package:pakeeza_pos/data/models/models.dart';
import 'package:pakeeza_pos/features/pos/catalog/product_visual_catalog.dart';
import 'package:pakeeza_pos/features/pos/widgets/product_visual.dart';

Future<VariantModel?> showVariantPicker(
  BuildContext context, {
  required String productName,
  required int categoryId,
  required int productId,
  required List<VariantModel> variants,
}) {
  final style = ProductVisualCatalog.forProduct(
    categoryId: categoryId,
    productId: productId,
    productName: productName,
  );

  return showDialog<VariantModel>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.bgPanel,
      title: Text(productName, textAlign: TextAlign.center),
      content: SizedBox(
        width: 420,
        child: variants.length <= 3
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: variants
                    .asMap()
                    .entries
                    .map(
                      (e) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: _VariantTile(
                            variant: e.value,
                            style: style,
                            categoryId: categoryId,
                            productId: productId,
                            index: e.key,
                            onPick: () => Navigator.pop(ctx, e.value),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              )
            : Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: variants
                    .asMap()
                    .entries
                    .map(
                      (e) => SizedBox(
                        width: 120,
                        child: _VariantTile(
                          variant: e.value,
                          style: style,
                          categoryId: categoryId,
                          productId: productId,
                          index: e.key,
                          onPick: () => Navigator.pop(ctx, e.value),
                        ),
                      ),
                    )
                    .toList(),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}

class _VariantTile extends StatelessWidget {
  const _VariantTile({
    required this.variant,
    required this.style,
    required this.categoryId,
    required this.productId,
    required this.index,
    required this.onPick,
  });

  final VariantModel variant;
  final ProductVisualStyle style;
  final int categoryId;
  final int productId;
  final int index;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final variantStyle = ProductVisualCatalog.forVariant(
      categoryId: categoryId,
      variantName: variant.name,
      productId: productId,
    );

    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: style.isPizza ? 100 : 72,
                child: ProductVisual(
                  style: style,
                  variantStyle: variantStyle,
                  height: style.isPizza ? 100 : 72,
                  showLabel: style.isPizza,
                  animate: true,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                variant.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.goldLight,
                ),
              ),
              Text(
                formatPkr(variant.price),
                style: const TextStyle(
                  color: AppColors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 80).ms, duration: 300.ms)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          delay: (index * 80).ms,
          duration: 300.ms,
        );
  }
}
