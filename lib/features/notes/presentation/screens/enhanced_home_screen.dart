import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/notes_provider.dart';
import '../widgets/beautiful_notes_list.dart';
import '../widgets/beautiful_search_bar.dart';
import '../widgets/animated_filter_chips.dart';
import '../widgets/note_filter.dart';
import '../../../templates/presentation/screens/beautiful_template_selection_screen.dart';

class EnhancedHomeScreen extends ConsumerStatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  ConsumerState<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends ConsumerState<EnhancedHomeScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  NoteFilter _currentFilter = NoteFilter.all;
  late AnimationController _fabAnimationController;
  late AnimationController _headerAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<Offset> _headerSlideAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _headerSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _headerAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Start animations
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimationController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Beautiful App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
            flexibleSpace: FlexibleSpaceBar(
              background: SlideTransition(
                position: _headerSlideAnimation,
                child: _buildHeader(),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.analytics_outlined),
                onPressed: _showStats,
                tooltip: 'Statistics',
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: _showSettings,
                tooltip: 'Settings',
              ),
            ],
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: BeautifulSearchBar(
                controller: _searchController,
                onChanged: (query) {
                  ref.read(searchQueryProvider.notifier).state = query;
                },
              ),
            ),
          ),

          // Filter Chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: AnimatedFilterChips(
                currentFilter: _currentFilter,
                onFilterChanged: (filter) {
                  setState(() {
                    _currentFilter = filter;
                  });
                },
                notes: searchResults.value ?? [],
              ),
            ),
          ),

          // Notes List
          SliverFillRemaining(
            child: searchResults.when(
              data: (notes) => BeautifulNotesList(
                notes: notes,
                currentFilter: _currentFilter,
                onFilterChanged: (filter) {
                  setState(() {
                    _currentFilter = filter;
                  });
                },
              ),
              loading: () => _buildLoadingState(),
              error: (error, _) => _buildErrorState(error),
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: FloatingActionButton.extended(
          onPressed: _createNewNote,
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Note'),
          elevation: 8,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final greeting = _getGreeting();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w300,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your Notes',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('EEEE, MMMM d').format(now),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your notes...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref.refresh(notesProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _createNewNote() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const BeautifulTemplateSelectionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
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

  void _showStats() {
    final notes = ref.read(notesProvider).value ?? [];
    final totalNotes = notes.where((n) => !n.isDeleted).length;
    final pinnedNotes = notes.where((n) => n.isPinned && !n.isDeleted).length;
    final archivedNotes = notes
        .where((n) => n.isArchived && !n.isDeleted)
        .length;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Statistics',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatCard(
                    icon: Icons.note_outlined,
                    label: 'Total Notes',
                    value: totalNotes.toString(),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  _StatCard(
                    icon: Icons.push_pin_outlined,
                    label: 'Pinned',
                    value: pinnedNotes.toString(),
                    color: Colors.orange,
                  ),
                  _StatCard(
                    icon: Icons.archive_outlined,
                    label: 'Archived',
                    value: archivedNotes.toString(),
                    color: Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.backup_outlined),
                title: const Text('Create Backup'),
                onTap: () {
                  Navigator.pop(context);
                  _createBackup();
                },
              ),
              ListTile(
                leading: const Icon(Icons.restore_outlined),
                title: const Text('Restore Backup'),
                onTap: () {
                  Navigator.pop(context);
                  _restoreBackup();
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_download_outlined),
                title: const Text('Export Notes'),
                onTap: () {
                  Navigator.pop(context);
                  _exportNotes();
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: () {
                  Navigator.pop(context);
                  _showAbout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createBackup() async {
    try {
      final repository = ref.read(notesRepositoryProvider);
      final backupName = 'backup_${DateTime.now().millisecondsSinceEpoch}';
      await repository.createBackup(backupName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Backup created successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Failed to create backup: $error')),
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

  void _restoreBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Restore backup feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _exportNotes() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export notes feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Offline Markdown Notes',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.note_outlined,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 32,
        ),
      ),
      children: [
        const Text(
          'A beautiful, offline-first markdown notes app built with Flutter.',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
