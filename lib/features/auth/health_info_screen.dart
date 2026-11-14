import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/models/user_model.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/glass_card.dart';

class HealthInfoScreen extends ConsumerStatefulWidget {
  const HealthInfoScreen({super.key});

  @override
  ConsumerState<HealthInfoScreen> createState() => _HealthInfoScreenState();
}

class _HealthInfoScreenState extends ConsumerState<HealthInfoScreen> {
  int _age = 16;
  double _weightKg = 60;
  double _heightCm = 165;
  String _gender = 'female';
  int _dailyStepGoal = 10000;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0F), Color(0xFF0F0A20), Color(0xFF0A0A0F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Üst çubuk
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('🏥',
                          style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sağlık Bilgilerin',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontFamily: 'Nunito',
                            ),
                          ),
                          Text(
                            'Kalori & adım hesabı için kullanılır',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontFamily: 'Nunito',
                              fontSize: 13,
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
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // Cinsiyet seçimi
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionLabel('Cinsiyet'),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _genderBtn('Kız', 'female', '👧'),
                                  const SizedBox(width: 10),
                                  _genderBtn('Erkek', 'male', '👦'),
                                  const SizedBox(width: 10),
                                  _genderBtn('Diğer', 'other', '🌟'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 100.ms),

                      const SizedBox(height: 16),

                      // Yaş
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionLabel('Yaş: $_age'),
                              Slider(
                                value: _age.toDouble(),
                                min: 6,
                                max: 80,
                                divisions: 74,
                                activeColor: AppTheme.primary,
                                inactiveColor:
                                    AppTheme.primary.withOpacity(0.2),
                                label: '$_age yaş',
                                onChanged: (v) =>
                                    setState(() => _age = v.round()),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 16),

                      // Ağırlık
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionLabel(
                                  'Kilo: ${_weightKg.toStringAsFixed(1)} kg'),
                              Slider(
                                value: _weightKg,
                                min: 20,
                                max: 150,
                                divisions: 130,
                                activeColor: AppTheme.secondary,
                                inactiveColor:
                                    AppTheme.secondary.withOpacity(0.2),
                                label: '${_weightKg.toStringAsFixed(0)} kg',
                                onChanged: (v) =>
                                    setState(() => _weightKg = v),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 300.ms),

                      const SizedBox(height: 16),

                      // Boy
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionLabel(
                                  'Boy: ${_heightCm.toStringAsFixed(0)} cm'),
                              Slider(
                                value: _heightCm,
                                min: 100,
                                max: 220,
                                divisions: 120,
                                activeColor: AppTheme.accent,
                                inactiveColor:
                                    AppTheme.accent.withOpacity(0.2),
                                label: '${_heightCm.toStringAsFixed(0)} cm',
                                onChanged: (v) =>
                                    setState(() => _heightCm = v),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 400.ms),

                      const SizedBox(height: 16),

                      // Günlük adım hedefi
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionLabel(
                                  'Günlük Adım Hedefi: ${_dailyStepGoal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}'),
                              Slider(
                                value: _dailyStepGoal.toDouble(),
                                min: 2000,
                                max: 30000,
                                divisions: 28,
                                activeColor: AppTheme.green,
                                inactiveColor:
                                    AppTheme.green.withOpacity(0.2),
                                label: '$_dailyStepGoal',
                                onChanged: (v) => setState(
                                    () => _dailyStepGoal =
                                        (v / 1000).round() * 1000),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 500.ms),

                      const SizedBox(height: 16),

                      // BMI göstergesi
                      _buildBmiCard(),

                      const SizedBox(height: 32),

                      // Kaydet
                      GradientButton(
                        onPressed: _isLoading ? null : _save,
                        label: 'Uygulamayı Başlat! 🚴',
                        icon: Icons.check_circle_outline,
                        isLoading: _isLoading,
                      ).animate().fadeIn(delay: 600.ms),

                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _skip,
                        child: Text(
                          'Şimdilik atla (sonra profilden düzenleyebilirsin)',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontFamily: 'Nunito',
                            fontSize: 13,
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

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontFamily: 'Nunito',
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _genderBtn(String label, String value, String emoji) {
    final selected = _gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: selected
                ? const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary])
                : null,
            color: selected ? null : Colors.white.withOpacity(0.07),
            border: Border.all(
              color: selected
                  ? AppTheme.primary
                  : Colors.white.withOpacity(0.1),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppTheme.textSecondary,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBmiCard() {
    if (_weightKg == 0 || _heightCm == 0) return const SizedBox.shrink();
    final bmi = _weightKg / ((_heightCm / 100) * (_heightCm / 100));
    String category;
    Color color;
    String emoji;

    if (bmi < 18.5) {
      category = 'Zayıf';
      color = Colors.blue;
      emoji = '😟';
    } else if (bmi < 25) {
      category = 'Normal ✨';
      color = AppTheme.green;
      emoji = '😊';
    } else if (bmi < 30) {
      category = 'Fazla Kilolu';
      color = AppTheme.gold;
      emoji = '😐';
    } else {
      category = 'Obez';
      color = Colors.red;
      emoji = '😰';
    }

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VKİ (BMI): ${bmi.toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    category,
                    style: TextStyle(
                      color: color,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id');
      if (userId == null) return;

      final box = Hive.box<UserModel>('users');
      final user = box.get(userId);
      if (user == null) return;

      final updated = user.copyWith(
        age: _age,
        weightKg: _weightKg,
        heightCm: _heightCm,
        gender: _gender,
        dailyStepGoal: _dailyStepGoal,
      );
      await box.put(userId, updated);

      // İzinleri iste
      await _requestPermissions();

      if (mounted) context.go('/home');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.activityRecognition,
      Permission.location,
      Permission.locationWhenInUse,
      Permission.notification,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
  }

  Future<void> _skip() async {
    await _requestPermissions();
    if (mounted) context.go('/home');
  }
}
