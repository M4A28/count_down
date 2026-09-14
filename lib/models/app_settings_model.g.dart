// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsModelAdapter extends TypeAdapter<AppSettingsModel> {
  @override
  final int typeId = 2;

  @override
  AppSettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettingsModel(
      locale: fields[0] as String,
      themeMode: fields[1] as int,
      primaryColor: fields[2] as int,
      quietTimeStart: fields[3] as int,
      quietTimeEnd: fields[4] as int,
      weeklyReminderEnabled: fields[5] as bool,
      autoBackupEnabled: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettingsModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.locale)
      ..writeByte(1)
      ..write(obj.themeMode)
      ..writeByte(2)
      ..write(obj.primaryColor)
      ..writeByte(3)
      ..write(obj.quietTimeStart)
      ..writeByte(4)
      ..write(obj.quietTimeEnd)
      ..writeByte(5)
      ..write(obj.weeklyReminderEnabled)
      ..writeByte(6)
      ..write(obj.autoBackupEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
