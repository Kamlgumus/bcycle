import 'package:hive/hive.dart';

part 'song_model.g.dart';

@HiveType(typeId: 2)
class SongModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String artist;

  @HiveField(3)
  final String album;

  @HiveField(4)
  final String assetPath;

  @HiveField(5)
  final String duration;

  @HiveField(6)
  final String genre;

  @HiveField(7)
  final String emoji;

  @HiveField(8)
  final bool isFavorite;

  @HiveField(9)
  final int playCount;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.assetPath,
    required this.duration,
    required this.genre,
    required this.emoji,
    this.isFavorite = false,
    this.playCount = 0,
  });

  factory SongModel.fromMap(Map<String, String> map) {
    return SongModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      album: map['album'] ?? '',
      assetPath: map['assetPath'] ?? '',
      duration: map['duration'] ?? '0:00',
      genre: map['genre'] ?? '',
      emoji: map['emoji'] ?? '🎵',
    );
  }

  SongModel copyWith({
    bool? isFavorite,
    int? playCount,
  }) {
    return SongModel(
      id: id,
      title: title,
      artist: artist,
      album: album,
      assetPath: assetPath,
      duration: duration,
      genre: genre,
      emoji: emoji,
      isFavorite: isFavorite ?? this.isFavorite,
      playCount: playCount ?? this.playCount,
    );
  }
}
