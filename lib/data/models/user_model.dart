import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String displayName;

  @HiveField(3)
  final int age;

  @HiveField(4)
  final double weightKg;

  @HiveField(5)
  final double heightCm;

  @HiveField(6)
  final String gender; // 'male', 'female', 'other'

  @HiveField(7)
  final String? avatarPath;

  @HiveField(8)
  final int dailyStepGoal;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final int totalRides;

  @HiveField(11)
  final double totalDistanceKm;

  UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.gender,
    this.avatarPath,
    this.dailyStepGoal = 10000,
    required this.createdAt,
    this.totalRides = 0,
    this.totalDistanceKm = 0,
  });

  UserModel copyWith({
    String? username,
    String? displayName,
    int? age,
    double? weightKg,
    double? heightCm,
    String? gender,
    String? avatarPath,
    int? dailyStepGoal,
    int? totalRides,
    double? totalDistanceKm,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      gender: gender ?? this.gender,
      avatarPath: avatarPath ?? this.avatarPath,
      dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
      createdAt: createdAt,
      totalRides: totalRides ?? this.totalRides,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
    );
  }

  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Zayıf';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Fazla Kilolu';
    return 'Obez';
  }
}
