import 'package:hive_flutter/hive_flutter.dart';
import '../models/event_model.dart';
import '../models/reminder_model.dart';
import '../models/app_settings_model.dart';

class HiveService {
  static const String eventsBoxName = 'events';
  static const String remindersBoxName = 'reminders';
  static const String settingsBoxName = 'settings';
  static const String settingsKey = 'app_settings';

  static late Box<EventModel> _eventsBox;
  static late Box<ReminderModel> _remindersBox;
  static late Box<AppSettingsModel> _settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(EventModelAdapter());
    Hive.registerAdapter(ReminderModelAdapter());
    Hive.registerAdapter(AppSettingsModelAdapter());
    _eventsBox = await Hive.openBox<EventModel>(eventsBoxName);
    _remindersBox = await Hive.openBox<ReminderModel>(remindersBoxName);
    _settingsBox = await Hive.openBox<AppSettingsModel>(settingsBoxName);
  }

  // ─── Events ────────────────────────────────────────────
  static Box<EventModel> get eventsBox => _eventsBox;

  static List<EventModel> getAllEvents() => _eventsBox.values.toList();

  static List<EventModel> getActiveEvents() =>
      _eventsBox.values.where((e) => !e.isArchived).toList()
        ..sort((a, b) => a.targetDateTime.compareTo(b.targetDateTime));

  static List<EventModel> getArchivedEvents() =>
      _eventsBox.values.where((e) => e.isArchived).toList()
        ..sort((a, b) => b.targetDateTime.compareTo(a.targetDateTime));

  static EventModel? getEvent(String id) {
    try {
      return _eventsBox.values.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveEvent(EventModel event) async {
    await _eventsBox.put(event.id, event);
  }

  static Future<void> deleteEvent(String id) async {
    await _eventsBox.delete(id);
    // Also delete associated reminders
    final reminders = getRemindersForEvent(id);
    for (final r in reminders) {
      await _remindersBox.delete(r.id);
    }
  }

  static Future<void> archiveEvent(String id) async {
    final event = getEvent(id);
    if (event != null) {
      event.isArchived = true;
      await event.save();
    }
  }

  static Future<void> unarchiveEvent(String id) async {
    final event = getEvent(id);
    if (event != null) {
      event.isArchived = false;
      await event.save();
    }
  }

  // ─── Reminders ─────────────────────────────────────────
  static Box<ReminderModel> get remindersBox => _remindersBox;

  static List<ReminderModel> getRemindersForEvent(String eventId) =>
      _remindersBox.values.where((r) => r.eventId == eventId).toList();

  static Future<void> saveReminder(ReminderModel reminder) async {
    await _remindersBox.put(reminder.id, reminder);
  }

  static Future<void> deleteReminder(String id) async {
    await _remindersBox.delete(id);
  }

  // ─── Settings ──────────────────────────────────────────
  static AppSettingsModel getSettings() {
    return _settingsBox.get(settingsKey) ?? AppSettingsModel();
  }

  static Future<void> saveSettings(AppSettingsModel settings) async {
    await _settingsBox.put(settingsKey, settings);
  }

  // ─── Reset ─────────────────────────────────────────────
  static Future<void> resetAll() async {
    await _eventsBox.clear();
    await _remindersBox.clear();
    await _settingsBox.clear();
  }

  // ─── Backup helpers ────────────────────────────────────
  static Map<String, dynamic> exportAll() {
    return {
      'events': getAllEvents().map((e) => e.toJson()).toList(),
      'reminders': _remindersBox.values.map((r) => r.toJson()).toList(),
      'settings': getSettings().toJson(),
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };
  }

  static Future<void> importAll(Map<String, dynamic> data) async {
    await _eventsBox.clear();
    await _remindersBox.clear();

    final events = (data['events'] as List?)
        ?.map((e) => EventModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    if (events != null) {
      for (final event in events) {
        await _eventsBox.put(event.id, event);
      }
    }

    final reminders = (data['reminders'] as List?)
        ?.map((r) => ReminderModel.fromJson(Map<String, dynamic>.from(r)))
        .toList();
    if (reminders != null) {
      for (final reminder in reminders) {
        await _remindersBox.put(reminder.id, reminder);
      }
    }

    if (data['settings'] != null) {
      final settings = AppSettingsModel.fromJson(
          Map<String, dynamic>.from(data['settings']));
      await saveSettings(settings);
    }
  }
}
