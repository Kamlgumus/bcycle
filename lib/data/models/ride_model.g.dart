// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_model.dart';

class RideModelAdapter extends TypeAdapter<RideModel> {
  @override
  final int typeId = 3;

  @override
  RideModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RideModel(
      id: fields[0] as String,
      startTime: fields[1] as DateTime,
      endTime: fields[2] as DateTime,
      distanceKm: fields[3] as double,
      durationSeconds: fields[4] as int,
      pedalCount: fields[5] as int,
      avgSpeedKmh: fields[6] as double,
      maxSpeedKmh: fields[7] as double,
      calories: fields[8] as double,
      notes: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RideModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.distanceKm)
      ..writeByte(4)
      ..write(obj.durationSeconds)
      ..writeByte(5)
      ..write(obj.pedalCount)
      ..writeByte(6)
      ..write(obj.avgSpeedKmh)
      ..writeByte(7)
      ..write(obj.maxSpeedKmh)
      ..writeByte(8)
      ..write(obj.calories)
      ..writeByte(9)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RideModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
