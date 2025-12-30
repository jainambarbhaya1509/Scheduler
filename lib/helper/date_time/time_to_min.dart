int timeToMinutes(String time) {
  final clean = time.trim();
  final parts = clean.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}
