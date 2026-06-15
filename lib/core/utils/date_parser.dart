DateTime? parseRfc822(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return null;

  var cleaned = dateStr.trim();

  // 1. Try standard ISO-8601 parsing first
  final parsed = DateTime.tryParse(cleaned);
  if (parsed != null) return parsed;

  // 2. Manual RFC-822 / RFC-1123 parsing (GMT/UTC offsets and names)
  // Remove day of week prefix if present (e.g. "Wed, ")
  if (cleaned.contains(', ')) {
    cleaned = cleaned.split(', ').last;
  }

  final parts = cleaned.split(RegExp(r'\s+'));
  if (parts.length >= 4) {
    final day = int.tryParse(parts[0]);
    final monthStr = parts[1];
    final year = int.tryParse(parts[2]);
    final timeParts = parts[3].split(':');

    if (day != null && year != null && timeParts.length >= 3) {
      final hour = int.tryParse(timeParts[0]);
      final minute = int.tryParse(timeParts[1]);
      final second = int.tryParse(timeParts[2]);

      final months = {
        'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
        'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12
      };

      if (monthStr.length >= 3) {
        final month = months[monthStr.toLowerCase().substring(0, 3)];
        if (month != null && hour != null && minute != null && second != null) {
          var offsetDuration = Duration.zero;
          if (parts.length >= 5) {
            final tz = parts[4];
            if (tz.startsWith('+') || tz.startsWith('-')) {
              final sign = tz.startsWith('+') ? 1 : -1;
              final offsetStr = tz.substring(1);
              if (offsetStr.length == 4) {
                final hours = int.tryParse(offsetStr.substring(0, 2)) ?? 0;
                final minutes = int.tryParse(offsetStr.substring(2, 4)) ?? 0;
                offsetDuration = Duration(hours: hours, minutes: minutes) * sign;
              }
            }
          }

          final utcTime = DateTime.utc(year, month, day, hour, minute, second);
          return utcTime.subtract(offsetDuration).toLocal();
        }
      }
    }
  }

  return null;
}
