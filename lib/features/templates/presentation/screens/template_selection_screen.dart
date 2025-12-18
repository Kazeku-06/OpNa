import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/built_in_templates.dart';
import '../../../notes/presentation/providers/notes_provider.dart';
import '../../../notes/presentation/screens/simple_note_editor_screen.dart';

class TemplateSelectionScreen extends ConsumerWidget {
  const TemplateSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = BuiltInTemplates.getBuiltInTemplates();

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Template')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: templates.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.note_add),
                title: const Text('Blank Note'),
                subtitle: const Text('Start with an empty note'),
                onTap: () => _createBlankNote(context, ref),
              ),
            );
          }

          final template = templates[index - 1];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.note),
              title: Text(template.name),
              subtitle: Text('Template: ${template.name}'),
              onTap: () => _createNoteFromTemplate(context, ref, template),
            ),
          );
        },
      ),
    );
  }

  Future<void> _createBlankNote(BuildContext context, WidgetRef ref) async {
    try {
      final note = await ref.read(notesProvider.notifier).createNote();
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SimpleNoteEditorScreen(noteId: note.id),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create note: $error')),
        );
      }
    }
  }

  Future<void> _createNoteFromTemplate(
    BuildContext context,
    WidgetRef ref,
    template,
  ) async {
    try {
      final processedContent = BuiltInTemplates.processTemplate(
        template.content,
      );
      final note = await ref
          .read(notesProvider.notifier)
          .createNote(title: template.name);

      final repository = ref.read(notesRepositoryProvider);
      await repository.saveNoteContent(note.id, processedContent);

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SimpleNoteEditorScreen(noteId: note.id),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create note from template: $error'),
          ),
        );
      }
    }
  }
}
