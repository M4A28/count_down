import 'dart:async';
import 'package:flutter/material.dart';
import 'package:count_down/l10n/app_localizations.dart';

class CountdownDisplay extends StatefulWidget {
  final Duration duration;
  final int displayFormat;
  final bool isExpired;
  final bool isLarge;
  final Color? textColor;

  const CountdownDisplay({
    super.key,
    required this.duration,
    this.displayFormat = 0,
    this.isExpired = false,
    this.isLarge = false,
    this.textColor,
  });

  @override
  State<CountdownDisplay> createState() => _CountdownDisplayState();
}

class _CountdownDisplayState extends State<CountdownDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(CountdownDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration.inSeconds != widget.duration.inSeconds) {
      _animController.forward().then((_) => _animController.reverse());
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final color = widget.textColor ?? theme.colorScheme.onSurface;

    if (widget.isExpired) {
      return Text(
        l10n.eventArrived,
        style: TextStyle(
          fontSize: widget.isLarge ? 32 : 18,
          fontWeight: FontWeight.w700,
          color: Colors.green,
        ),
      );
    }

    final days = widget.duration.inDays;
    final hours = widget.duration.inHours % 24;
    final minutes = widget.duration.inMinutes % 60;
    final seconds = widget.duration.inSeconds % 60;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.isLarge
          ? _buildLargeDisplay(days, hours, minutes, seconds, l10n, color)
          : _buildCompactDisplay(days, hours, minutes, seconds, l10n, color),
    );
  }

  Widget _buildLargeDisplay(
    int days,
    int hours,
    int minutes,
    int seconds,
    AppLocalizations l10n,
    Color color,
  ) {
    final items = _getDisplayItems(days, hours, minutes, seconds, l10n);
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: items.map((item) {
          final index = items.indexOf(item);
          return Row(
            children: [
              if (index > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    ':',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      color: color.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              _TimeBlock(
                value: item['value']!,
                label: item['label']!,
                color: color,
                isLarge: true,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCompactDisplay(
    int days,
    int hours,
    int minutes,
    int seconds,
    AppLocalizations l10n,
    Color color,
  ) {
    final items = _getDisplayItems(days, hours, minutes, seconds, l10n);
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          final index = items.indexOf(item);
          return Row(
            children: [
              if (index > 0) const SizedBox(width: 12),
              _TimeBlock(
                value: item['value']!,
                label: item['label']!,
                color: color,
                isLarge: false,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<Map<String, String>> _getDisplayItems(
    int days,
    int hours,
    int minutes,
    int seconds,
    AppLocalizations l10n,
  ) {
    switch (widget.displayFormat) {
      case 1: // days only
        return [
          {'value': '$days', 'label': l10n.days},
        ];
      case 2: // no seconds
        return [
          {'value': '$days', 'label': l10n.days},
          {'value': hours.toString().padLeft(2, '0'), 'label': l10n.hours},
          {'value': minutes.toString().padLeft(2, '0'), 'label': l10n.minutes},
        ];
      default: // full
        return [
          {'value': '$days', 'label': l10n.days},
          {'value': hours.toString().padLeft(2, '0'), 'label': l10n.hours},
          {'value': minutes.toString().padLeft(2, '0'), 'label': l10n.minutes},
          {'value': seconds.toString().padLeft(2, '0'), 'label': l10n.seconds},
        ];
    }
  }
}

class _TimeBlock extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final bool isLarge;

  const _TimeBlock({
    required this.value,
    required this.label,
    required this.color,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isLarge ? 16 : 10,
            vertical: isLarge ? 12 : 6,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(isLarge ? 16 : 12),
            border: Border.all(color: color.withValues(alpha: 0.15)),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: isLarge ? 56 : 22,
              fontWeight: FontWeight.w700,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isLarge ? 14 : 10,
            fontWeight: FontWeight.w500,
            color: color.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
