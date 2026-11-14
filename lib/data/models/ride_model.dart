import 'package:hive/hive.dart';

part 'ride_model.g.dart';

@HiveType(typeId: 3)
class RideModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime startTime;

  @HiveField(2)
  final DateTime endTime;

  @HiveField(3)
  final double distanceKm;

  @HiveField(4)
  final int durationSeconds;

  @HiveField(5)
  final int pedalCount;

  @HiveField(6)
  final double avgSpeedKmh;

  @HiveField(7)
  final double maxSpeedKmh;

  @HiveField(8)
  final double calories;

  @HiveField(9)
  final String? notes;

  RideModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.distanceKm,
    required this.durationSeconds,
    required this.pedalCount,
    required this.avgSpeedKmh,
    required this.maxSpeedKmh,
    required this.calories,
    this.notes,
  });

  String get formattedDuration {
    final h = durationSeconds ~/ 3600;
    final m = (durationSeconds % 3600) ~/ 60;
    final s = durationSeconds % 60;
    if (h > 0) return '${h}s ${m}d ${s}sn';
    return '${m}d ${s}sn';
  }
}
