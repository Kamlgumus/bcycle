// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_model.dart';

class SongModelAdapter extends TypeAdapter<SongModel> {
  @override
  final int typeId = 2;

  @override
  SongModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SongModel(
      id: fields[0] as String,
      title: fields[1] as String,
      artist: fields[2] as String,
      album: fields[3] as String,
      assetPath: fields[4] as String,
      duration: fields[5] as String,
      genre: fields[6] as String,
      emoji: fields[7] as String,
      isFavorite: fields[8] as bool,
      playCount: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SongModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.artist)
      ..writeByte(3)
      ..write(obj.album)
      ..writeByte(4)
      ..write(obj.assetPath)
      ..writeByte(5)
      ..write(obj.duration)
      ..writeByte(6)
      ..write(obj.genre)
      ..writeByte(7)
      ..write(obj.emoji)
      ..writeByte(8)
      ..write(obj.isFavorite)
      ..writeByte(9)
      ..write(obj.playCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
