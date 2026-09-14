import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:count_down/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import '../providers/settings_provider.dart';
import '../providers/events_provider.dart';
import '../services/hive_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Language
                  _sectionCard(
                    theme: theme,
                    icon: Icons.language_rounded,
                    title: l10n.language,
                    child: Row(
                      children: [
                        _langChip(context, settings, 'ar', l10n.arabic),
                        const SizedBox(width: 8),
                        _langChip(context, settings, 'en', l10n.english),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Theme
                  _sectionCard(
                    theme: theme,
                    icon: Icons.palette_rounded,
                    title: l10n.theme,
                    child: Row(
                      children: [
                        _themeChip(
                          context,
                          settings,
                          0,
                          l10n.systemTheme,
                          Icons.brightness_auto_rounded,
                        ),
                        const SizedBox(width: 8),
                        _themeChip(
                          context,
                          settings,
                          1,
                          l10n.lightTheme,
                          Icons.light_mode_rounded,
                        ),
                        const SizedBox(width: 8),
                        _themeChip(
                          context,
                          settings,
                          2,
                          l10n.darkTheme,
                          Icons.dark_mode_rounded,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Color picker
                  _sectionCard(
                    theme: theme,
                    icon: Icons.color_lens_rounded,
                    title: l10n.backgroundColor,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in _colors)
                          _colorDot(context, settings, c),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Quiet time
                  _sectionCard(
                    theme: theme,
                    icon: Icons.do_not_disturb_on_rounded,
                    title: l10n.quietTime,
                    subtitle: l10n.quietTimeDesc,
                    child: Row(
                      children: [
                        Text(
                          '${l10n.from}: ${_minutesToTime(settings.settings.quietTimeStart)}',
                        ),
                        const Spacer(),
                        Text(
                          '${l10n.to}: ${_minutesToTime(settings.settings.quietTimeEnd)}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Weekly reminder
                  _sectionCard(
                    theme: theme,
                    icon: Icons.calendar_view_week_rounded,
                    title: l10n.weeklyReminder,
                    subtitle: l10n.weeklyReminderDesc,
                    child: Switch(
                      value: settings.settings.weeklyReminderEnabled,
                      onChanged: (v) => settings.setWeeklyReminder(v),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Backup
                  _sectionCard(
                    theme: theme,
                    icon: Icons.backup_rounded,
                    title: l10n.backup,
                    child: Column(
                      children: [
                        _actionTile(
                          Icons.upload_rounded,
                          l10n.createBackup,
                          () => _createBackup(context, l10n),
                        ),
                        _actionTile(
                          Icons.download_rounded,
                          l10n.restoreBackup,
                          () => _restoreBackup(context, l10n),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Export CSV
                  _sectionCard(
                    theme: theme,
                    icon: Icons.table_chart_rounded,
                    title: l10n.exportCsv,
                    child: _actionTile(
                      Icons.file_download_rounded,
                      l10n.exportCsv,
                      () => _exportCsv(context, l10n),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Reset
                  _sectionCard(
                    theme: theme,
                    icon: Icons.restart_alt_rounded,
                    title: l10n.resetApp,
                    iconColor: Colors.red,
                    child: _actionTile(
                      Icons.delete_forever_rounded,
                      l10n.resetApp,
                      () => _resetApp(context, l10n),
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required ThemeData theme,
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget child,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: iconColor ?? theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _langChip(
    BuildContext ctx,
    SettingsProvider s,
    String code,
    String label,
  ) {
    final sel = s.settings.locale == code;
    return Expanded(
      child: GestureDetector(
        onTap: () => s.setLocale(code),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: sel
                ? Theme.of(ctx).colorScheme.primary.withValues(alpha: 0.1)
                : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: sel
                  ? Theme.of(ctx).colorScheme.primary
                  : Theme.of(ctx).colorScheme.outline.withValues(alpha: 0.15),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                color: sel ? Theme.of(ctx).colorScheme.primary : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _themeChip(
    BuildContext ctx,
    SettingsProvider s,
    int mode,
    String label,
    IconData icon,
  ) {
    final sel = s.settings.themeMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => s.setThemeMode(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel
                ? Theme.of(ctx).colorScheme.primary.withValues(alpha: 0.1)
                : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: sel
                  ? Theme.of(ctx).colorScheme.primary
                  : Theme.of(ctx).colorScheme.outline.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: sel ? Theme.of(ctx).colorScheme.primary : null,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                  color: sel ? Theme.of(ctx).colorScheme.primary : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _colors = [
    // ألوان أساسية إضافية
    0xFFF44336, // أحمر
    0xFF2196F3, // أزرق
    0xFF4CAF50, // أخضر
    0xFFFFEB3B, // أصفر
    0xFF009688, // تركوازي داكن
    0xFF673AB7, // بنفسجي غامق
    // ألوان نابضة (Accent Colors)
    0xFF00E676, // أخضر نابض
    0xFF2979FF, // أزرق نابض
    0xFFF50057, // وردي حاد
    0xFFFF3D00, // برتقالي حاد
    0xFFD500F9, // بنفسجي فوشيا
    0xFF00E5FF, // سماوي نابض
    // ألوان دافئة
    0xFFFFC107, // عنبري
    0xFFFF5722, // برتقالي محمر
    0xFF8BC34A, // أخضر ليموني
    0xFF3F51B5, // نيلي
    // ألوان هادئة / فاتحة
    0xFF26C6DA, // سماوي فاتح
    0xFFAB47BC, // بنفسجي فاتح
    0xFF5C6BC0, // أزرق بنفسجي هادئ
    0xFFFF7043, // مرجاني
  ];

  Widget _colorDot(BuildContext ctx, SettingsProvider s, int color) {
    final sel = s.settings.primaryColor == color;
    return GestureDetector(
      onTap: () => s.setPrimaryColor(color),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Color(color),
          shape: BoxShape.circle,
          border: Border.all(
            color: sel ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: sel
              ? [
                  BoxShadow(
                    color: Color(color).withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: sel
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : null,
      ),
    );
  }

  Widget _actionTile(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w500, color: color),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: color ?? Colors.grey),
          ],
        ),
      ),
    );
  }

  String _minutesToTime(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _createBackup(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final data = HiveService.exportAll();
    final json = jsonEncode(data);
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/countdown_backup_${DateTime.now().millisecondsSinceEpoch}.json',
    );
    await file.writeAsString(json);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.backupSuccess)));
    }
  }

  Future<void> _restoreBackup(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.isEmpty) return;
    final file = File(result.files.single.path!);
    final json = await file.readAsString();
    final data = jsonDecode(json) as Map<String, dynamic>;
    await HiveService.importAll(data);
    if (context.mounted) {
      context.read<EventsProvider>().loadEvents();
      context.read<SettingsProvider>().loadSettings();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.restoreSuccess)));
    }
  }

  Future<void> _exportCsv(BuildContext context, AppLocalizations l10n) async {
    final events = HiveService.getAllEvents();
    final rows = [
      ['Title', 'Target Date', 'Days Remaining', 'Status'],
      ...events.map(
        (e) => [
          e.title,
          e.targetDateTime.toIso8601String(),
          e.remainingDuration.inDays.toString(),
          e.isExpired ? 'Expired' : 'Active',
        ],
      ),
    ];
    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/countdown_events.csv');
    await file.writeAsString(csv);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.exportSuccess)));
    }
  }

  void _resetApp(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.resetConfirmTitle),
        content: Text(l10n.resetConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await HiveService.resetAll();
              if (context.mounted) {
                context.read<EventsProvider>().loadEvents();
                context.read<SettingsProvider>().resetSettings();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.resetSuccess)));
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}
