import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../core/theme/app_theme.dart';
import 'countdown_display.dart';

class EventCard extends StatefulWidget {
  final EventModel event;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

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
    if (!mounted) return;
    setState(() {
      _remaining = widget.event.remainingDuration;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preset = widget.event.themePreset != null
        ? PresetTheme.getById(widget.event.themePreset!)
        : null;
    final bgColor = widget.event.backgroundColor != null
        ? Color(widget.event.backgroundColor!)
        : null;
    final gradientColors =
        preset?.gradientColors ??
        [
          theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
        ];

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          gradient: bgColor == null
              ? LinearGradient(
                  colors: gradientColors
                      .map((c) => c.withValues(alpha: 0.15))
                      .toList(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: bgColor?.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (preset?.primaryColor ?? theme.colorScheme.outline)
                .withValues(alpha: 0.1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Event image or icon
              _buildLeading(theme, preset),
              const SizedBox(width: 14),
              // Event info
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(widget.event.targetDateTime),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: widget.event.progressPercentage,
                        backgroundColor: theme.colorScheme.onSurface.withValues(
                          alpha: 0.08,
                        ),
                        valueColor: AlwaysStoppedAnimation(
                          preset?.primaryColor ?? theme.colorScheme.primary,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Countdown
              Expanded(
                flex: 3,
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: CountdownDisplay(
                    duration: _remaining,
                    displayFormat: widget.event.displayFormat,
                    isExpired: widget.event.isExpired,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(ThemeData theme, PresetTheme? preset) {
    if (widget.event.imagePath != null &&
        File(widget.event.imagePath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.file(
          File(widget.event.imagePath!),
          width: 52,
          height: 52,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              preset?.gradientColors ??
              [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        preset?.icon ?? Icons.event_rounded,
        color: Colors.white,
        size: 26,
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} - '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
