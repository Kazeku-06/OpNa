import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notes_provider.dart';

class NotesSearchBar extends ConsumerStatefulWidget {
  final TextEditingController controller;

  const NotesSearchBar({
    super.key,
    required this.controller,
  });

  @override
  ConsumerState<NotesSearchBar> createState() => _NotesSearchBarState();
}

class _NotesSearchBarState extends ConsumerState<NotesSearchBar> {
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.controller.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = widget.controller.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: 'Search notes...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: widget.controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  widget.controller.clear();
                  ref.read(searchQueryProvider.notifier).state = '';
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
    );
  }
}