import 'package:flutter/material.dart';
import 'package:pakeeza_pos/core/constants/app_constants.dart';
import 'package:pakeeza_pos/core/theme/app_theme.dart';
import 'package:pakeeza_pos/core/utils/currency_format.dart';
import 'package:pakeeza_pos/data/models/models.dart';
import 'package:pakeeza_pos/data/repositories/menu_repository.dart';
import 'package:pakeeza_pos/data/repositories/order_repository.dart';
import 'package:pakeeza_pos/features/pos/catalog/product_visual_catalog.dart';
import 'package:pakeeza_pos/features/pos/widgets/product_card.dart';
import 'package:pakeeza_pos/features/pos/widgets/product_visual.dart';
import 'package:pakeeza_pos/features/pos/widgets/variant_picker_dialog.dart';
import 'package:pakeeza_pos/providers/auth_provider.dart';
import 'package:pakeeza_pos/providers/cart_provider.dart';
import 'package:pakeeza_pos/services/printer_service.dart';
import 'package:provider/provider.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final _menuRepo = MenuRepository();
  final _orderRepo = OrderRepository();

  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  CategoryModel? _selectedCategory;
  bool _loadingMenu = true;
  String _payment = AppConstants.paymentCash;
  final _noteController = TextEditingController();
  bool _checkingOut = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final cats = await _menuRepo.getCategories();
    if (!mounted) return;
    setState(() {
      _categories = cats;
      _loadingMenu = false;
      if (cats.isNotEmpty) {
        _selectedCategory = cats.first;
      }
    });
    if (cats.isNotEmpty) await _loadProducts(cats.first.id);
  }

  Future<void> _loadProducts(int categoryId) async {
    final products = await _menuRepo.getProducts(categoryId);
    if (!mounted) return;
    setState(() => _products = products);
  }

  Future<void> _onCategoryTap(CategoryModel cat) async {
    setState(() {
      _selectedCategory = cat;
      _products = [];
    });
    await _loadProducts(cat.id);
  }

  Future<void> _onProductTap(ProductModel product) async {
    final variants = await _menuRepo.getVariants(product.id);
    if (!mounted) return;

    VariantModel selected;
    if (variants.length == 1) {
      selected = variants.first;
    } else {
      final picked = await showVariantPicker(
        context,
        productName: product.name,
        categoryId: product.categoryId,
        productId: product.id,
        variants: variants,
      );
      if (picked == null) return;
      selected = picked;
    }

    if (!mounted) return;
    context.read<CartProvider>().addItem(
          productId: product.id,
          categoryId: product.categoryId,
          variantId: selected.id,
          productName: product.name,
          variantName: selected.name,
          unitPrice: selected.price,
        );
  }

  Future<void> _checkout() async {
    final cart = context.read<CartProvider>();
    if (cart.isEmpty) return;

    setState(() => _checkingOut = true);
    try {
      final userId = context.read<AuthProvider>().user?.id;
      final orderId = await _orderRepo.createOrder(
        items: cart.lines,
        paymentMethod: _payment,
        customerNote: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        userId: userId,
      );

      await PrinterService.instance.printReceipt(
        shopSettings: {},
        orderId: orderId,
        lines: [],
        total: cart.total,
        paymentMethod: _payment,
      );

      if (!mounted) return;
      final totalPaid = cart.total;
      cart.clear();
      _noteController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order #$orderId completed — ${formatPkr(totalPaid)}'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _checkingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Row(
      children: [
        SizedBox(
          width: 200,
          child: _loadingMenu
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _categories.length,
                  itemBuilder: (_, i) {
                    final cat = _categories[i];
                    final selected = _selectedCategory?.id == cat.id;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Material(
                        color: selected
                            ? AppColors.orange
                            : AppColors.bgCard,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () => _onCategoryTap(cat),
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Text(
                                  ProductVisualCatalog.categoryEmoji(cat.id),
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    cat.name,
                                    style: TextStyle(
                                      fontWeight: selected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        const VerticalDivider(width: 1, color: AppColors.border),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.82,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _products.length,
            itemBuilder: (_, i) {
              final p = _products[i];
              final catId = _selectedCategory?.id ?? p.categoryId;
              return ProductCard(
                product: p,
                categoryId: catId,
                onTap: () => _onProductTap(p),
              );
            },
          ),
        ),
        Container(
          width: 320,
          color: AppColors.bgPanel,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cart (${cart.itemCount})',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: cart.isEmpty ? null : () => cart.clear(),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: cart.isEmpty
                    ? const Center(
                        child: Text(
                          'Tap items to add',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      )
                    : ListView.builder(
                        itemCount: cart.lines.length,
                        itemBuilder: (_, i) {
                          final line = cart.lines[i];
                          return ListTile(
                            dense: true,
                            leading: SizedBox(
                              width: 44,
                              height: 44,
                              child: ProductVisual(
                                style: ProductVisualCatalog.forProduct(
                                  categoryId: line.categoryId,
                                  productId: line.productId,
                                  productName: line.productName,
                                ),
                                variantStyle:
                                    ProductVisualCatalog.forVariant(
                                  categoryId: line.categoryId,
                                  variantName: line.variantName,
                                  productId: line.productId,
                                ),
                                height: 44,
                                animate: false,
                              ),
                            ),
                            title: Text(
                              line.productName,
                              style: const TextStyle(fontSize: 14),
                            ),
                            subtitle: Text(
                              '${line.variantName} × ${formatPkr(line.unitPrice)}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => cart.decrement(line.key),
                                ),
                                Text('${line.quantity}'),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => cart.increment(line.key),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const Divider(color: AppColors.border),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    isDense: true,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: AppConstants.paymentCash,
                      label: Text('Cash'),
                    ),
                    ButtonSegment(
                      value: AppConstants.paymentCard,
                      label: Text('Card'),
                    ),
                    ButtonSegment(
                      value: AppConstants.paymentOnline,
                      label: Text('Online'),
                    ),
                  ],
                  selected: {_payment},
                  onSelectionChanged: (s) =>
                      setState(() => _payment = s.first),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      formatPkr(cart.total),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.goldLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: cart.isEmpty || _checkingOut
                            ? null
                            : _checkout,
                        child: _checkingOut
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Complete order'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
