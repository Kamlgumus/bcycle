import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/step_counter_service.dart';
import '../../data/models/user_model.dart';
import '../../shared/widgets/glass_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('current_user_id');
    if (userId != null) {
      final box = Hive.box<UserModel>('users');
      setState(() {
        _user = box.get(userId);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stepData = ref.watch(stepCounterProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0A20), Color(0xFF0A0A0F), Color(0xFF08121E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Üst Çubuk
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
                      '👤 Profil & Ayarlar',
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
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppTheme.primary))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),

                            // Profil Kartı
                            _buildProfileHeader(),

                            const SizedBox(height: 20),

                            // Sağlık & Biyometri Kartı
                            _buildHealthCard(),

                            const SizedBox(height: 20),

                            // Başarımlar / Rozetler
                            _buildBadgesCard(),

                            const SizedBox(height: 20),

                            // Hızlı Ayarlar
                            _buildSettingsList(),

                            const SizedBox(height: 30),
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

  Widget _buildProfileHeader() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.secondary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _user?.displayName.isNotEmpty == true
                      ? _user!.displayName[0].toUpperCase()
                      : '🚴',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _user?.displayName ?? 'Bisikletçi',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${_user?.username ?? "bcycle_user"}',
                    style: const TextStyle(
                      color: AppTheme.primaryLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.green.withOpacity(0.4)),
                    ),
                    child: const Text(
                      '🏆 Usta Pedalcı',
                      style: TextStyle(
                        color: AppTheme.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildHealthCard() {
    if (_user == null) return const SizedBox.shrink();

    final bmi = _user!.bmi;
    final bmiCat = _user!.bmiCategory;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '❤️ Sağlık & Fiziksel Bilgiler',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Nunito',
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go('/health-info'),
                  child: const Text(
                    'Düzenle',
                    style: TextStyle(
                      color: AppTheme.secondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _metricItem('Yaş', '${_user!.age > 0 ? _user!.age : "--"}', 'yaş'),
                _metricItem('Boy', '${_user!.heightCm > 0 ? _user!.heightCm.toStringAsFixed(0) : "--"}', 'cm'),
                _metricItem('Kilo', '${_user!.weightKg > 0 ? _user!.weightKg.toStringAsFixed(0) : "--"}', 'kg'),
                _metricItem('VKİ (BMI)', bmi > 0 ? bmi.toStringAsFixed(1) : '--', bmiCat),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricItem(String title, String val, String sub) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontFamily: 'Nunito',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          val,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            fontFamily: 'Nunito',
          ),
        ),
        Text(
          sub,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 10,
            fontFamily: 'Nunito',
          ),
        ),
      ],
    );
  }

  Widget _buildBadgesCard() {
    final badges = [
      {'emoji': '⚡', 'title': 'Hızlı Pedal', 'desc': '30 km/h aşıldı'},
      {'emoji': '🌙', 'title': 'Gece Kuşu', 'desc': 'Gece sürüşü'},
      {'emoji': '🎵', 'title': 'Müziksever', 'desc': '50 şarkı çalındı'},
      {'emoji': '⌚', 'title': 'Aikela Dostu', 'desc': 'Saat bağlandı'},
    ];

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🏅 Kazanılan Rozetler',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: badges.map((b) {
                return Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                        border: Border.all(color: AppTheme.gold.withOpacity(0.4)),
                      ),
                      child: Center(
                        child: Text(b['emoji']!, style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      b['title']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList() {
    return GlassCard(
      child: Column(
        children: [
          _settingTile(
            icon: Icons.watch_rounded,
            title: 'Aikela Akıllı Saat Ayarları',
            subtitle: 'Kalp atışı, pil ve adım eşitleme',
            onTap: () => context.go('/home/watch'),
          ),
          Divider(color: Colors.white.withOpacity(0.08), height: 1),
          _settingTile(
            icon: Icons.security_rounded,
            title: 'Anne Takip İzni & Gizlilik',
            subtitle: 'Konum paylaşım izinlerini yönet',
            onTap: () => context.go('/home/location'),
          ),
          Divider(color: Colors.white.withOpacity(0.08), height: 1),
          _settingTile(
            icon: Icons.notifications_active_rounded,
            title: 'Sabit Adım Bildirimi',
            subtitle: 'Silinmeyen bildirim aktif',
            trailing: const Icon(Icons.check_circle_rounded, color: AppTheme.green, size: 20),
            onTap: () {},
          ),
          Divider(color: Colors.white.withOpacity(0.08), height: 1),
          _settingTile(
            icon: Icons.info_outline_rounded,
            title: 'Uygulama Sürümü',
            subtitle: 'BCycle v1.0.0 Pro • Play Store Ready',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.18),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryLight, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          fontFamily: 'Nunito',
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 11,
          fontFamily: 'Nunito',
        ),
      ),
      trailing: trailing ??
          const Icon(Icons.arrow_forward_ios_rounded,
              color: AppTheme.textMuted, size: 14),
      onTap: onTap,
    );
  }
}
