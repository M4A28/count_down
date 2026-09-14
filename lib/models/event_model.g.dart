// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventModelAdapter extends TypeAdapter<EventModel> {
  @override
  final int typeId = 0;

  @override
  EventModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EventModel(
      id: fields[0] as String,
      title: fields[1] as String,
      targetDateTime: fields[2] as DateTime,
      timeZone: fields[3] as String,
      createdAt: fields[4] as DateTime?,
      imagePath: fields[5] as String?,
      backgroundColor: fields[6] as int?,
      themePreset: fields[7] as String?,
      backgroundImagePath: fields[8] as String?,
      isArchived: fields[9] as bool,
      notificationsEnabled: fields[10] as bool,
      displayFormat: fields[11] as int,
      recurrenceType: fields[12] as int,
      soundPath: fields[13] as String?,
      vibrationEnabled: fields[14] as bool,
      calendarEventId: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EventModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.targetDateTime)
      ..writeByte(3)
      ..write(obj.timeZone)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.imagePath)
      ..writeByte(6)
      ..write(obj.backgroundColor)
      ..writeByte(7)
      ..write(obj.themePreset)
      ..writeByte(8)
      ..write(obj.backgroundImagePath)
      ..writeByte(9)
      ..write(obj.isArchived)
      ..writeByte(10)
      ..write(obj.notificationsEnabled)
      ..writeByte(11)
      ..write(obj.displayFormat)
      ..writeByte(12)
      ..write(obj.recurrenceType)
      ..writeByte(13)
      ..write(obj.soundPath)
      ..writeByte(14)
      ..write(obj.vibrationEnabled)
      ..writeByte(15)
      ..write(obj.calendarEventId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
