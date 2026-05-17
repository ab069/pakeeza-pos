import 'package:intl/intl.dart';

final _pkFormatter = NumberFormat.currency(
  locale: 'en_PK',
  symbol: 'Rs ',
  decimalDigits: 0,
);

String formatPkr(int amount) => _pkFormatter.format(amount);
