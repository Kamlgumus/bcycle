import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math' as math;

import '../../data/models/user_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/step_counter_service.dart';
import '../../core/services/ride_service.dart';
import '../../core/services/music_service.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/mini_music_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  int _selectedTab = 0;
  UserModel? _user;
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('current_user_id');
    if (userId != null) {
      final box = Hive.box<UserModel>('users');
      setState(() => _user = box.get(userId));
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stepData = ref.watch(stepCounterProvider);
    final musicState = ref.watch(musicServiceProvider);
    final rideData = ref.watch(rideServiceProvider);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          final t = _bgController.value;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(
                    math.cos(t * math.pi * 2) * 0.5,
                    math.sin(t * math.pi * 2) * 0.5),
                end: Alignment(
                    -math.cos(t * math.pi * 2) * 0.5,
                    -math.sin(t * math.pi * 2) * 0.5),
                colors: const [
                  Color(0xFF0A0A0F),
                  Color(0xFF1A0A2E),
                  Color(0xFF0A1628),
                  Color(0xFF0F0A20),
                ],
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              // İçerik
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // Üst başlık
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Row(
                          children: [
                            // Kullanıcı avatarı
                            GestureDetector(
                              onTap: () => context.go('/home/profile'),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [AppTheme.primary, AppTheme.secondary],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primary.withOpacity(0.4),
                                      blurRadius: 15,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    _user?.displayName.isNotEmpty == true
                                        ? _user!.displayName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'Nunito',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _greeting(),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontFamily: 'Nunito',
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    _user?.displayName ?? 'Pedalcı',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Nunito',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Bildirim
                            GestureDetector(
                              onTap: () => context.go('/home/friends/requests'),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.notifications_outlined,
                                    color: Colors.white, size: 22),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(child: const SizedBox(height: 24)),

                    // Adım sayacı kartı
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildStepCard(stepData),
                      ),
                    ),

                    SliverToBoxAdapter(child: const SizedBox(height: 16)),

                    // Aktif sürüş banner
                    if (rideData.isRiding)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildActiveRideBanner(rideData),
                        ),
                      ),

                    SliverToBoxAdapter(child: const SizedBox(height: 16)),

                    // Hızlı erişim grid
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverGrid(
                        delegate: SliverChildListDelegate([
                          _quickCard(
                            emoji: '🚴',
                            title: 'Bisiklet\nSürüşü',
                            subtitle: rideData.isRiding ? 'Devam ediyor...' : 'Başla',
                            color: const Color(0xFF059669),
                            onTap: () => context.go('/home/ride'),
                            badge: rideData.isRiding ? '●' : null,
                          ),
                          _quickCard(
                            emoji: '🎵',
                            title: 'Müzik\nÇalar',
                            subtitle: musicState.currentSong?.title ?? '15+ Şarkı',
                            color: const Color(0xFF7C3AED),
                            onTap: () => context.go('/home/music'),
                          ),
                          _quickCard(
                            emoji: '👥',
                            title: 'Arkadaşlar',
                            subtitle: 'Ekle & Takip',
                            color: const Color(0xFF0891B2),
                            onTap: () => context.go('/home/friends'),
                          ),
                          _quickCard(
                            emoji: '📍',
                            title: 'Konum\nPaylaş',
                            subtitle: 'Annene göster',
                            color: const Color(0xFFEC4899),
                            onTap: () => context.go('/home/location'),
                          ),
                          _quickCard(
                            emoji: '⌚',
                            title: 'Aikela\nSaat',
                            subtitle: 'Bağla & Yönet',
                            color: const Color(0xFFD97706),
                            onTap: () => context.go('/home/watch'),
                          ),
                          _quickCard(
                            emoji: '🎮',
                            title: 'Oyunlar',
                            subtitle: 'Çevrimdışı Oyna',
                            color: const Color(0xFF7C3AED),
                            onTap: () => context.go('/home/games'),
                          ),
                          _quickCard(
                            emoji: '📊',
                            title: 'İstatistikler',
                            subtitle: 'Geçmişin',
                            color: const Color(0xFF64748B),
                            onTap: () => context.go('/home/stats'),
                          ),
                          _quickCard(
                            emoji: '👤',
                            title: 'Profil',
                            subtitle: 'Ayarlar',
                            color: const Color(0xFF64748B),
                            onTap: () => context.go('/home/profile'),
                          ),
                        ]),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.5,
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(child: const SizedBox(height: 20)),
                  ],
                ),
              ),

              // Mini müzik bar
              if (musicState.currentSong != null)
                MiniMusicBar(
                  onTap: () => context.go('/home/music'),
                ),

              // Alt navigasyon
              _buildBottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(StepData stepData) {
    final progress = (stepData.steps / stepData.dailyGoal).clamp(0.0, 1.0);
    return GlassCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1A0A30), Color(0xFF0A1020)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Text('👟', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                const Text(
                  'Bugünkü Adımlar',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  stepData.steps.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    fontSize: 40,
                  ),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '/ ${stepData.dailyGoal}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontFamily: 'Nunito',
                      fontSize: 16,
                    ),
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${stepData.calories.toStringAsFixed(0)} kcal',
                      style: const TextStyle(
                          color: AppTheme.gold, fontFamily: 'Nunito', fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${stepData.distanceKm.toStringAsFixed(2)} km',
                      style: const TextStyle(
                          color: AppTheme.secondary, fontFamily: 'Nunito', fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildActiveRideBanner(RideData rideData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF064E3B)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withOpacity(0.3),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .fadeOut(duration: 800.ms)
              .then()
              .fadeIn(duration: 800.ms),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sürüş Devam Ediyor',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${rideData.distanceKm.toStringAsFixed(2)} km • ${rideData.formattedDuration} • ${rideData.speedKmh.toStringAsFixed(1)} km/h',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontFamily: 'Nunito',
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.go('/home/ride'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Görüntüle →',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickCard({
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.15),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(emoji,
                          style: const TextStyle(fontSize: 28)),
                      const Spacer(),
                      Icon(Icons.arrow_forward_ios,
                          color: color.withOpacity(0.6), size: 14),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: color,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (badge != null)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(fontSize: 8, color: Colors.white),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .fadeOut(duration: 800.ms)
                    .then()
                    .fadeIn(duration: 800.ms),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100)).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          curve: Curves.easeOut,
        );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF13131F),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(icon: Icons.home_rounded, label: 'Ana Sayfa', index: 0, route: '/home'),
          _navItem(icon: Icons.pedal_bike_rounded, label: 'Sürüş', index: 1, route: '/home/ride'),
          _navItem(icon: Icons.music_note_rounded, label: 'Müzik', index: 2, route: '/home/music'),
          _navItem(icon: Icons.people_rounded, label: 'Arkadaşlar', index: 3, route: '/home/friends'),
          _navItem(icon: Icons.person_rounded, label: 'Profil', index: 4, route: '/home/profile'),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
    required String route,
  }) {
    final selected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedTab = index);
        context.go(route);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected
              ? AppTheme.primary.withOpacity(0.2)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? AppTheme.primaryLight : AppTheme.textMuted,
              size: selected ? 26 : 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppTheme.primaryLight : AppTheme.textMuted,
                fontFamily: 'Nunito',
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Gece Pedalcısı 🌙';
    if (hour < 12) return 'Günaydın! ☀️';
    if (hour < 17) return 'İyi Öğleden Sonralar! 🌤️';
    if (hour < 20) return 'İyi Akşamlar! 🌆';
    return 'İyi Geceler! 🌙';
  }
}
