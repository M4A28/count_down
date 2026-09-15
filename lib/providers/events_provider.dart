import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/reminder_model.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';
import 'package:uuid/uuid.dart';

class EventsProvider extends ChangeNotifier {
  List<EventModel> _activeEvents = [];
  List<EventModel> _archivedEvents = [];
  String _searchQuery = '';

  List<EventModel> get activeEvents {
    if (_searchQuery.isEmpty) return _activeEvents;
    return _activeEvents
        .where((e) => e.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<EventModel> get archivedEvents {
    if (_searchQuery.isEmpty) return _archivedEvents;
    return _archivedEvents
        .where((e) => e.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  String get searchQuery => _searchQuery;

  void loadEvents() {
    _activeEvents = HiveService.getActiveEvents();
    _archivedEvents = HiveService.getArchivedEvents();
    _rescheduleAllNotifications();
    notifyListeners();
  }

  Future<void> _rescheduleAllNotifications() async {
    await NotificationService().cancelAll();
    for (final event in _activeEvents) {
      if (event.notificationsEnabled && !event.isExpired) {
        final reminders = HiveService.getRemindersForEvent(event.id);
        await NotificationService().scheduleEventNotifications(event, reminders);
      }
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addEvent(EventModel event) async {
    await HiveService.saveEvent(event);
    loadEvents();
  }

  Future<void> updateEvent(EventModel event) async {
    await HiveService.saveEvent(event);
    loadEvents();
  }

  Future<void> deleteEvent(String id) async {
    final event = getEvent(id);
    if (event != null) {
      await NotificationService().cancelEventNotifications(
          event, HiveService.getRemindersForEvent(event.id));
    }
    await HiveService.deleteEvent(id);
    loadEvents();
  }

  Future<void> archiveEvent(String id) async {
    await HiveService.archiveEvent(id);
    loadEvents();
  }

  Future<void> unarchiveEvent(String id) async {
    await HiveService.unarchiveEvent(id);
    loadEvents();
  }

  EventModel? getEvent(String id) => HiveService.getEvent(id);

  // ─── Reminders ─────────────────────────────────────
  List<ReminderModel> getReminders(String eventId) =>
      HiveService.getRemindersForEvent(eventId);

  Future<void> addReminder(ReminderModel reminder) async {
    await HiveService.saveReminder(reminder);
    final event = getEvent(reminder.eventId);
    if (event != null) {
      await NotificationService().scheduleEventNotifications(
          event, HiveService.getRemindersForEvent(event.id));
    }
    notifyListeners();
  }

  Future<void> deleteReminder(String id) async {
    final reminder = HiveService.remindersBox.values.firstWhere((r) => r.id == id);
    final eventId = reminder.eventId;
    await HiveService.deleteReminder(id);
    final event = getEvent(eventId);
    if (event != null) {
      await NotificationService().scheduleEventNotifications(
          event, HiveService.getRemindersForEvent(event.id));
    }
    notifyListeners();
  }
  // ─── Auto-archive expired events ──────────────────
  Future<void> autoArchiveExpired() async {
    for (final event in _activeEvents) {
      if (event.isExpired && event.recurrenceType == 0) {
        await HiveService.archiveEvent(event.id);
      }
    }
    loadEvents();
  }

  // ─── Handle recurring events ──────────────────────
  Future<void> handleRecurringEvents() async {
    for (final event in _activeEvents) {
      if (event.isExpired && event.recurrenceType > 0) {
        DateTime nextDate;
        switch (event.recurrenceType) {
          case 1: // daily
            nextDate = event.targetDateTime.add(const Duration(days: 1));
            break;
          case 2: // weekly
            nextDate = event.targetDateTime.add(const Duration(days: 7));
            break;
          case 3: // monthly
            nextDate = DateTime(
              event.targetDateTime.year,
              event.targetDateTime.month + 1,
              event.targetDateTime.day,
              event.targetDateTime.hour,
              event.targetDateTime.minute,
            );
            break;
          case 4: // yearly
            nextDate = DateTime(
              event.targetDateTime.year + 1,
              event.targetDateTime.month,
              event.targetDateTime.day,
              event.targetDateTime.hour,
              event.targetDateTime.minute,
            );
            break;
          default:
            continue;
        }
        // Update the existing event's target date
        event.targetDateTime = nextDate;
        event.createdAt = DateTime.now();
        await HiveService.saveEvent(event);
      }
    }
    loadEvents();
  }
}
