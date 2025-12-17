import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/note.dart';

class NoteListItem extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback onTogglePin;

  const NoteListItem({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
    required this.onDuplicate,
    required this.onTogglePin,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Row(
          children: [
            if (note.isPinned)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.push_pin, size: 16, color: Colors.orange),
              ),
            Expanded(
              child: Text(
                note.title,
                style: const TextStyle(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.folder != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.folder, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      note.folder!,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Updated: ${dateFormat.format(note.updatedAt)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'pin':
                onTogglePin();
                break;
              case 'duplicate':
                onDuplicate();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'pin',
              child: Row(
                children: [
                  Icon(note.isPinned ? Icons.push_pin_outlined : Icons.push_pin),
                  const SizedBox(width: 8),
                  Text(note.isPinned ? 'Unpin' : 'Pin'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'duplicate',
              child: Row(
                children: [
                  Icon(Icons.copy),
                  SizedBox(width: 8),
                  Text('Duplicate'),
                ],
              ),
            ),
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
        onTap: onTap,
      ),
    );
  }
}