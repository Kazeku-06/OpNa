import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notes_provider.dart';

class SortOptionsWidget extends ConsumerWidget {
  const SortOptionsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSort = ref.watch(sortOptionProvider);

    return Row(
      children: [
        const Text('Sort by: '),
        const SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: SortOption.values.map((option) {
                final isSelected = currentSort == option;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_getSortLabel(option)),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(sortOptionProvider.notifier).state = option;
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  String _getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.dateCreated:
        return 'Date Created';
      case SortOption.dateUpdated:
        return 'Date Updated';
      case SortOption.title:
        return 'Title';
      case SortOption.pinned:
        return 'Pinned First';
    }
  }
}