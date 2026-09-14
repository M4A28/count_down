import 'package:flutter/material.dart';
import '../models/app_settings_model.dart';
import '../services/hive_service.dart';

class SettingsProvider extends ChangeNotifier {
  AppSettingsModel _settings = AppSettingsModel();

  AppSettingsModel get settings => _settings;

  Locale get locale => Locale(_settings.locale);

  ThemeMode get themeMode {
    switch (_settings.themeMode) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Color get primaryColor => Color(_settings.primaryColor);

  void loadSettings() {
    _settings = HiveService.getSettings();
    notifyListeners();
  }

  Future<void> setLocale(String locale) async {
    _settings = _settings.copyWith(locale: locale);
    await HiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setThemeMode(int mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    await HiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setPrimaryColor(int color) async {
    _settings = _settings.copyWith(primaryColor: color);
    await HiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setQuietTime(int start, int end) async {
    _settings = _settings.copyWith(quietTimeStart: start, quietTimeEnd: end);
    await HiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setWeeklyReminder(bool enabled) async {
    _settings = _settings.copyWith(weeklyReminderEnabled: enabled);
    await HiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setAutoBackup(bool enabled) async {
    _settings = _settings.copyWith(autoBackupEnabled: enabled);
    await HiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateSettings(AppSettingsModel newSettings) async {
    _settings = newSettings;
    await HiveService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> resetSettings() async {
    _settings = AppSettingsModel();
    await HiveService.saveSettings(_settings);
    notifyListeners();
  }
}
