import 'package:flutter/material.dart';
import 'package:diff_match_patch/diff_match_patch.dart';

import '../../domain/entities/note_version.dart';

class DiffViewerScreen extends StatelessWidget {
  final String noteId;
  final NoteVersion version1;
  final NoteVersion version2;

  const DiffViewerScreen({
    super.key,
    required this.noteId,
    required this.version1,
    required this.version2,
  });

  @override
  Widget build(BuildContext context) {
    final dmp = DiffMatchPatch();
    final diffs = dmp.diff(version2.content, version1.content);
    dmp.diffCleanupSemantic(diffs);

    return Scaffold(
      appBar: AppBar(
        title: Text('Compare v${version2.version} → v${version1.version}'),
      ),
      body: Column(
        children: [
          // Legend
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            child: Row(
              children: [
                _LegendItem(
                  color: Colors.red.withOpacity(0.3),
                  label: 'Removed',
                ),
                const SizedBox(width: 16),
                _LegendItem(
                  color: Colors.green.withOpacity(0.3),
                  label: 'Added',
                ),
                const SizedBox(width: 16),
                _LegendItem(
                  color: Colors.transparent,
                  label: 'Unchanged',
                ),
              ],
            ),
          ),
          // Diff content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildDiffContent(context, diffs),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiffContent(BuildContext context, List<Diff> diffs) {
    final spans = <TextSpan>[];

    for (final diff in diffs) {
      Color? backgroundColor;
      Color? textColor;

      switch (diff.operation) {
        case DIFF_DELETE:
          backgroundColor = Colors.red.withOpacity(0.3);
          textColor = Colors.red.shade800;
          break;
        case DIFF_INSERT:
          backgroundColor = Colors.green.withOpacity(0.3);
          textColor = Colors.green.shade800;
          break;
        case DIFF_EQUAL:
          backgroundColor = null;
          textColor = Theme.of(context).textTheme.bodyMedium?.color;
          break;
      }

      spans.add(
        TextSpan(
          text: diff.text,
          style: TextStyle(
            backgroundColor: backgroundColor,
            color: textColor,
            fontFamily: 'monospace',
          ),
        ),
      );
    }

    return SelectableText.rich(
      TextSpan(children: spans),
      style: const TextStyle(fontSize: 14, height: 1.5),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}