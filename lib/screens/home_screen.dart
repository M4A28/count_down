import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:count_down/l10n/app_localizations.dart';
import '../providers/events_provider.dart';
import '../services/notification_service.dart';
import '../widgets/event_card.dart';
import 'add_edit_event_screen.dart';
import 'event_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Auto-archive and handle recurrence on launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService().requestPermissions();
      final provider = context.read<EventsProvider>();
      provider.handleRecurringEvents();
      provider.autoArchiveExpired();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            snap: true,
            pinned: true,
            expandedHeight: _isSearching ? 120 : 140,
            title: _isSearching
                ? _buildSearchField(l10n, theme)
                : Text(l10n.appTitle),
            actions: [
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search_rounded),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      context.read<EventsProvider>().setSearchQuery('');
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_rounded),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.label,
              dividerHeight: 0,
              tabs: [
                Tab(text: l10n.activeEvents),
                Tab(text: l10n.archivedEvents),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildEventsList(isArchived: false),
            _buildEventsList(isArchived: true),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEvent(),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addEvent),
      ),
    );
  }

  Widget _buildSearchField(AppLocalizations l10n, ThemeData theme) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: l10n.search,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          fillColor: Colors.transparent,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
        ),
        onChanged: (q) => context.read<EventsProvider>().setSearchQuery(q),
      ),
    );
  }

  Widget _buildEventsList({required bool isArchived}) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<EventsProvider>(
      builder: (context, provider, _) {
        final events = isArchived
            ? provider.archivedEvents
            : provider.activeEvents;

        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isArchived
                      ? Icons.archive_rounded
                      : Icons.hourglass_empty_rounded,
                  size: 80,
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 16),
                Text(
                  isArchived ? l10n.noArchivedEvents : l10n.noEvents,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                if (!isArchived) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.noEventsSubtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              return GridView.builder(
                padding: const EdgeInsets.only(
                  top: 16,
                  bottom: 100,
                  left: 16,
                  right: 16,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 500,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return EventCard(
                    event: event,
                    onTap: () => _navigateToDetail(event.id),
                    onLongPress: () => _showEventOptions(event.id, isArchived),
                  );
                },
              );
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 100),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return EventCard(
                      event: event,
                      onTap: () => _navigateToDetail(event.id),
                      onLongPress: () =>
                          _showEventOptions(event.id, isArchived),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToAddEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditEventScreen()),
    ).then((_) => context.read<EventsProvider>().loadEvents());
  }

  void _navigateToDetail(String eventId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: eventId)),
    ).then((_) => context.read<EventsProvider>().loadEvents());
  }

  void _showEventOptions(String eventId, bool isArchived) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<EventsProvider>();

    showModalBottomSheet(
      context: context,
      constraints: const BoxConstraints(maxWidth: 600),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: Text(l10n.edit),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditEventScreen(eventId: eventId),
                  ),
                ).then((_) => provider.loadEvents());
              },
            ),
            ListTile(
              leading: Icon(
                isArchived ? Icons.unarchive_rounded : Icons.archive_rounded,
              ),
              title: Text(isArchived ? l10n.unarchive : l10n.archive),
              onTap: () {
                Navigator.pop(ctx);
                if (isArchived) {
                  provider.unarchiveEvent(eventId);
                } else {
                  provider.archiveEvent(eventId);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: Colors.red),
              title: Text(
                l10n.delete,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(eventId);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String eventId) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<EventsProvider>().deleteEvent(eventId);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
