import 'package:hive/hive.dart';

part 'app_settings_model.g.dart';

@HiveType(typeId: 2)
class AppSettingsModel extends HiveObject {
  @HiveField(0)
  String locale;

  /// 0 = system, 1 = light, 2 = dark
  @HiveField(1)
  int themeMode;

  @HiveField(2)
  int primaryColor;

  /// Minutes from midnight (e.g., 23*60 = 1380 for 11PM)
  @HiveField(3)
  int quietTimeStart;

  /// Minutes from midnight (e.g., 6*60 = 360 for 6AM)
  @HiveField(4)
  int quietTimeEnd;

  @HiveField(5)
  bool weeklyReminderEnabled;

  @HiveField(6)
  bool autoBackupEnabled;

  AppSettingsModel({
    this.locale = 'ar',
    this.themeMode = 0,
    this.primaryColor = 0xFF6C63FF,
    this.quietTimeStart = 1380,
    this.quietTimeEnd = 360,
    this.weeklyReminderEnabled = false,
    this.autoBackupEnabled = false,
  });

  AppSettingsModel copyWith({
    String? locale,
    int? themeMode,
    int? primaryColor,
    int? quietTimeStart,
    int? quietTimeEnd,
    bool? weeklyReminderEnabled,
    bool? autoBackupEnabled,
  }) {
    return AppSettingsModel(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      quietTimeStart: quietTimeStart ?? this.quietTimeStart,
      quietTimeEnd: quietTimeEnd ?? this.quietTimeEnd,
      weeklyReminderEnabled: weeklyReminderEnabled ?? this.weeklyReminderEnabled,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locale': locale,
      'themeMode': themeMode,
      'primaryColor': primaryColor,
      'quietTimeStart': quietTimeStart,
      'quietTimeEnd': quietTimeEnd,
      'weeklyReminderEnabled': weeklyReminderEnabled,
      'autoBackupEnabled': autoBackupEnabled,
    };
  }

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      locale: json['locale'] as String? ?? 'ar',
      themeMode: json['themeMode'] as int? ?? 0,
      primaryColor: json['primaryColor'] as int? ?? 0xFF6C63FF,
      quietTimeStart: json['quietTimeStart'] as int? ?? 1380,
      quietTimeEnd: json['quietTimeEnd'] as int? ?? 360,
      weeklyReminderEnabled: json['weeklyReminderEnabled'] as bool? ?? false,
      autoBackupEnabled: json['autoBackupEnabled'] as bool? ?? false,
    );
  }
}
