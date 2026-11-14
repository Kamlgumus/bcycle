import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/ride_service.dart';
import '../../core/services/watch_service.dart';
import '../../shared/widgets/glass_card.dart';

class RideScreen extends ConsumerStatefulWidget {
  const RideScreen({super.key});

  @override
  ConsumerState<RideScreen> createState() => _RideScreenState();
}

class _RideScreenState extends ConsumerState<RideScreen>
    with TickerProviderStateMixin {
  late AnimationController _pedalController;
  late AnimationController _pulseController;
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _pedalController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pedalController.dispose();
    _pulseController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rideData = ref.watch(rideServiceProvider);
    final rideService = ref.read(rideServiceProvider.notifier);
    final watchData = ref.watch(watchServiceProvider);

    // Pedal animasyonu sürüş varsa dönsün
    if (rideData.isRiding && !_pedalController.isAnimating) {
      _pedalController.repeat();
    } else if (!rideData.isRiding) {
      _pedalController.stop();
    }

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: rideData.isRiding
                    ? [
                        const Color(0xFF064E3B),
                        const Color(0xFF0A1628),
                        const Color(0xFF0A0A0F),
                      ]
                    : [
                        const Color(0xFF0A0A0F),
                        const Color(0xFF1A0A2E),
                        const Color(0xFF0A0A0F),
                      ],
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              // Üst çubuk
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/home'),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      '🚴 Bisiklet Sürüşü',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
                    const Spacer(),
                    // Saat bağlantı durumu
                    if (watchData.status == WatchStatus.connected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppTheme.green.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.watch_rounded,
                                color: AppTheme.green, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${watchData.heartRate} bpm',
                              style: const TextStyle(
                                color: AppTheme.green,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Ana bisiklet animasyonu / pedal sayacı
                      _buildPedalCounter(rideData),

                      const SizedBox(height: 24),

                      // İstatistik kartları
                      _buildStatGrid(rideData, watchData),

                      const SizedBox(height: 20),

                      // Hız göstergesi
                      _buildSpeedGauge(rideData),

                      const SizedBox(height: 24),

                      // Kontrol butonları
                      _buildControls(rideData, rideService, context),

                      const SizedBox(height: 20),

                      // Rotayı göster
                      if (rideData.route.isNotEmpty)
                        _buildRouteInfo(rideData),
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

  Widget _buildPedalCounter(RideData rideData) {
    return GlassCard(
      gradient: rideData.isRiding
          ? const LinearGradient(
              colors: [Color(0xFF064E3B), Color(0xFF0A1628)])
          : null,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            // Bisiklet ikonu animasyonu
            RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0).animate(_pedalController),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: rideData.isRiding
                        ? [AppTheme.green, const Color(0xFF064E3B)]
                        : [AppTheme.primary, const Color(0xFF4C1D95)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (rideData.isRiding ? AppTheme.green : AppTheme.primary)
                          .withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.settings_rounded, // Dişli = pedal
                  size: 56,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Pedal sayısı
            Text(
              '${rideData.pedalCount}',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w900,
                fontSize: 56,
              ),
            ),
            Text(
              'Pedal',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 10),

            // Süre
            Text(
              rideData.formattedDuration,
              style: const TextStyle(
                color: AppTheme.secondary,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),

            if (!rideData.isRiding)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  '⚡ Sürüşü başlatmak için aşağıdaki butona bas!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontFamily: 'Nunito',
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  Widget _buildStatGrid(RideData rideData, WatchData watchData) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        _statCard(
          label: 'Hız',
          value: '${rideData.speedKmh.toStringAsFixed(1)}',
          unit: 'km/h',
          icon: Icons.speed_rounded,
          color: AppTheme.secondary,
        ),
        _statCard(
          label: 'Mesafe',
          value: rideData.distanceKm.toStringAsFixed(2),
          unit: 'km',
          icon: Icons.straighten_rounded,
          color: AppTheme.green,
        ),
        _statCard(
          label: 'Kalori',
          value: rideData.calories.toStringAsFixed(0),
          unit: 'kcal',
          icon: Icons.local_fire_department_rounded,
          color: AppTheme.gold,
        ),
        _statCard(
          label: 'Maks Hız',
          value: '${rideData.maxSpeedKmh.toStringAsFixed(1)}',
          unit: 'km/h',
          icon: Icons.flash_on_rounded,
          color: AppTheme.accent,
        ),
        _statCard(
          label: 'Ort. Hız',
          value: '${rideData.avgSpeedKmh.toStringAsFixed(1)}',
          unit: 'km/h',
          icon: Icons.timeline_rounded,
          color: AppTheme.primary,
        ),
        if (watchData.status == WatchStatus.connected)
          _statCard(
            label: 'Nabız',
            value: '${watchData.heartRate}',
            unit: 'bpm',
            icon: Icons.favorite_rounded,
            color: Colors.red,
          )
        else
          _statCard(
            label: 'Rota Noktası',
            value: '${rideData.route.length}',
            unit: 'nokta',
            icon: Icons.map_rounded,
            color: AppTheme.secondary,
          ),
      ],
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontFamily: 'Nunito',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Spacer(),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: color,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
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
    );
  }

  Widget _buildSpeedGauge(RideData rideData) {
    final maxSpeed = 60.0;
    final speedFraction = (rideData.speedKmh / maxSpeed).clamp(0.0, 1.0);

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '⚡ Hız Göstergesi',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${rideData.speedKmh.toStringAsFixed(1)} km/h',
                  style: const TextStyle(
                    color: AppTheme.secondary,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: speedFraction,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  speedFraction < 0.4
                      ? AppTheme.green
                      : speedFraction < 0.7
                          ? AppTheme.gold
                          : Colors.red,
                ),
                minHeight: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0', style: TextStyle(color: Colors.white.withOpacity(0.4), fontFamily: 'Nunito', fontSize: 11)),
                Text('15', style: TextStyle(color: Colors.white.withOpacity(0.4), fontFamily: 'Nunito', fontSize: 11)),
                Text('30', style: TextStyle(color: Colors.white.withOpacity(0.4), fontFamily: 'Nunito', fontSize: 11)),
                Text('45', style: TextStyle(color: Colors.white.withOpacity(0.4), fontFamily: 'Nunito', fontSize: 11)),
                Text('60+ km/h', style: TextStyle(color: Colors.white.withOpacity(0.4), fontFamily: 'Nunito', fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(RideData rideData, RideService service, BuildContext ctx) {
    return Row(
      children: [
        if (!rideData.isRiding)
          Expanded(
            child: GestureDetector(
              onTap: service.startRide,
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [AppTheme.green, Color(0xFF064E3B)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.green.withOpacity(0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 32),
                    SizedBox(width: 8),
                    Text(
                      'Sürüşü Başlat!',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else ...[
          Expanded(
            child: GestureDetector(
              onTap: service.pauseRide,
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pause_rounded, color: Colors.white, size: 28),
                    SizedBox(width: 8),
                    Text(
                      'Duraklat',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: ctx,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF1C1C2E),
                    title: const Text('Sürüşü Bitir?',
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'Nunito')),
                    content: Text(
                      'Toplam: ${rideData.distanceKm.toStringAsFixed(2)} km, ${rideData.formattedDuration}',
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontFamily: 'Nunito'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('İptal',
                            style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontFamily: 'Nunito')),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Bitir',
                            style: TextStyle(
                                color: Colors.red, fontFamily: 'Nunito')),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await service.stopRide();
                }
              },
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Colors.red, Color(0xFF7F1D1D)],
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.stop_rounded, color: Colors.white, size: 28),
                    SizedBox(width: 8),
                    Text(
                      'Bitir',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRouteInfo(RideData rideData) {
    final last = rideData.route.last;
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.location_on_rounded,
                color: AppTheme.accent, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Son Konum',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${last.latitude.toStringAsFixed(5)}, ${last.longitude.toStringAsFixed(5)}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontFamily: 'Nunito',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => context.go('/home/location'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Haritada Gör →',
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
