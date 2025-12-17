import 'package:flutter/material.dart';

class MarkdownEditor extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const MarkdownEditor({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _ToolbarButton(
                  icon: Icons.format_bold,
                  tooltip: 'Bold',
                  onPressed: () => _insertMarkdown('**', '**'),
                ),
                _ToolbarButton(
                  icon: Icons.format_italic,
                  tooltip: 'Italic',
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
              ],
            ),
          ),
        ),
        // Text editor
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: null,
            expands: true,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
            ),
            decoration: const InputDecoration(
              hintText: 'Start writing your note in Markdown...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  void _insertMarkdown(String before, String after) {
    final text = controller.text;
    final selection = controller.selection;
    
    if (selection.isValid) {
      final selectedText = text.substring(selection.start, selection.end);
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        '$before$selectedText$after',
      );
      
      controller.text = newText;
      controller.selection = TextSelection.collapsed(
        offset: selection.start + before.length + selectedText.length + after.length,
      );
    } else {
      final newText = text + before + after;
      controller.text = newText;
      controller.selection = TextSelection.collapsed(
        offset: newText.length - after.length,
      );
    }
    
    onChanged?.call(controller.text);
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
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
      ),
    );
  }
}