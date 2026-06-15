class TextSanitizer {
  /// Sanitizes string fetched from external APIs by:
  /// 1. Replacing `<br>` or `<br/>` tags with newlines (`\n`).
  /// 2. Removing any other HTML/XML tags.
  /// 3. Decoding common HTML/XML entities.
  /// 4. Normalizing consecutive spaces and newlines, and trimming each line.
  static String sanitize(String input) {
    if (input.isEmpty) return '';

    // 1. Convert <br>, <br/>, <br /> tags to newlines
    var clean = input.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');

    // 2. Remove all other HTML/XML tags
    clean = clean.replaceAll(RegExp(r'<[^>]*>'), '');

    // 3. Replace common HTML/XML entities
    clean = clean
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ');

    // 4. Process line-by-line to trim spaces and collapse spaces/tabs
    final lines = clean.split('\n');
    final processedLines = lines.map((line) {
      return line.replaceAll(RegExp(r'[ \t]+'), ' ').trim();
    }).toList();

    // 5. Join back and collapse multiple newlines (3 or more) to max 2 newlines
    var result = processedLines.join('\n');
    result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return result.trim();
  }
}
