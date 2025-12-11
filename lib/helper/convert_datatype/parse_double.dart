double safeParseDouble(String? s) {
  if (s == null) return 0.0;
  final cleaned = s.trim();
  if (cleaned.isEmpty) return 0.0;
  return double.tryParse(cleaned) ?? 0.0;
}
