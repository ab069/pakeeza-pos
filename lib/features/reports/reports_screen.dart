import 'package:flutter/material.dart';
import 'package:pakeeza_pos/core/theme/app_theme.dart';
import 'package:pakeeza_pos/core/utils/currency_format.dart';
import 'package:pakeeza_pos/data/repositories/order_repository.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _repo = OrderRepository();
  bool _loading = true;
  dynamic _summary;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final summary = await _repo.getDailySummary();
    if (mounted) {
      setState(() {
        _summary = summary;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final s = _summary;
    final dateStr = DateFormat.yMMMEd().format(DateTime.now());

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Daily report', style: Theme.of(context).textTheme.titleLarge),
              Text(dateStr, style: const TextStyle(color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 16),
          _StatCard(
            label: 'Total sales',
            value: formatPkr(s.totalSales),
            highlight: true,
          ),
          _StatCard(label: 'Orders', value: '${s.orderCount}'),
          _StatCard(label: 'Cash', value: formatPkr(s.cashTotal)),
          _StatCard(label: 'Card', value: formatPkr(s.cardTotal)),
          _StatCard(label: 'Online', value: formatPkr(s.onlineTotal)),
          const SizedBox(height: 24),
          Text(
            'Top items today',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (s.topItems.isEmpty)
            const Text(
              'No sales yet today.',
              style: TextStyle(color: AppColors.textMuted),
            )
          else
            ...s.topItems.map(
              (t) => Card(
                color: AppColors.bgCard,
                child: ListTile(
                  title: Text('${t.productName} (${t.variantName})'),
                  trailing: Text('${t.qty} sold · ${formatPkr(t.revenue)}'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: highlight ? AppColors.bgCard : AppColors.bgPanel,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(label),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: highlight ? 22 : 16,
            fontWeight: FontWeight.bold,
            color: highlight ? AppColors.goldLight : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
