class UserModel {
  final int id;
  final String username;
  final String displayName;
  final String role;

  const UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, Object?> map) => UserModel(
        id: map['id'] as int,
        username: map['username'] as String,
        displayName: map['display_name'] as String,
        role: map['role'] as String,
      );

  bool get isOwner => role == 'owner';
}

class CategoryModel {
  final int id;
  final String name;
  final int sortOrder;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.sortOrder,
  });

  factory CategoryModel.fromMap(Map<String, Object?> map) => CategoryModel(
        id: map['id'] as int,
        name: map['name'] as String,
        sortOrder: map['sort_order'] as int,
      );
}

class ProductModel {
  final int id;
  final int categoryId;
  final String name;
  final int sortOrder;

  const ProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.sortOrder,
  });

  factory ProductModel.fromMap(Map<String, Object?> map) => ProductModel(
        id: map['id'] as int,
        categoryId: map['category_id'] as int,
        name: map['name'] as String,
        sortOrder: map['sort_order'] as int,
      );
}

class VariantModel {
  final int id;
  final int productId;
  final String name;
  final int price;
  final int sortOrder;

  const VariantModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.sortOrder,
  });

  factory VariantModel.fromMap(Map<String, Object?> map) => VariantModel(
        id: map['id'] as int,
        productId: map['product_id'] as int,
        name: map['name'] as String,
        price: map['price'] as int,
        sortOrder: map['sort_order'] as int,
      );
}

class CartLine {
  final int productId;
  final int categoryId;
  final int variantId;
  final String productName;
  final String variantName;
  final int unitPrice;
  int quantity;

  CartLine({
    required this.productId,
    required this.categoryId,
    required this.variantId,
    required this.productName,
    required this.variantName,
    required this.unitPrice,
    this.quantity = 1,
  });

  int get lineTotal => unitPrice * quantity;

  String get key => '$productId-$variantId';

  CartLine copyWith({int? quantity}) => CartLine(
        productId: productId,
        categoryId: categoryId,
        variantId: variantId,
        productName: productName,
        variantName: variantName,
        unitPrice: unitPrice,
        quantity: quantity ?? this.quantity,
      );
}

class OrderModel {
  final int id;
  final String createdAt;
  final int total;
  final String paymentMethod;
  final String? customerNote;
  final int? itemCount;
  final String? cashierName;

  const OrderModel({
    required this.id,
    required this.createdAt,
    required this.total,
    required this.paymentMethod,
    this.customerNote,
    this.itemCount,
    this.cashierName,
  });

  factory OrderModel.fromMap(Map<String, Object?> map) => OrderModel(
        id: map['id'] as int,
        createdAt: map['created_at'] as String,
        total: map['total'] as int,
        paymentMethod: map['payment_method'] as String,
        customerNote: map['customer_note'] as String?,
        itemCount: map['item_count'] as int?,
        cashierName: map['cashier_name'] as String?,
      );
}

class OrderItemModel {
  final int id;
  final int orderId;
  final String productName;
  final String variantName;
  final int unitPrice;
  final int quantity;
  final int lineTotal;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productName,
    required this.variantName,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
  });

  factory OrderItemModel.fromMap(Map<String, Object?> map) => OrderItemModel(
        id: map['id'] as int,
        orderId: map['order_id'] as int,
        productName: map['product_name'] as String,
        variantName: map['variant_name'] as String,
        unitPrice: map['unit_price'] as int,
        quantity: map['quantity'] as int,
        lineTotal: map['line_total'] as int,
      );
}

class DailySummary {
  final int orderCount;
  final int totalSales;
  final int cashTotal;
  final int cardTotal;
  final int onlineTotal;
  final List<TopItemRow> topItems;

  const DailySummary({
    required this.orderCount,
    required this.totalSales,
    required this.cashTotal,
    required this.cardTotal,
    required this.onlineTotal,
    required this.topItems,
  });
}

class TopItemRow {
  final String productName;
  final String variantName;
  final int qty;
  final int revenue;

  const TopItemRow({
    required this.productName,
    required this.variantName,
    required this.qty,
    required this.revenue,
  });
}
