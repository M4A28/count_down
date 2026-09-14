import 'package:hive/hive.dart';

part 'event_model.g.dart';

@HiveType(typeId: 0)
class EventModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime targetDateTime;

  @HiveField(3)
  String timeZone;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  String? imagePath;

  @HiveField(6)
  int? backgroundColor;

  @HiveField(7)
  String? themePreset;

  @HiveField(8)
  String? backgroundImagePath;

  @HiveField(9)
  bool isArchived;

  @HiveField(10)
  bool notificationsEnabled;

  /// 0 = full (days, hours, minutes, seconds)
  /// 1 = days only
  /// 2 = no seconds (days, hours, minutes)
  @HiveField(11)
  int displayFormat;

  /// 0 = once, 1 = daily, 2 = weekly, 3 = monthly, 4 = yearly
  @HiveField(12)
  int recurrenceType;

  @HiveField(13)
  String? soundPath;

  @HiveField(14)
  bool vibrationEnabled;

  @HiveField(15)
  String? calendarEventId;

  EventModel({
    required this.id,
    required this.title,
    required this.targetDateTime,
    this.timeZone = 'local',
    DateTime? createdAt,
    this.imagePath,
    this.backgroundColor,
    this.themePreset,
    this.backgroundImagePath,
    this.isArchived = false,
    this.notificationsEnabled = true,
    this.displayFormat = 0,
    this.recurrenceType = 0,
    this.soundPath,
    this.vibrationEnabled = true,
    this.calendarEventId,
  }) : createdAt = createdAt ?? DateTime.now();

  Duration get remainingDuration {
    final now = DateTime.now();
    if (targetDateTime.isAfter(now)) {
      return targetDateTime.difference(now);
    }
    return Duration.zero;
  }

  bool get isExpired => DateTime.now().isAfter(targetDateTime);

  double get progressPercentage {
    final total = targetDateTime.difference(createdAt).inSeconds;
    if (total <= 0) return 1.0;
    final elapsed = DateTime.now().difference(createdAt).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  EventModel copyWith({
    String? id,
    String? title,
    DateTime? targetDateTime,
    String? timeZone,
    DateTime? createdAt,
    String? imagePath,
    int? backgroundColor,
    String? themePreset,
    String? backgroundImagePath,
    bool? isArchived,
    bool? notificationsEnabled,
    int? displayFormat,
    int? recurrenceType,
    String? soundPath,
    bool? vibrationEnabled,
    String? calendarEventId,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      targetDateTime: targetDateTime ?? this.targetDateTime,
      timeZone: timeZone ?? this.timeZone,
      createdAt: createdAt ?? this.createdAt,
      imagePath: imagePath ?? this.imagePath,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      themePreset: themePreset ?? this.themePreset,
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
      isArchived: isArchived ?? this.isArchived,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      displayFormat: displayFormat ?? this.displayFormat,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      soundPath: soundPath ?? this.soundPath,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      calendarEventId: calendarEventId ?? this.calendarEventId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetDateTime': targetDateTime.toIso8601String(),
      'timeZone': timeZone,
      'createdAt': createdAt.toIso8601String(),
      'imagePath': imagePath,
      'backgroundColor': backgroundColor,
      'themePreset': themePreset,
      'backgroundImagePath': backgroundImagePath,
      'isArchived': isArchived,
      'notificationsEnabled': notificationsEnabled,
      'displayFormat': displayFormat,
      'recurrenceType': recurrenceType,
      'soundPath': soundPath,
      'vibrationEnabled': vibrationEnabled,
      'calendarEventId': calendarEventId,
    };
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      targetDateTime: DateTime.parse(json['targetDateTime'] as String),
      timeZone: json['timeZone'] as String? ?? 'local',
      createdAt: DateTime.parse(json['createdAt'] as String),
      imagePath: json['imagePath'] as String?,
      backgroundColor: json['backgroundColor'] as int?,
      themePreset: json['themePreset'] as String?,
      backgroundImagePath: json['backgroundImagePath'] as String?,
      isArchived: json['isArchived'] as bool? ?? false,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      displayFormat: json['displayFormat'] as int? ?? 0,
      recurrenceType: json['recurrenceType'] as int? ?? 0,
      soundPath: json['soundPath'] as String?,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      calendarEventId: json['calendarEventId'] as String?,
    );
  }
}
