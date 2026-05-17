import 'package:flutter/foundation.dart';
import 'package:pakeeza_pos/data/models/models.dart';

class CartProvider extends ChangeNotifier {
  final List<CartLine> _lines = [];

  List<CartLine> get lines => List.unmodifiable(_lines);

  int get total => _lines.fold(0, (sum, l) => sum + l.lineTotal);

  int get itemCount => _lines.fold(0, (sum, l) => sum + l.quantity);

  bool get isEmpty => _lines.isEmpty;

  void addItem({
    required int productId,
    required int categoryId,
    required int variantId,
    required String productName,
    required String variantName,
    required int unitPrice,
  }) {
    final key = '$productId-$variantId';
    final existing = _lines.indexWhere((l) => l.key == key);
    if (existing >= 0) {
      _lines[existing].quantity += 1;
    } else {
      _lines.add(CartLine(
        productId: productId,
        categoryId: categoryId,
        variantId: variantId,
        productName: productName,
        variantName: variantName,
        unitPrice: unitPrice,
      ));
    }
    notifyListeners();
  }

  void increment(String key) {
    final i = _lines.indexWhere((l) => l.key == key);
    if (i >= 0) {
      _lines[i].quantity += 1;
      notifyListeners();
    }
  }

  void decrement(String key) {
    final i = _lines.indexWhere((l) => l.key == key);
    if (i < 0) return;
    if (_lines[i].quantity > 1) {
      _lines[i].quantity -= 1;
    } else {
      _lines.removeAt(i);
    }
    notifyListeners();
  }

  void remove(String key) {
    _lines.removeWhere((l) => l.key == key);
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    notifyListeners();
  }
}
