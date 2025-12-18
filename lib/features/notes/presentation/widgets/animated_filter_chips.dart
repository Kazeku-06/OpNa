import 'package:flutter/material.dart';
import '../../domain/entities/note.dart';
import 'enhanced_notes_list.dart';

class AnimatedFilterChips extends StatelessWidget {
  final NoteFilter currentFilter;
  final ValueChanged<NoteFilter> onFilterChanged;
  final List<Note> notes;

  const AnimatedFilterChips({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            context,
            NoteFilter.all,
            'All',
            Icons.notes_rounded,
            _getFilterCount(NoteFilter.all),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            NoteFilter.pinned,
            'Pinned',
            Icons.push_pin_rounded,
            _getFilterCount(NoteFilter.pinned),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            NoteFilter.archived,
            'Archived',
            Icons.archive_rounded,
            _getFilterCount(NoteFilter.archived),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            NoteFilter.deleted,
            'Trash',
            Icons.delete_rounded,
            _getFilterCount(NoteFilter.deleted),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    NoteFilter filter,
    String label,
    IconData icon,
    int count,
  ) {
    final theme = Theme.of(context);
    final isSelected = currentFilter == filter;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer.withOpacity(0.2)
                      : theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        onSelected: (selected) {
          if (selected) onFilterChanged(filter);
        },
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        selectedColor: theme.colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        elevation: isSelected ? 2 : 0,
        shadowColor: theme.colorScheme.primary.withOpacity(0.3),
      ),
    );
  }

  int _getFilterCount(NoteFilter filter) {
    switch (filter) {
      case NoteFilter.all:
        return notes.where((n) => !n.isArchived && !n.isDeleted).length;
      case NoteFilter.pinned:
        return notes
            .where((n) => n.isPinned && !n.isArchived && !n.isDeleted)
            .length;
      case NoteFilter.archived:
        return notes.where((n) => n.isArchived && !n.isDeleted).length;
      case NoteFilter.deleted:
        return notes.where((n) => n.isDeleted).length;
    }
  }
}
