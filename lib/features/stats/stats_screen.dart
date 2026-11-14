import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/step_counter_service.dart';
import '../../data/models/user_model.dart';
import '../../data/models/ride_model.dart';
import '../../shared/widgets/glass_card.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  UserModel? _user;
  List<RideModel> _rides = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('current_user_id');
    if (userId != null) {
      final userBox = Hive.box<UserModel>('users');
      setState(() => _user = userBox.get(userId));
    }
    final rideBox = Hive.box<RideModel>('rides');
    setState(() => _rides = rideBox.values.toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime)));
  }

  @override
  Widget build(BuildContext context) {
    final stepData = ref.watch(stepCounterProvider);
    final totalRides = _rides.length;
    final totalDistance = _rides.fold(0.0, (s, r) => s + r.distanceKm);
    final totalCalories = _rides.fold(0.0, (s, r) => s + r.calories);
    final totalTime = _rides.fold(0, (s, r) => s + r.durationSeconds);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0A0F), Color(0xFF0A1020)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
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
                      '📊 İstatistikler',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
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
                      const SizedBox(height: 10),

                      // Genel istatistikler
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.4,
                        children: [
                          _statCard('🚴', 'Toplam Sürüş', '$totalRides',
                              'kez', AppTheme.primary),
                          _statCard(
                              '📏',
                              'Toplam Mesafe',
                              totalDistance.toStringAsFixed(1),
                              'km',
                              AppTheme.green),
                          _statCard(
                              '🔥',
                              'Toplam Kalori',
                              totalCalories.toStringAsFixed(0),
                              'kcal',
                              AppTheme.gold),
                          _statCard(
                              '⏱️',
                              'Toplam Süre',
                              _formatTime(totalTime),
                              '',
                              AppTheme.secondary),
                          _statCard('👟', 'Bugün Adım',
                              '${stepData.steps}', 'adım', AppTheme.accent),
                          _statCard(
                              '🎯',
                              'Adım Hedefi',
                              '${((stepData.steps / stepData.dailyGoal) * 100).round()}%',
                              'tamamlandı',
                              Colors.teal),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Haftalık adım grafiği
                      _buildStepChart(),

                      const SizedBox(height: 20),

                      // Son sürüşler
                      if (_rides.isNotEmpty) ...[
                        const Row(
                          children: [
                            Text(
                              '🏁 Son Sürüşler',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ..._rides.take(5).map(_buildRideCard),
                      ] else
                        GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Column(
                                children: [
                                  const Text('🚴', style: TextStyle(fontSize: 48)),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Henüz sürüş kaydın yok!',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontFamily: 'Nunito',
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
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

  Widget _statCard(String emoji, String label, String value, String unit, Color color) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontFamily: 'Nunito',
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
            if (unit.isNotEmpty)
              Text(
                unit,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontFamily: 'Nunito',
                  fontSize: 11,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepChart() {
    // Son 7 günün adım verileri (simüle)
    final data = [4200, 7800, 5500, 9200, 6100, 8800, 10200];
    final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📈 Haftalık Adım Grafiği',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 12000,
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.white.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                    drawVerticalLine: false,
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          return Text(
                            days[value.toInt()],
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontFamily: 'Nunito',
                              fontSize: 11,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  barGroups: data.asMap().entries.map((e) {
                    final isToday = e.key == data.length - 1;
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.toDouble(),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: isToday
                                ? [AppTheme.primary, AppTheme.primaryLight]
                                : [
                                    AppTheme.primary.withOpacity(0.4),
                                    AppTheme.primary.withOpacity(0.6),
                                  ],
                          ),
                          width: 20,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideCard(RideModel ride) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withOpacity(0.2),
              ),
              child: const Center(
                child: Text('🚴', style: TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${ride.startTime.day}.${ride.startTime.month}.${ride.startTime.year}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${ride.distanceKm.toStringAsFixed(2)} km • ${ride.formattedDuration} • ${ride.pedalCount} pedal',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontFamily: 'Nunito',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${ride.avgSpeedKmh.toStringAsFixed(1)} km/h',
                  style: const TextStyle(
                    color: AppTheme.secondary,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${ride.calories.toStringAsFixed(0)} kcal',
                  style: const TextStyle(
                    color: AppTheme.gold,
                    fontFamily: 'Nunito',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) return '${h}s ${m}d';
    return '${m}d';
  }
}
