import 'package:pakeeza_pos/data/database/database_helper.dart';
import 'package:pakeeza_pos/data/models/models.dart';

class OrderRepository {
  Future<int> createOrder({
    required List<CartLine> items,
    required String paymentMethod,
    String? customerNote,
    int? userId,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final total = items.fold<int>(0, (sum, i) => sum + i.lineTotal);
    final createdAt = DateTime.now().toIso8601String();

    return db.transaction<int>((txn) async {
      final orderId = await txn.insert('orders', {
        'created_at': createdAt,
        'total': total,
        'payment_method': paymentMethod,
        'customer_note': customerNote,
        'status': 'completed',
        'user_id': userId,
      });

      for (final item in items) {
        await txn.insert('order_items', {
          'order_id': orderId,
          'product_name': item.productName,
          'variant_name': item.variantName,
          'unit_price': item.unitPrice,
          'quantity': item.quantity,
          'line_total': item.lineTotal,
        });
      }
      return orderId;
    });
  }

  String _todayStartIso() {
    final start = DateTime.now();
    return DateTime(start.year, start.month, start.day).toIso8601String();
  }

  Future<List<OrderModel>> getOrdersToday() async {
    final db = await DatabaseHelper.instance.database;
    final from = _todayStartIso();
    final rows = await db.rawQuery('''
      SELECT o.*, COUNT(oi.id) AS item_count, u.display_name AS cashier_name
      FROM orders o
      LEFT JOIN order_items oi ON oi.order_id = o.id
      LEFT JOIN users u ON u.id = o.user_id
      WHERE o.created_at >= ?
      GROUP BY o.id
      ORDER BY o.created_at DESC
    ''', [from]);
    return rows.map(OrderModel.fromMap).toList();
  }

  Future<List<OrderItemModel>> getOrderItems(int orderId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
    return rows.map(OrderItemModel.fromMap).toList();
  }

  Future<DailySummary> getDailySummary() async {
    final db = await DatabaseHelper.instance.database;
    final from = _todayStartIso();

    final summaryRows = await db.rawQuery('''
      SELECT
        COUNT(*) AS order_count,
        COALESCE(SUM(total), 0) AS total_sales,
        COALESCE(SUM(CASE WHEN payment_method = 'cash' THEN total ELSE 0 END), 0) AS cash_total,
        COALESCE(SUM(CASE WHEN payment_method = 'card' THEN total ELSE 0 END), 0) AS card_total,
        COALESCE(SUM(CASE WHEN payment_method = 'online' THEN total ELSE 0 END), 0) AS online_total
      FROM orders
      WHERE created_at >= ? AND status = 'completed'
    ''', [from]);
    final s = summaryRows.first;

    final topRows = await db.rawQuery('''
      SELECT oi.product_name, oi.variant_name,
             SUM(oi.quantity) AS qty,
             SUM(oi.line_total) AS revenue
      FROM order_items oi
      JOIN orders o ON o.id = oi.order_id
      WHERE o.created_at >= ? AND o.status = 'completed'
      GROUP BY oi.product_name, oi.variant_name
      ORDER BY qty DESC
      LIMIT 10
    ''', [from]);

    return DailySummary(
      orderCount: s['order_count'] as int,
      totalSales: s['total_sales'] as int,
      cashTotal: s['cash_total'] as int,
      cardTotal: s['card_total'] as int,
      onlineTotal: s['online_total'] as int,
      topItems: topRows
          .map(
            (r) => TopItemRow(
              productName: r['product_name'] as String,
              variantName: r['variant_name'] as String,
              qty: r['qty'] as int,
              revenue: r['revenue'] as int,
            ),
          )
          .toList(),
    );
  }
}
