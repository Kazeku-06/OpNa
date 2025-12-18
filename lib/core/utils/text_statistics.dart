class TextStatistics {
  static Map<String, int> calculateStats(String text) {
    final words = text.trim().split(RegExp(r'\s+'));
    final wordCount = text.trim().isEmpty ? 0 : words.length;
    final charCount = text.length;
    final charCountNoSpaces = text.replaceAll(RegExp(r'\s'), '').length;

    // Reading time: average 200 words per minute
    final readingTimeMinutes = (wordCount / 200).ceil();

    return {
      'words': wordCount,
      'characters': charCount,
      'charactersNoSpaces': charCountNoSpaces,
      'readingTimeMinutes': readingTimeMinutes,
    };
  }

  static String formatReadingTime(int minutes) {
    if (minutes == 0) return 'Less than 1 min read';
    if (minutes == 1) return '1 min read';
    return '$minutes min read';
  }
}
