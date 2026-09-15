import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:count_down/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/event_model.dart';
import '../models/reminder_model.dart';
import '../providers/events_provider.dart';
import '../services/notification_service.dart';
import '../core/theme/app_theme.dart';

class AddEditEventScreen extends StatefulWidget {
  final String? eventId;
  const AddEditEventScreen({super.key, this.eventId});

  @override
  State<AddEditEventScreen> createState() => _AddEditEventScreenState();
}

class _AddEditEventScreenState extends State<AddEditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _uuid = const Uuid();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  String? _imagePath;
  int _displayFormat = 0;
  int _recurrenceType = 0;
  bool _notificationsEnabled = true;
  bool _vibrationEnabled = true;
  String? _themePreset;
  int? _backgroundColor;
  List<ReminderModel> _reminders = [];

  bool get _isEditing => widget.eventId != null;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 7));
    _selectedTime = TimeOfDay.fromDateTime(_selectedDate);
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadEvent());
    }
  }

  void _loadEvent() {
    final provider = context.read<EventsProvider>();
    final event = provider.getEvent(widget.eventId!);
    if (event != null) {
      setState(() {
        _titleController.text = event.title;
        _selectedDate = event.targetDateTime;
        _selectedTime = TimeOfDay.fromDateTime(event.targetDateTime);
        _imagePath = event.imagePath;
        _displayFormat = event.displayFormat;
        _recurrenceType = event.recurrenceType;
        _notificationsEnabled = event.notificationsEnabled;
        _vibrationEnabled = event.vibrationEnabled;
        _themePreset = event.themePreset;
        _backgroundColor = event.backgroundColor;
        _reminders = provider.getReminders(event.id);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? l10n.editEvent : l10n.addEvent)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _sectionTitle(l10n.eventTitle, Icons.title_rounded),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(hintText: l10n.eventTitleHint),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? l10n.eventTitleRequired
                      : null,
                ),
                const SizedBox(height: 24),
                _sectionTitle(l10n.dateAndTime, Icons.calendar_today_rounded),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _optionCard(
                        Icons.calendar_month_rounded,
                        '${_selectedDate.year}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}',
                        _pickDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _optionCard(
                        Icons.access_time_rounded,
                        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                        _pickTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _sectionTitle(l10n.image, Icons.image_rounded),
                const SizedBox(height: 8),
                _buildImagePicker(l10n),
                const SizedBox(height: 24),
                _sectionTitle(l10n.themePreset, Icons.palette_rounded),
                const SizedBox(height: 8),
                _buildThemePresetPicker(),
                const SizedBox(height: 24),
                _sectionTitle(l10n.displayFormat, Icons.timer_rounded),
                const SizedBox(height: 8),
                _buildDisplayFormatPicker(l10n),
                const SizedBox(height: 24),
                _sectionTitle(l10n.recurrence, Icons.repeat_rounded),
                const SizedBox(height: 8),
                _buildRecurrencePicker(l10n),
                const SizedBox(height: 24),
                _sectionTitle(l10n.notifications, Icons.notifications_rounded),
                const SizedBox(height: 8),
                _buildNotifications(l10n),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _saveEvent,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(l10n.save),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t, IconData ic) => Row(
    children: [
      Icon(ic, size: 20, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 8),
      Text(
        t,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    ],
  );

  Widget _optionCard(IconData ic, String label, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(ic, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    ),
  );

  Widget _buildImagePicker(AppLocalizations l10n) {
    if (_imagePath != null && File(_imagePath!).existsSync()) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(_imagePath!),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                _miniBtn(Icons.edit, () => _pickImage()),
                const SizedBox(width: 4),
                _miniBtn(Icons.close, () => setState(() => _imagePath = null)),
              ],
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: _optionCard(
            Icons.photo_library_rounded,
            l10n.fromGallery,
            () => _pickImage(source: ImageSource.gallery),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _optionCard(
            Icons.camera_alt_rounded,
            l10n.fromCamera,
            () => _pickImage(source: ImageSource.camera),
          ),
        ),
      ],
    );
  }

  Widget _miniBtn(IconData ic, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(ic, size: 18, color: Colors.white),
    ),
  );

  Widget _buildThemePresetPicker() {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _themeChip(
            null,
            Icons.format_paint_rounded,
            AppLocalizations.of(context)!.custom,
            null,
          ),
          ...PresetTheme.presets.map(
            (p) => _themeChip(
              p.id,
              p.icon,
              isAr ? p.nameAr : p.nameEn,
              p.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _themeChip(String? id, IconData ic, String label, Color? color) {
    final sel = _themePreset == id;
    final th = Theme.of(context);
    return GestureDetector(
      onTap: () => setState(() => _themePreset = id),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: sel
                ? (color ?? th.colorScheme.primary)
                : th.colorScheme.outline.withValues(alpha: 0.15),
            width: sel ? 2 : 1,
          ),
          color: sel
              ? (color ?? th.colorScheme.primary).withValues(alpha: 0.1)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ic, color: color ?? th.colorScheme.primary, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayFormatPicker(AppLocalizations l10n) => Wrap(
    spacing: 8,
    children: [(0, l10n.fullFormat), (1, l10n.daysOnly), (2, l10n.noSeconds)]
        .map(
          (f) => ChoiceChip(
            selected: _displayFormat == f.$1,
            label: Text(f.$2, style: const TextStyle(fontSize: 12)),
            onSelected: (_) => setState(() => _displayFormat = f.$1),
          ),
        )
        .toList(),
  );

  Widget _buildRecurrencePicker(AppLocalizations l10n) => Wrap(
    spacing: 8,
    children:
        [
              (0, l10n.once),
              (1, l10n.daily),
              (2, l10n.weekly),
              (3, l10n.monthly),
              (4, l10n.yearly),
            ]
            .map(
              (o) => ChoiceChip(
                selected: _recurrenceType == o.$1,
                label: Text(o.$2, style: const TextStyle(fontSize: 12)),
                onSelected: (_) => setState(() => _recurrenceType = o.$1),
              ),
            )
            .toList(),
  );

  Widget _buildNotifications(AppLocalizations l10n) => Column(
    children: [
      SwitchListTile(
        title: Text(l10n.enableNotifications),
        value: _notificationsEnabled,
        onChanged: (v) async {
          if (v) {
            await NotificationService().requestPermissions();
          }
          setState(() => _notificationsEnabled = v);
        },
        contentPadding: EdgeInsets.zero,
      ),
      SwitchListTile(
        title: Text(l10n.vibration),
        value: _vibrationEnabled,
        onChanged: (v) => setState(() => _vibrationEnabled = v),
        contentPadding: EdgeInsets.zero,
      ),
      if (_notificationsEnabled) ...[
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.reminders,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              onPressed: _addReminderDialog,
            ),
          ],
        ),
        ..._reminders.map(
          (r) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.alarm_rounded),
            title: Text('${r.label} ${l10n.beforeEvent}'),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () => setState(() => _reminders.remove(r)),
            ),
          ),
        ),
      ],
    ],
  );

  void _addReminderDialog() {
    final l10n = AppLocalizations.of(context)!;
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
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              l10n.addReminder,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...[
              (15, l10n.minutesBefore(15)),
              (60, l10n.hoursBefore(1)),
              (1440, l10n.daysBefore(1)),
              (10080, l10n.daysBefore(7)),
            ].map(
              (o) => ListTile(
                leading: const Icon(Icons.alarm_add_rounded),
                title: Text(o.$2),
                onTap: () {
                  setState(
                    () => _reminders.add(
                      ReminderModel(
                        id: _uuid.v4(),
                        eventId: widget.eventId ?? '',
                        offsetMinutes: o.$1,
                      ),
                    ),
                  );
                  Navigator.pop(ctx);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime(2100, 12, 31),
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (t != null) setState(() => _selectedTime = t);
  }

  Future<void> _pickImage({ImageSource source = ImageSource.gallery}) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1200,
    );
    if (picked != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final imgDir = Directory('${appDir.path}/event_images');
      if (!imgDir.existsSync()) imgDir.createSync(recursive: true);
      final newPath =
          '${imgDir.path}/${_uuid.v4()}${path.extension(picked.path)}';
      await File(picked.path).copy(newPath);
      setState(() => _imagePath = newPath);
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;
    final targetDT = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    final provider = context.read<EventsProvider>();
    final eventId = widget.eventId ?? _uuid.v4();
    final event = EventModel(
      id: eventId,
      title: _titleController.text.trim(),
      targetDateTime: targetDT,
      imagePath: _imagePath,
      displayFormat: _displayFormat,
      recurrenceType: _recurrenceType,
      notificationsEnabled: _notificationsEnabled,
      vibrationEnabled: _vibrationEnabled,
      themePreset: _themePreset,
      backgroundColor: _backgroundColor,
    );
    if (_isEditing) {
      await provider.updateEvent(event);
    } else {
      await provider.addEvent(event);
    }
    for (final r in _reminders) {
      await provider.addReminder(
        ReminderModel(
          id: r.id,
          eventId: eventId,
          offsetMinutes: r.offsetMinutes,
          repeatInterval: r.repeatInterval,
          isEnabled: r.isEnabled,
        ),
      );
    }

    // Show instant notification + SnackBar for new events
    if (!_isEditing && mounted) {
      final l10n = AppLocalizations.of(context)!;
      final eventTitle = _titleController.text.trim();

      // System notification
      await NotificationService().showInstantNotification(
        title: l10n.eventAddedSuccess,
        body: l10n.eventAddedNotification(eventTitle),
      );

      // In-app SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.eventAddedSuccess)),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    if (mounted) Navigator.pop(context);
  }
}
