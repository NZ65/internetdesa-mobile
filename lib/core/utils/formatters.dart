import 'package:intl/intl.dart';

class Formatters {
  static String formatRupiah(dynamic amount) {
    final num val = (amount is num) ? amount : (num.tryParse(amount?.toString() ?? '0') ?? 0);
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(val);
  }

  static String formatCurrency(dynamic amount) => formatRupiah(amount);
  static String formatDateTime(String? dateStr) => formatDate(dateStr);

  static String formatCompactRupiah(dynamic amount) {
    final num val = (amount is num) ? amount : (num.tryParse(amount?.toString() ?? '0') ?? 0);
    if (val >= 1000000000) {
      return 'Rp ${(val / 1000000000).toStringAsFixed(1)} M';
    } else if (val >= 1000000) {
      return 'Rp ${(val / 1000000).toStringAsFixed(1)} Jt';
    } else if (val >= 1000) {
      return 'Rp ${(val / 1000).toStringAsFixed(0)} Rb';
    }
    return 'Rp $val';
  }

  static String formatBytes(dynamic bytes) {
    final num val = (bytes is num) ? bytes : (num.tryParse(bytes?.toString() ?? '0') ?? 0);
    if (val <= 0) return '0 B';
    if (val >= 1073741824) return '${(val / 1073741824).toStringAsFixed(2)} GB';
    if (val >= 1048576) return '${(val / 1048576).toStringAsFixed(1)} MB';
    if (val >= 1024) return '${(val / 1024).toStringAsFixed(0)} KB';
    return '$val B';
  }

  static String formatBps(dynamic bps) {
    final num val = (bps is num) ? bps : (num.tryParse(bps?.toString() ?? '0') ?? 0);
    if (val <= 0) return '0 bps';
    if (val >= 1000000000) return '${(val / 1000000000).toStringAsFixed(2)} Gbps';
    if (val >= 1000000) return '${(val / 1000000).toStringAsFixed(2)} Mbps';
    if (val >= 1000) return '${(val / 1000).toStringAsFixed(1)} Kbps';
    return '$val bps';
  }

  static String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  static String formatShortDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return dateStr;
    }
  }
}
