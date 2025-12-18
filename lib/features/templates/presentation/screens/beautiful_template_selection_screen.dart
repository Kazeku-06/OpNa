import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/built_in_templates.dart';
import '../../../notes/presentation/providers/notes_provider.dart';
import '../../../notes/presentation/screens/simple_note_editor_screen.dart';

class BeautifulTemplateSelectionScreen extends ConsumerStatefulWidget {
  const BeautifulTemplateSelectionScreen({super.key});

  @override
  ConsumerState<BeautifulTemplateSelectionScreen> createState() =>
      _BeautifulTemplateSelectionScreenState();
}

class _BeautifulTemplateSelectionScreenState
    extends ConsumerState<BeautifulTemplateSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templates = BuiltInTemplates.getBuiltInTemplates();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Choose Template',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      (index * 0.1).clamp(0.0, 1.0),
                      ((index * 0.1) + 0.4).clamp(0.0, 1.0),
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                );

                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - animation.value)),
                      child: Opacity(
                        opacity: animation.value,
                        child: index == 0
                            ? _buildBlankNoteCard(context, ref)
                            : _buildTemplateCard(
                                context,
                                ref,
                                templates[index - 1],
                              ),
                      ),
                    );
                  },
                );
              }, childCount: templates.length + 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlankNoteCard(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _createBlankNote(context, ref),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.note_add_rounded,
                    size: 36,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Blank Note',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start with a clean slate',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer
                              .withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, WidgetRef ref, template) {
    final theme = Theme.of(context);
    final icon = _getTemplateIcon(template.name);
    final description = _getTemplateDescription(template.name);
    final color = _getTemplateColor(template.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _createNoteFromTemplate(context, ref, template),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTemplateIcon(String templateName) {
    switch (templateName) {
      case 'Daily Journal':
        return Icons.today_rounded;
      case 'Meeting Notes':
        return Icons.groups_rounded;
      case 'Study Notes':
        return Icons.school_rounded;
      case 'Project Planning':
        return Icons.assignment_rounded;
      case 'Book Notes':
        return Icons.menu_book_rounded;
      default:
        return Icons.note_rounded;
    }
  }

  String _getTemplateDescription(String templateName) {
    switch (templateName) {
      case 'Daily Journal':
        return 'Daily reflection and planning template';
      case 'Meeting Notes':
        return 'Structured meeting documentation';
      case 'Study Notes':
        return 'Academic note-taking template';
      case 'Project Planning':
        return 'Project structure and milestones';
      case 'Book Notes':
        return 'Reading notes and quotes template';
      default:
        return 'Template';
    }
  }

  Color _getTemplateColor(String templateName) {
    switch (templateName) {
      case 'Daily Journal':
        return Colors.blue;
      case 'Meeting Notes':
        return Colors.green;
      case 'Study Notes':
        return Colors.purple;
      case 'Project Planning':
        return Colors.orange;
      case 'Book Notes':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _createBlankNote(BuildContext context, WidgetRef ref) async {
    try {
      final note = await ref.read(notesProvider.notifier).createNote();
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                SimpleNoteEditorScreen(noteId: note.id),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: child,
                  );
                },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Failed to create note: $error')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
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
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                SimpleNoteEditorScreen(noteId: note.id),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: child,
                  );
                },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Failed to create note from template: $error'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}
