import 'package:hive/hive.dart';

part 'reminder_model.g.dart';

@HiveType(typeId: 1)
class ReminderModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String eventId;

  /// Offset in minutes before the event (e.g., 60 = 1 hour before, 1440 = 1 day before)
  @HiveField(2)
  int offsetMinutes;

  /// 0 = once, 1 = every hour, 2 = every day
  @HiveField(3)
  int repeatInterval;

  @HiveField(4)
  bool isEnabled;

  ReminderModel({
    required this.id,
    required this.eventId,
    required this.offsetMinutes,
    this.repeatInterval = 0,
    this.isEnabled = true,
  });

  String get label {
    if (offsetMinutes < 60) return '$offsetMinutes min';
    if (offsetMinutes < 1440) return '${offsetMinutes ~/ 60} hr';
    return '${offsetMinutes ~/ 1440} day';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'offsetMinutes': offsetMinutes,
      'repeatInterval': repeatInterval,
      'isEnabled': isEnabled,
    };
  }

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      offsetMinutes: json['offsetMinutes'] as int,
      repeatInterval: json['repeatInterval'] as int? ?? 0,
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }
}
