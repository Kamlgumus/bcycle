import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RideData {
  final bool isRiding;
  final int pedalCount;
  final double speedKmh;
  final double distanceKm;
  final int durationSeconds;
  final double calories;
  final double avgSpeedKmh;
  final double maxSpeedKmh;
  final List<Position> route;

  const RideData({
    this.isRiding = false,
    this.pedalCount = 0,
    this.speedKmh = 0,
    this.distanceKm = 0,
    this.durationSeconds = 0,
    this.calories = 0,
    this.avgSpeedKmh = 0,
    this.maxSpeedKmh = 0,
    this.route = const [],
  });

  RideData copyWith({
    bool? isRiding,
    int? pedalCount,
    double? speedKmh,
    double? distanceKm,
    int? durationSeconds,
    double? calories,
    double? avgSpeedKmh,
    double? maxSpeedKmh,
    List<Position>? route,
  }) {
    return RideData(
      isRiding: isRiding ?? this.isRiding,
      pedalCount: pedalCount ?? this.pedalCount,
      speedKmh: speedKmh ?? this.speedKmh,
      distanceKm: distanceKm ?? this.distanceKm,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      calories: calories ?? this.calories,
      avgSpeedKmh: avgSpeedKmh ?? this.avgSpeedKmh,
      maxSpeedKmh: maxSpeedKmh ?? this.maxSpeedKmh,
      route: route ?? this.route,
    );
  }

  String get formattedDuration {
    final h = durationSeconds ~/ 3600;
    final m = (durationSeconds % 3600) ~/ 60;
    final s = durationSeconds % 60;
    if (h > 0) return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class RideService extends StateNotifier<RideData> {
  RideService() : super(const RideData());

  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<Position>? _locationSub;
  Timer? _durationTimer;

  // Pedal algılama için
  double _lastZ = 0;
  bool _pedalUp = false;
  DateTime _lastPedalTime = DateTime.now();
  List<double> _speedHistory = [];

  Future<void> startRide() async {
    if (state.isRiding) return;
    state = const RideData(isRiding: true);

    // Konum izni
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // GPS takibi
    if (serviceEnabled && permission != LocationPermission.deniedForever) {
      _locationSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 5, // 5 metre
        ),
      ).listen(_onPosition);
    }

    // İvmeölçer ile pedal algılama
    _accelSub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 100),
    ).listen(_onAccelerometer);

    // Süre sayacı
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(durationSeconds: state.durationSeconds + 1);
    });
  }

  void _onAccelerometer(AccelerometerEvent event) {
    // Pedal algılama: Z ekseninde dönüş hareketi
    // Bisiklette, pedal çevirirken ivme değeri düzenli salınım yapar
    final double z = event.z;
    final double magnitude = math.sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    // Basit eşik tabanlı pedal algılama
    if (!_pedalUp && z > _lastZ + 2.0 && magnitude > 12) {
      _pedalUp = true;
      final now = DateTime.now();
      final diff = now.difference(_lastPedalTime).inMilliseconds;
      
      if (diff > 300 && diff < 3000) { // 20-200 RPM aralığı
        final newPedalCount = state.pedalCount + 1;
        // Kalori: yaklaşık pedal başına ağırlık * faktör
        final calories = newPedalCount * 0.1;
        state = state.copyWith(
          pedalCount: newPedalCount,
          calories: calories,
        );
      }
      _lastPedalTime = now;
    } else if (_pedalUp && z < _lastZ - 2.0) {
      _pedalUp = false;
    }
    _lastZ = z;
  }

  void _onPosition(Position position) {
    final route = [...state.route, position];
    double speed = position.speed * 3.6; // m/s → km/h
    if (speed < 0) speed = 0;

    _speedHistory.add(speed);
    if (_speedHistory.length > 20) _speedHistory.removeAt(0);

    final avgSpeed = _speedHistory.isEmpty
        ? 0.0
        : _speedHistory.reduce((a, b) => a + b) / _speedHistory.length;

    double distance = state.distanceKm;
    if (route.length >= 2) {
      final prev = route[route.length - 2];
      final curr = route.last;
      distance += Geolocator.distanceBetween(
            prev.latitude,
            prev.longitude,
            curr.latitude,
            curr.longitude,
          ) /
          1000;
    }

    state = state.copyWith(
      speedKmh: speed,
      avgSpeedKmh: avgSpeed,
      maxSpeedKmh: speed > state.maxSpeedKmh ? speed : state.maxSpeedKmh,
      distanceKm: distance,
      route: route,
    );
  }

  Future<void> stopRide() async {
    _accelSub?.cancel();
    _locationSub?.cancel();
    _durationTimer?.cancel();
    state = state.copyWith(isRiding: false);
  }

  void pauseRide() {
    _accelSub?.pause();
    _locationSub?.pause();
    _durationTimer?.cancel();
    state = state.copyWith(isRiding: false);
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _locationSub?.cancel();
    _durationTimer?.cancel();
    super.dispose();
  }
}

final rideServiceProvider = StateNotifierProvider<RideService, RideData>(
  (ref) => RideService(),
);
