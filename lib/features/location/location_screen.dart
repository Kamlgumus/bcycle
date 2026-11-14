import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/ride_service.dart';
import '../../data/models/friend_model.dart';
import '../../features/friends/friends_screen.dart';
import '../../shared/widgets/glass_card.dart';

class LocationScreen extends ConsumerStatefulWidget {
  const LocationScreen({super.key});

  @override
  ConsumerState<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends ConsumerState<LocationScreen> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  StreamSubscription<Position>? _locationSub;
  bool _locationSharing = true;
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  Future<void> _startLocationUpdates() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (!serviceEnabled ||
        permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = pos;
        _loadingLocation = false;
      });

      try {
        _mapController.move(
            LatLng(pos.latitude, pos.longitude), 15);
      } catch (_) {}

      _locationSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((pos) {
        setState(() => _currentPosition = pos);
        if (_locationSharing) {
          try {
            _mapController.move(LatLng(pos.latitude, pos.longitude), 15);
          } catch (_) {}
        }
      });
    } else {
      setState(() => _loadingLocation = false);
    }
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friends = ref.watch(friendsProvider);
    final acceptedFriends = friends.where((f) => f.status == 'accepted').toList();
    final rideData = ref.watch(rideServiceProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFF0A0A0F)),
        child: SafeArea(
          child: Column(
            children: [
              // Üst çubuk
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/home'),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        '📍 Konum Takibi',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    // Paylaşım toggle
                    GestureDetector(
                      onTap: () =>
                          setState(() => _locationSharing = !_locationSharing),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _locationSharing
                              ? AppTheme.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _locationSharing
                                ? AppTheme.green.withOpacity(0.5)
                                : Colors.red.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _locationSharing
                                  ? Icons.location_on_rounded
                                  : Icons.location_off_rounded,
                              color: _locationSharing
                                  ? AppTheme.green
                                  : Colors.red,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _locationSharing ? 'Paylaşılıyor' : 'Gizli',
                              style: TextStyle(
                                color: _locationSharing
                                    ? AppTheme.green
                                    : Colors.red,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Harita
              Expanded(
                flex: 3,
                child: _loadingLocation
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                                color: AppTheme.primary),
                            SizedBox(height: 16),
                            Text(
                              'Konum alınıyor...',
                              style: TextStyle(
                                  color: Colors.white, fontFamily: 'Nunito'),
                            ),
                          ],
                        ),
                      )
                    : _currentPosition == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_off,
                                    color: Colors.red, size: 48),
                                const SizedBox(height: 16),
                                const Text(
                                  'Konum izni yok!',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Nunito',
                                      fontSize: 18),
                                ),
                                TextButton(
                                  onPressed: () => Geolocator.openAppSettings(),
                                  child: const Text('Ayarlara Git',
                                      style: TextStyle(
                                          color: AppTheme.primary,
                                          fontFamily: 'Nunito')),
                                ),
                              ],
                            ),
                          )
                        : ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(0),
                            ),
                            child: FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: LatLng(
                                  _currentPosition!.latitude,
                                  _currentPosition!.longitude,
                                ),
                                initialZoom: 15,
                              ),
                              children: [
                                // OpenStreetMap tile (çevrimiçi, ücretsiz)
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.bcycle.app',
                                ),

                                // Rota çizgisi
                                if (rideData.route.length > 1)
                                  PolylineLayer(
                                    polylines: [
                                      Polyline(
                                        points: rideData.route
                                            .map((p) => LatLng(
                                                p.latitude, p.longitude))
                                            .toList(),
                                        strokeWidth: 4,
                                        color: AppTheme.primary,
                                      ),
                                    ],
                                  ),

                                // Benim konumum
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(
                                        _currentPosition!.latitude,
                                        _currentPosition!.longitude,
                                      ),
                                      width: 60,
                                      height: 60,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppTheme.primary
                                              .withOpacity(0.2),
                                        ),
                                        child: Center(
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppTheme.primary,
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 3),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Arkadaş konumları (simüle)
                                    ...acceptedFriends
                                        .where((f) =>
                                            f.lastLatitude != null &&
                                            f.lastLongitude != null)
                                        .map(
                                          (f) => Marker(
                                            point: LatLng(
                                              f.lastLatitude!,
                                              f.lastLongitude!,
                                            ),
                                            width: 50,
                                            height: 50,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppTheme.secondary
                                                    .withOpacity(0.2),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  f.displayName.isNotEmpty
                                                      ? f.displayName[0]
                                                      : '?',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Nunito',
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                  ],
                                ),
                              ],
                            ),
                          ),
              ),

              // Alt bilgi paneli
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Mevcut konum
                      if (_currentPosition != null)
                        GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                const Icon(Icons.my_location_rounded,
                                    color: AppTheme.primary, size: 24),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Senin Konumun',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Nunito',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        '${_currentPosition!.latitude.toStringAsFixed(5)}, ${_currentPosition!.longitude.toStringAsFixed(5)}',
                                        style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontFamily: 'Nunito',
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        'Hız: ${(_currentPosition!.speed * 3.6).toStringAsFixed(1)} km/h • '
                                        'Yükseklik: ${_currentPosition!.altitude.toStringAsFixed(0)} m',
                                        style: const TextStyle(
                                          color: AppTheme.textMuted,
                                          fontFamily: 'Nunito',
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 10),

                      // Annene paylaşma kartı
                      GlassCard(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4C1D95), Color(0xFF1E1B4B)],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              const Text('👩', style: TextStyle(fontSize: 28)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Anne Takip Modu',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Nunito',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      _locationSharing
                                          ? '✅ Konumun arkadaşlarınla paylaşılıyor'
                                          : '❌ Konum paylaşımı kapalı',
                                      style: TextStyle(
                                        color: _locationSharing
                                            ? AppTheme.green
                                            : Colors.red.withOpacity(0.8),
                                        fontFamily: 'Nunito',
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _locationSharing,
                                onChanged: (v) =>
                                    setState(() => _locationSharing = v),
                                activeColor: AppTheme.green,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Arkadaş listesi (konumla)
                      if (acceptedFriends.isNotEmpty)
                        GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '👥 Arkadaş Konumları',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ...acceptedFriends.map(
                                  (f) => Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppTheme.secondary
                                              .withOpacity(0.3),
                                        ),
                                        child: Center(
                                          child: Text(
                                            f.displayName[0],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Nunito',
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          f.displayName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Nunito',
                                          ),
                                        ),
                                      ),
                                      Text(
                                        f.lastLatitude != null
                                            ? 'Konum var'
                                            : 'Konum yok',
                                        style: TextStyle(
                                          color: f.lastLatitude != null
                                              ? AppTheme.green
                                              : AppTheme.textMuted,
                                          fontFamily: 'Nunito',
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
