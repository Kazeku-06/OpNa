import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/notes_provider.dart';
import 'diff_viewer_screen.dart';

class VersionHistoryScreen extends ConsumerWidget {
  final String noteId;

  const VersionHistoryScreen({
    super.key,
    required this.noteId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versionsAsync = ref.watch(noteVersionsProvider(noteId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Version History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: versionsAsync.when(
        data: (versions) {
          if (versions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No versions saved yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Save a version from the editor to see it here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: versions.length,
            itemBuilder: (context, index) {
              final version = versions[index];
              final isLatest = index == 0;
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isLatest 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceVariant,
                    child: Text(
                      'v${version.version}',
                      style: TextStyle(
                        color: isLatest 
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text('Version ${version.version}'),
                      if (isLatest)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'LATEST',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    'Saved: ${DateFormat('MMM dd, yyyy HH:mm').format(version.createdAt)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      switch (value) {
                        case 'restore':
                          await _restoreVersion(context, ref, version);
                          break;
                        case 'compare':
                          if (index < versions.length - 1) {
                            _compareVersions(context, version, versions[index + 1]);
                          }
                          break;
                        case 'delete':
                          await _deleteVersion(context, ref, version);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (!isLatest)
                        const PopupMenuItem(
                          value: 'restore',
                          child: Row(
                            children: [
                              Icon(Icons.restore),
                              SizedBox(width: 8),
                              Text('Restore'),
                            ],
                          ),
                        ),
                      if (index < versions.length - 1)
                        const PopupMenuItem(
                          value: 'compare',
                          child: Row(
                            children: [
                              Icon(Icons.compare_arrows),
                              SizedBox(width: 8),
                              Text('Compare'),
                            ],
                          ),
                        ),
                      if (!isLatest)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  onTap: () => _previewVersion(context, version),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64),
              const SizedBox(height: 16),
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () => ref.refresh(noteVersionsProvider(noteId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _previewVersion(BuildContext context, version) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Version ${version.version}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Text(
              version.content,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreVersion(BuildContext context, WidgetRef ref, version) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Version'),
        content: Text(
          'Are you sure you want to restore version ${version.version}? '
          'This will replace the current content.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repository = ref.read(notesRepositoryProvider);
        await repository.saveNoteContent(noteId, version.content);
        
        // Update the content provider
        ref.read(noteContentProvider(noteId).notifier).updateContent(version.content);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Version ${version.version} restored')),
          );
          Navigator.of(context).pop(); // Go back to editor
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to restore version: $error')),
          );
        }
      }
    }
  }

  void _compareVersions(BuildContext context, version1, version2) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DiffViewerScreen(
          noteId: noteId,
          version1: version1,
          version2: version2,
        ),
      ),
    );
  }

  Future<void> _deleteVersion(BuildContext context, WidgetRef ref, version) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Version'),
        content: Text(
          'Are you sure you want to delete version ${version.version}? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repository = ref.read(notesRepositoryProvider);
        await repository.deleteVersion(noteId, version.version);
        
        // Refresh the versions list
        ref.refresh(noteVersionsProvider(noteId));
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Version ${version.version} deleted')),
          );
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete version: $error')),
          );
        }
      }
    }
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Version History Help'),
        content: const Text(
          'Versions are created when you manually save from the editor.\n\n'
          '• Tap a version to preview its content\n'
          '• Use the menu to restore, compare, or delete versions\n'
          '• The latest version is marked and cannot be deleted\n'
          '• Compare shows differences between two versions',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}