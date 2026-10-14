/// Helper parsing JSON yang toleran: PHP/MySQL kadang mengirim angka sebagai string
/// (mis. DECIMAL "145000.00").
int parseInt(dynamic v, {int fallback = 0}) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is bool) return v ? 1 : 0;
  final s = v.toString().trim();
  return int.tryParse(s) ?? double.tryParse(s)?.toInt() ?? fallback;
}

int? parseIntOrNull(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  final s = v.toString().trim();
  return int.tryParse(s) ?? double.tryParse(s)?.toInt();
}

double parseDouble(dynamic v, {double fallback = 0}) {
  if (v == null) return fallback;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString().trim()) ?? fallback;
}

bool parseBool(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v.toString().trim().toLowerCase();
  return s == '1' || s == 'true' || s == 'yes';
}

String? parseStringOrNull(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  return s.trim().isEmpty ? null : s;
}

DateTime? parseDate(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString().replaceFirst(' ', 'T'));
}
