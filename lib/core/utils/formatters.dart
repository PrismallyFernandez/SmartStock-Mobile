import 'package:intl/intl.dart';

/// Utilidades de formato compartidas (moneda y fechas).
class Formatters {
  Formatters._();

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'es_DO',
    symbol: 'RD\$ ',
    decimalDigits: 2,
  );

  static final DateFormat _date = DateFormat('dd/MM/yyyy', 'es');
  static final DateFormat _dateTime = DateFormat('dd/MM/yyyy hh:mm a', 'es');

  static String currency(num value) => _currency.format(value);

  static String date(DateTime value) => _date.format(value);

  static String dateTime(DateTime value) => _dateTime.format(value);
}
