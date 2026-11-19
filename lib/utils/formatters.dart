import 'package:intl/intl.dart';

final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
final DateFormat _shortDateFormat = DateFormat('dd/MM');

String formatMoney(double value, {int digits = 2}) => NumberFormat.currency(
      locale: 'pt_BR',
      symbol: r'R$',
      decimalDigits: digits,
    ).format(value);

String formatNumber(double value, [int digits = 2]) =>
    NumberFormat.decimalPatternDigits(locale: 'pt_BR', decimalDigits: digits)
        .format(value);

String formatDateTime(DateTime date) => _dateTimeFormat.format(date);

String formatShortDate(DateTime date) => _shortDateFormat.format(date);

/// Converte "5,89" ou "5.89" em double. Retorna null se inválido.
double? parseNumber(String? text) {
  if (text == null) return null;
  return double.tryParse(text.trim().replaceAll(',', '.'));
}
