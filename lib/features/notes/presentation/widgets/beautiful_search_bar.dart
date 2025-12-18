import 'package:flutter/material.dart';

class BeautifulSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String hintText;

  const BeautifulSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.hintText = 'Search your notes...',
  });

  @override
  State<BeautifulSearchBar> createState() => _BeautifulSearchBarState();
}

class _BeautifulSearchBarState extends State<BeautifulSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(
                _isFocused ? 0.1 : 0.05,
              ),
              blurRadius: _isFocused ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          onTap: () {
            setState(() => _isFocused = true);
            _animationController.forward();
          },
          onTapOutside: (_) {
            setState(() => _isFocused = false);
            _animationController.reverse();
          },
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.search_rounded,
                color: _isFocused
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.5),
                size: 24,
              ),
            ),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    onPressed: () {
                      widget.controller.clear();
                      widget.onChanged?.call('');
                    },
                  )
                : null,
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }
}
