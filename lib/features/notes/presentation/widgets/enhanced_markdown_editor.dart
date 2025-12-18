import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/text_statistics.dart';

class EnhancedMarkdownEditor extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool focusMode;
  final VoidCallback? onToggleFocus;

  const EnhancedMarkdownEditor({
    super.key,
    required this.controller,
    this.onChanged,
    this.focusMode = false,
    this.onToggleFocus,
  });

  @override
  State<EnhancedMarkdownEditor> createState() => _EnhancedMarkdownEditorState();
}

class _EnhancedMarkdownEditorState extends State<EnhancedMarkdownEditor> {
  final UndoHistoryController _undoController = UndoHistoryController();
  Map<String, int> _stats = {
    'words': 0,
    'characters': 0,
    'readingTimeMinutes': 0,
  };

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateStats);
    _updateStats();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateStats);
    _undoController.dispose();
    super.dispose();
  }

  void _updateStats() {
    setState(() {
      _stats = TextStatistics.calculateStats(widget.controller.text);
    });
  }

  void _insertMarkdown(String before, String after) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;

    if (selection.isValid && !selection.isCollapsed) {
      // Format selected text
      final selectedText = text.substring(selection.start, selection.end);
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        '$before$selectedText$after',
      );

      widget.controller.text = newText;
      widget.controller.selection = TextSelection(
        baseOffset: selection.start + before.length,
        extentOffset: selection.start + before.length + selectedText.length,
      );
    } else {
      // Insert at cursor
      final cursorPos = selection.baseOffset;
      final newText =
          text.substring(0, cursorPos) +
          before +
          after +
          text.substring(cursorPos);

      widget.controller.text = newText;
      widget.controller.selection = TextSelection.collapsed(
        offset: cursorPos + before.length,
      );
    }

    widget.onChanged?.call(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toolbar (hidden in focus mode)
        if (!widget.focusMode) _buildToolbar(),

        // Editor
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: widget.controller,
              undoController: _undoController,
              onChanged: widget.onChanged,
              maxLines: null,
              expands: true,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                height: 1.6,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                hintText: widget.focusMode
                    ? 'Focus mode - press Esc to exit'
                    : 'Start writing your note in Markdown...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (_) {
                // Handle keyboard shortcuts
              },
            ),
          ),
        ),

        // Stats bar (hidden in focus mode)
        if (!widget.focusMode) _buildStatsBar(),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Undo/Redo
          IconButton(
            icon: const Icon(Icons.undo, size: 20),
            onPressed: _undoController.value.canUndo
                ? () => _undoController.undo()
                : null,
            tooltip: 'Undo (Ctrl+Z)',
          ),
          IconButton(
            icon: const Icon(Icons.redo, size: 20),
            onPressed: _undoController.value.canRedo
                ? () => _undoController.redo()
                : null,
            tooltip: 'Redo (Ctrl+Y)',
          ),

          const VerticalDivider(width: 16),

          // Formatting
          _ToolbarButton(
            icon: Icons.format_bold,
            tooltip: 'Bold (Ctrl+B)',
            onPressed: () => _insertMarkdown('**', '**'),
          ),
          _ToolbarButton(
            icon: Icons.format_italic,
            tooltip: 'Italic (Ctrl+I)',
            onPressed: () => _insertMarkdown('*', '*'),
          ),
          _ToolbarButton(
            icon: Icons.format_list_bulleted,
            tooltip: 'Bullet List',
            onPressed: () => _insertMarkdown('- ', ''),
          ),
          _ToolbarButton(
            icon: Icons.code,
            tooltip: 'Code Block',
            onPressed: () => _insertMarkdown('```\n', '\n```'),
          ),
          _ToolbarButton(
            icon: Icons.title,
            tooltip: 'Heading',
            onPressed: () => _insertMarkdown('# ', ''),
          ),
          _ToolbarButton(
            icon: Icons.format_quote,
            tooltip: 'Quote',
            onPressed: () => _insertMarkdown('> ', ''),
          ),
          _ToolbarButton(
            icon: Icons.link,
            tooltip: 'Link',
            onPressed: () => _insertMarkdown('[', '](url)'),
          ),

          const Spacer(),

          // Focus mode toggle
          IconButton(
            icon: Icon(
              widget.focusMode ? Icons.fullscreen_exit : Icons.fullscreen,
              size: 20,
            ),
            onPressed: widget.onToggleFocus,
            tooltip: 'Focus Mode (F11)',
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.1),
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${_stats['words']} words',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 16),
          Text(
            '${_stats['characters']} characters',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 16),
          Text(
            TextStatistics.formatReadingTime(_stats['readingTimeMinutes']!),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          Icon(
            Icons.auto_awesome,
            size: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          const SizedBox(width: 4),
          Text('Auto-saving', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: IconButton(
        icon: Icon(icon, size: 20),
        tooltip: tooltip,
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );
  }
}
