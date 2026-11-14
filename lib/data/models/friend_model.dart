import 'package:hive/hive.dart';

part 'friend_model.g.dart';

@HiveType(typeId: 1)
class FriendModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String displayName;

  @HiveField(3)
  final String status; // 'pending', 'accepted', 'sent'

  @HiveField(4)
  final DateTime addedAt;

  @HiveField(5)
  final String? avatarPath;

  @HiveField(6)
  final double? lastLatitude;

  @HiveField(7)
  final double? lastLongitude;

  @HiveField(8)
  final DateTime? lastSeen;

  @HiveField(9)
  final bool isOnline;

  FriendModel({
    required this.id,
    required this.username,
    required this.displayName,
    required this.status,
    required this.addedAt,
    this.avatarPath,
    this.lastLatitude,
    this.lastLongitude,
    this.lastSeen,
    this.isOnline = false,
  });

  FriendModel copyWith({
    String? status,
    double? lastLatitude,
    double? lastLongitude,
    DateTime? lastSeen,
    bool? isOnline,
  }) {
    return FriendModel(
      id: id,
      username: username,
      displayName: displayName,
      status: status ?? this.status,
      addedAt: addedAt,
      avatarPath: avatarPath,
      lastLatitude: lastLatitude ?? this.lastLatitude,
      lastLongitude: lastLongitude ?? this.lastLongitude,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
