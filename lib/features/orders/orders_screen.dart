import 'package:flutter/material.dart';
import 'package:pakeeza_pos/core/theme/app_theme.dart';
import 'package:pakeeza_pos/core/utils/currency_format.dart';
import 'package:pakeeza_pos/data/models/models.dart';
import 'package:pakeeza_pos/data/repositories/order_repository.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _repo = OrderRepository();
  List<OrderModel> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final orders = await _repo.getOrdersToday();
    if (mounted) {
      setState(() {
        _orders = orders;
        _loading = false;
      });
    }
  }

  Future<void> _showDetail(OrderModel order) async {
    final items = await _repo.getOrderItems(order.id);
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgPanel,
        title: Text('Order #${order.id}'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total: ${formatPkr(order.total)}'),
              Text('Payment: ${order.paymentMethod}'),
              if (order.cashierName != null)
                Text('Cashier: ${order.cashierName}'),
              const Divider(),
              ...items.map(
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '${i.quantity}× ${i.productName} (${i.variantName}) — ${formatPkr(i.lineTotal)}',
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No orders today yet',
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _load, child: const Text('Refresh')),
          ],
        ),
      );
    }

    final timeFmt = DateFormat.jm();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's orders (${_orders.length})",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              OutlinedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _orders.length,
            itemBuilder: (_, i) {
              final o = _orders[i];
              final time = DateTime.tryParse(o.createdAt);
              return Card(
                color: AppColors.bgCard,
                child: ListTile(
                  title: Text('Order #${o.id} — ${formatPkr(o.total)}'),
                  subtitle: Text(
                    '${time != null ? timeFmt.format(time) : o.createdAt} · '
                    '${o.paymentMethod} · ${o.itemCount ?? 0} items'
                    '${o.cashierName != null ? ' · ${o.cashierName}' : ''}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showDetail(o),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
