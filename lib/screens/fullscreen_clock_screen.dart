import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:count_down/l10n/app_localizations.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../providers/events_provider.dart';
import '../models/event_model.dart';
import '../widgets/countdown_display.dart';
import '../core/theme/app_theme.dart';

class FullscreenClockScreen extends StatefulWidget {
  final String eventId;
  const FullscreenClockScreen({super.key, required this.eventId});

  @override
  State<FullscreenClockScreen> createState() => _FullscreenClockScreenState();
}

class _FullscreenClockScreenState extends State<FullscreenClockScreen> {
  late Timer _timer;
  Duration _remaining = Duration.zero;
  bool _keepScreenOn = true;

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
    WakelockPlus.enable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _updateRemaining() {
    final event = _event;
    if (event == null || !mounted) return;
    setState(() => _remaining = event.remainingDuration);
  }

  @override
  void dispose() {
    _timer.cancel();
    WakelockPlus.disable();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final event = _event;
    if (event == null) {
      return const Scaffold(body: Center(child: Text('Event not found')));
    }

    final l10n = AppLocalizations.of(context)!;
    final preset = event.themePreset != null
        ? PresetTheme.getById(event.themePreset!)
        : null;
    final gradColors =
        preset?.gradientColors ??
        [const Color(0xFF6C63FF), const Color(0xFFFF6584)];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => _showControls(l10n),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradColors.map((c) => c.withValues(alpha: 0.3)).toList(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: Colors.white70,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 40),
                CountdownDisplay(
                  duration: _remaining,
                  displayFormat: event.displayFormat,
                  isExpired: event.isExpired,
                  isLarge: true,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 40),
                Text(
                  '${l10n.remaining}...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.4),
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showControls(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      constraints: const BoxConstraints(maxWidth: 600),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: Text(
                  l10n.keepScreenOn,
                  style: const TextStyle(color: Colors.white),
                ),
                value: _keepScreenOn,
                onChanged: (v) {
                  setState(() => _keepScreenOn = v);
                  if (v) {
                    WakelockPlus.enable();
                  } else {
                    WakelockPlus.disable();
                  }
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.white70),
                title: Text(
                  l10n.cancel,
                  style: const TextStyle(color: Colors.white70),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
