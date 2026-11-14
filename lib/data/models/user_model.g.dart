// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      username: fields[1] as String,
      displayName: fields[2] as String,
      age: fields[3] as int,
      weightKg: fields[4] as double,
      heightCm: fields[5] as double,
      gender: fields[6] as String,
      avatarPath: fields[7] as String?,
      dailyStepGoal: fields[8] as int,
      createdAt: fields[9] as DateTime,
      totalRides: fields[10] as int,
      totalDistanceKm: fields[11] as double,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.displayName)
      ..writeByte(3)
      ..write(obj.age)
      ..writeByte(4)
      ..write(obj.weightKg)
      ..writeByte(5)
      ..write(obj.heightCm)
      ..writeByte(6)
      ..write(obj.gender)
      ..writeByte(7)
      ..write(obj.avatarPath)
      ..writeByte(8)
      ..write(obj.dailyStepGoal)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.totalRides)
      ..writeByte(11)
      ..write(obj.totalDistanceKm);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
