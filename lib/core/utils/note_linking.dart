import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class NoteLinking {
  static final RegExp _linkPattern = RegExp(r'\[\[([^\]]+)\]\]');

  static List<String> extractLinks(String content) {
    final matches = _linkPattern.allMatches(content);
    return matches.map((match) => match.group(1)!.trim()).toList();
  }

  static List<InlineSpan> buildLinkedText(
    String content,
    Map<String, String> noteIdsByTitle,
    Function(String noteId) onNoteTap,
    TextStyle? defaultStyle,
  ) {
    final spans = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in _linkPattern.allMatches(content)) {
      // Add text before the link
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: content.substring(lastEnd, match.start),
            style: defaultStyle,
          ),
        );
      }

      final linkText = match.group(1)!.trim();
      final noteId = noteIdsByTitle[linkText];
      final isValidLink = noteId != null;

      // Add the link
      spans.add(
        TextSpan(
          text: '[[${linkText}]]',
          style: defaultStyle?.copyWith(
            color: isValidLink ? Colors.blue : Colors.red,
            decoration: TextDecoration.underline,
          ),
          recognizer: isValidLink
              ? (TapGestureRecognizer()..onTap = () => onNoteTap(noteId))
              : null,
        ),
      );

      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < content.length) {
      spans.add(
        TextSpan(text: content.substring(lastEnd), style: defaultStyle),
      );
    }

    return spans;
  }

  static List<String> findBacklinks(
    String targetTitle,
    List<String> allContents,
  ) {
    final backlinks = <String>[];
    final targetPattern = RegExp(
      r'\[\[\s*' + RegExp.escape(targetTitle) + r'\s*\]\]',
    );

    for (int i = 0; i < allContents.length; i++) {
      if (targetPattern.hasMatch(allContents[i])) {
        backlinks.add(
          i.toString(),
        ); // In real implementation, this would be note IDs
      }
    }

    return backlinks;
  }
}
