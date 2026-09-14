import 'dart:async';
import 'dart:io';
import 'package:count_down/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/event_model.dart';
import '../providers/events_provider.dart';
import '../core/theme/app_theme.dart';
import '../widgets/countdown_display.dart';
import 'add_edit_event_screen.dart';
import 'fullscreen_clock_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Timer _timer;
  Duration _remaining = Duration.zero;
  final _screenshotController = ScreenshotController();

  EventModel? get _event =>
      context.read<EventsProvider>().getEvent(widget.eventId);

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateRemaining(),
    );
  }

  void _updateRemaining() {
    final event = _event;
    if (event == null || !mounted) return;
    setState(() => _remaining = event.remainingDuration);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final event = _event;
    if (event == null)
      return const Scaffold(body: Center(child: Text('Event not found')));

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final preset = event.themePreset != null
        ? PresetTheme.getById(event.themePreset!)
        : null;
    final gradColors =
        preset?.gradientColors ??
        [theme.colorScheme.primary, theme.colorScheme.secondary];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(event, gradColors, theme),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.fullscreen_rounded),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FullscreenClockScreen(eventId: widget.eventId),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) => _handleMenuAction(v, event),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(l10n.edit),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'share_img',
                    child: Row(
                      children: [
                        const Icon(Icons.image_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(l10n.shareAsImage),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'archive',
                    child: Row(
                      children: [
                        Icon(
                          event.isArchived
                              ? Icons.unarchive_rounded
                              : Icons.archive_rounded,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(event.isArchived ? l10n.unarchive : l10n.archive),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_rounded,
                          size: 20,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.delete,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Countdown section
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Screenshot(
                    controller: _screenshotController,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradColors
                              .map((c) => c.withValues(alpha: 0.1))
                              .toList(),
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: gradColors.first.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            event.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 20),
                          CountdownDisplay(
                            duration: _remaining,
                            displayFormat: event.displayFormat,
                            isExpired: event.isExpired,
                            isLarge: true,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _formatDate(event.targetDateTime),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Progress section
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildProgressSection(event, l10n, theme, gradColors),
                ),
              ),
            ),
          ),

          // Stats section
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _buildStatsSection(event, l10n, theme),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildHeader(
    EventModel event,
    List<Color> gradColors,
    ThemeData theme,
  ) {
    if (event.imagePath != null && File(event.imagePath!).existsSync()) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(event.imagePath!), fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildProgressSection(
    EventModel event,
    AppLocalizations l10n,
    ThemeData theme,
    List<Color> gradColors,
  ) {
    final progress = event.progressPercentage;
    final pct = (progress * 100).toInt();
    String? motivational;
    if (pct >= 90)
      motivational = l10n.motivational90;
    else if (pct >= 75)
      motivational = l10n.motivational75;
    else if (pct >= 50)
      motivational = l10n.motivationalHalf;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.progress,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '$pct%',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: gradColors.first,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: theme.colorScheme.onSurface.withValues(
              alpha: 0.08,
            ),
            valueColor: AlwaysStoppedAnimation(gradColors.first),
          ),
        ),
        if (motivational != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: gradColors.first.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events_rounded, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    motivational,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsSection(
    EventModel event,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final total = event.targetDateTime.difference(event.createdAt);
    final elapsed = DateTime.now().difference(event.createdAt);
    return Row(
      children: [
        Expanded(
          child: _statCard(
            l10n.timeElapsed,
            '${elapsed.inDays} ${l10n.days}',
            Icons.hourglass_top_rounded,
            theme.colorScheme.tertiary,
            theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            l10n.timeRemaining,
            '${_remaining.inDays} ${l10n.days}',
            Icons.hourglass_bottom_rounded,
            theme.colorScheme.primary,
            theme,
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, EventModel event) {
    final provider = context.read<EventsProvider>();
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddEditEventScreen(eventId: widget.eventId),
          ),
        ).then((_) => setState(() {}));
      case 'share_img':
        _shareAsImage();
      case 'archive':
        if (event.isArchived) {
          provider.unarchiveEvent(event.id);
        } else {
          provider.archiveEvent(event.id);
        }
        Navigator.pop(context);
      case 'delete':
        _confirmDelete();
    }
  }

  Future<void> _shareAsImage() async {
    final image = await _screenshotController.capture();
    if (image == null) return;
    final dir = await getTemporaryDirectory();
    final file = await File('${dir.path}/countdown_share.png').create();
    await file.writeAsBytes(image);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: _event?.title ?? ''),
    );
  }

  void _confirmDelete() {
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
              context.read<EventsProvider>().deleteEvent(widget.eventId);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} - '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
