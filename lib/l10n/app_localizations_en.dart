// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Countdown';

  @override
  String get events => 'Events';

  @override
  String get activeEvents => 'Active';

  @override
  String get archivedEvents => 'Archived';

  @override
  String get addEvent => 'Add Event';

  @override
  String get editEvent => 'Edit Event';

  @override
  String get eventTitle => 'Event Title';

  @override
  String get eventTitleHint => 'Enter event title';

  @override
  String get eventTitleRequired => 'Event title is required';

  @override
  String get dateAndTime => 'Date & Time';

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectTime => 'Select Time';

  @override
  String get timeZone => 'Time Zone';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get confirm => 'Confirm';

  @override
  String get deleteConfirmTitle => 'Delete Event';

  @override
  String get deleteConfirmMessage => 'Are you sure you want to delete this event?';

  @override
  String get archive => 'Archive';

  @override
  String get unarchive => 'Unarchive';

  @override
  String get share => 'Share';

  @override
  String get shareAsImage => 'Share as Image';

  @override
  String get shareAsLink => 'Share as Link';

  @override
  String get search => 'Search events...';

  @override
  String get noEvents => 'No events yet';

  @override
  String get noEventsSubtitle => 'Tap + to add your first countdown';

  @override
  String get noArchivedEvents => 'No archived events';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get theme => 'Theme';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get systemTheme => 'System';

  @override
  String get notifications => 'Notifications';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get reminders => 'Reminders';

  @override
  String get addReminder => 'Add Reminder';

  @override
  String get beforeEvent => 'before event';

  @override
  String get quietTime => 'Quiet Time';

  @override
  String get quietTimeDesc => 'No notifications during this period';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get weeklyReminder => 'Weekly Summary';

  @override
  String get weeklyReminderDesc => 'Remind of all events in the next 7 days';

  @override
  String get sound => 'Sound';

  @override
  String get vibration => 'Vibration';

  @override
  String get displayFormat => 'Display Format';

  @override
  String get fullFormat => 'Full (Days, Hours, Minutes, Seconds)';

  @override
  String get daysOnly => 'Days Only';

  @override
  String get noSeconds => 'Without Seconds';

  @override
  String get recurrence => 'Recurrence';

  @override
  String get once => 'Once';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get image => 'Image';

  @override
  String get addImage => 'Add Image';

  @override
  String get changeImage => 'Change Image';

  @override
  String get removeImage => 'Remove Image';

  @override
  String get fromGallery => 'From Gallery';

  @override
  String get fromCamera => 'From Camera';

  @override
  String get themePreset => 'Theme Preset';

  @override
  String get birthday => 'Birthday';

  @override
  String get wedding => 'Wedding';

  @override
  String get vacation => 'Vacation';

  @override
  String get work => 'Work';

  @override
  String get custom => 'Custom';

  @override
  String get backgroundColor => 'Background Color';

  @override
  String get fullscreenMode => 'Fullscreen Clock';

  @override
  String get keepScreenOn => 'Keep Screen On';

  @override
  String get statistics => 'Statistics';

  @override
  String get progress => 'Progress';

  @override
  String get timeElapsed => 'Time Elapsed';

  @override
  String get timeRemaining => 'Time Remaining';

  @override
  String get motivationalHalf => 'You\'re halfway there! 🎯';

  @override
  String get motivational75 => 'Almost there! 75% done! 🚀';

  @override
  String get motivational90 => 'So close! Just 10% left! ⭐';

  @override
  String get motivational100 => 'Done! 🎉';

  @override
  String get backup => 'Backup & Restore';

  @override
  String get createBackup => 'Create Backup';

  @override
  String get restoreBackup => 'Restore Backup';

  @override
  String get backupSuccess => 'Backup created successfully';

  @override
  String get restoreSuccess => 'Data restored successfully';

  @override
  String get exportCsv => 'Export to CSV';

  @override
  String get exportSuccess => 'Exported successfully';

  @override
  String get importCalendar => 'Import from Calendar';

  @override
  String get selectCalendar => 'Select Calendar';

  @override
  String get resetApp => 'Reset App';

  @override
  String get resetConfirmTitle => 'Reset App';

  @override
  String get resetConfirmMessage => 'This will delete ALL events and reset all settings. This action cannot be undone.';

  @override
  String get resetSuccess => 'App has been reset';

  @override
  String get days => 'days';

  @override
  String get hours => 'hours';

  @override
  String get minutes => 'minutes';

  @override
  String get seconds => 'seconds';

  @override
  String get day => 'day';

  @override
  String get hour => 'hour';

  @override
  String get minute => 'minute';

  @override
  String get second => 'second';

  @override
  String get remaining => 'remaining';

  @override
  String get eventArrived => 'Event has arrived! 🎉';

  @override
  String get ago => 'ago';

  @override
  String minutesBefore(Object count) {
    return '$count minutes before';
  }

  @override
  String hoursBefore(Object count) {
    return '$count hours before';
  }

  @override
  String daysBefore(Object count) {
    return '$count days before';
  }

  @override
  String get eventAddedSuccess => 'Event added successfully! 🎉';

  @override
  String eventAddedNotification(Object title) {
    return 'Countdown started for $title';
  }
}
