import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownPreview extends StatelessWidget {
  final String content;

  const MarkdownPreview({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    if (content.trim().isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.preview, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Preview will appear here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Markdown(
        data: content,
        selectable: true,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          p: Theme.of(context).textTheme.bodyMedium,
          h1: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          h2: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          h3: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          code: TextStyle(
            fontFamily: 'monospace',
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          codeblockDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          blockquoteDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
            border: Border(
              left: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}