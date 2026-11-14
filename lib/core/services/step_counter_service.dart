import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class StepData {
  final int steps;
  final int dailyGoal;
  final double calories;
  final double distanceKm;
  final int activeMinutes;

  const StepData({
    this.steps = 0,
    this.dailyGoal = 10000,
    this.calories = 0,
    this.distanceKm = 0,
    this.activeMinutes = 0,
  });

  StepData copyWith({
    int? steps,
    int? dailyGoal,
    double? calories,
    double? distanceKm,
    int? activeMinutes,
  }) {
    return StepData(
      steps: steps ?? this.steps,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      calories: calories ?? this.calories,
      distanceKm: distanceKm ?? this.distanceKm,
      activeMinutes: activeMinutes ?? this.activeMinutes,
    );
  }
}

class StepCounterService extends StateNotifier<StepData> {
  StepCounterService() : super(const StepData()) {
    _init();
  }

  StreamSubscription<StepCount>? _stepSubscription;
  StreamSubscription<PedestrianStatus>? _statusSubscription;
  int _initialSteps = -1;
  Timer? _notifTimer;

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedGoal = prefs.getInt('step_goal') ?? 10000;
    final todaySteps = prefs.getInt('today_steps') ?? 0;

    state = state.copyWith(steps: todaySteps, dailyGoal: savedGoal);

    try {
      _stepSubscription = Pedometer.stepCountStream.listen(
        _onStep,
        onError: (e) => print('Adım hatası: $e'),
      );
      _statusSubscription = Pedometer.pedestrianStatusStream.listen(
        _onStatus,
        onError: (e) => print('Durum hatası: $e'),
      );
    } catch (e) {
      print('Pedometer başlatılamadı: $e');
    }

    // Her dakika bildirimi güncelle
    _notifTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateNotification();
    });
    _updateNotification();
  }

  void _onStep(StepCount event) async {
    if (_initialSteps < 0) {
      _initialSteps = event.steps;
    }
    final newSteps = event.steps - _initialSteps + (state.steps);
    final calories = newSteps * 0.04; // Ortalama 0.04 kcal/adım
    final distanceKm = newSteps * 0.000762; // Ortalama adım uzunluğu

    state = state.copyWith(
      steps: newSteps,
      calories: calories,
      distanceKm: distanceKm,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('today_steps', newSteps);
    _updateNotification();
  }

  void _onStatus(PedestrianStatus event) {
    // Yürüme/durma durumu
    print('Yürüme durumu: ${event.status}');
  }

  void _updateNotification() {
    NotificationService.showStepNotification(
      steps: state.steps,
      goal: state.dailyGoal,
      calories: state.calories,
    );
  }

  Future<void> setDailyGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('step_goal', goal);
    state = state.copyWith(dailyGoal: goal);
    _updateNotification();
  }

  Future<void> resetToday() async {
    _initialSteps = -1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('today_steps', 0);
    state = state.copyWith(steps: 0, calories: 0, distanceKm: 0);
    _updateNotification();
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    _statusSubscription?.cancel();
    _notifTimer?.cancel();
    super.dispose();
  }
}

final stepCounterProvider =
    StateNotifierProvider<StepCounterService, StepData>(
  (ref) => StepCounterService(),
);
