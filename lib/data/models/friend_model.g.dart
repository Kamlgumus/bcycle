// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_model.dart';

class FriendModelAdapter extends TypeAdapter<FriendModel> {
  @override
  final int typeId = 1;

  @override
  FriendModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FriendModel(
      id: fields[0] as String,
      username: fields[1] as String,
      displayName: fields[2] as String,
      status: fields[3] as String,
      addedAt: fields[4] as DateTime,
      avatarPath: fields[5] as String?,
      lastLatitude: fields[6] as double?,
      lastLongitude: fields[7] as double?,
      lastSeen: fields[8] as DateTime?,
      isOnline: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, FriendModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.displayName)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.addedAt)
      ..writeByte(5)
      ..write(obj.avatarPath)
      ..writeByte(6)
      ..write(obj.lastLatitude)
      ..writeByte(7)
      ..write(obj.lastLongitude)
      ..writeByte(8)
      ..write(obj.lastSeen)
      ..writeByte(9)
      ..write(obj.isOnline);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
