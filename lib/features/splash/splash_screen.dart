import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _particleController;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _startLoading();
  }

  Future<void> _startLoading() async {
    for (int i = 0; i <= 100; i += 2) {
      await Future.delayed(const Duration(milliseconds: 40));
      if (mounted) setState(() => _progress = i / 100);
    }
    await _navigate();
  }

  Future<void> _navigate() async {
    final prefs = await SharedPreferences.getInstance();
    final hasUser = prefs.getString('current_user_id') != null;
    if (!mounted) return;
    if (hasUser) {
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0F),
              Color(0xFF1A0A2E),
              Color(0xFF0A1628),
              Color(0xFF0A0A0F),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Arka plan nokta efekti
            ...List.generate(20, (i) => _buildParticle(i)),

            // İçerik
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withOpacity(0.5),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.pedal_bike_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                  )
                      .animate(controller: _logoController)
                      .scale(
                        begin: const Offset(0, 0),
                        end: const Offset(1, 1),
                        curve: Curves.elasticOut,
                      )
                      .fade(),

                  const SizedBox(height: 24),

                  // Uygulama adı
                  const Text(
                    'BCycle',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontFamily: 'Nunito',
                      letterSpacing: 2,
                    ),
                  )
                      .animate(controller: _logoController)
                      .fadeIn(delay: 400.ms)
                      .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 8),

                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
                    ).createShader(bounds),
                    child: const Text(
                      'Bisikletini Hisset 🚴',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  )
                      .animate(controller: _logoController)
                      .fadeIn(delay: 600.ms),

                  const SizedBox(height: 60),

                  // Yükleme çubuğu
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _progress,
                            backgroundColor:
                                Colors.white.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF7C3AED),
                            ),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${(_progress * 100).round()}%',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontFamily: 'Nunito',
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ).animate(controller: _logoController).fadeIn(delay: 800.ms),
                ],
              ),
            ),

            // Alt versiyon metni
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Text(
                'v1.0.0 • BCycle',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontFamily: 'Nunito',
                  fontSize: 12,
                ),
              ).animate().fadeIn(delay: 1.seconds),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticle(int index) {
    final random = (index * 73.13 + 17.5) % 1.0;
    final size = 2.0 + (index % 4).toDouble();
    final left = (index * 47.3 + 11.0) % 100;
    final top = (index * 61.7 + 23.0) % 100;

    return Positioned(
      left: MediaQuery.of(context).size.width * left / 100,
      top: MediaQuery.of(context).size.height * top / 100,
      child: AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          final val = (DateTime.now().millisecondsSinceEpoch / 1000 + random * 10).remainder(2 * math.pi);
          final opacity = (0.3 + 0.7 * (1 + math.cos(val)) / 2).clamp(0.1, 1.0);
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index % 3 == 0
                  ? const Color(0xFF7C3AED).withOpacity(0.4)
                  : index % 3 == 1
                      ? const Color(0xFF06B6D4).withOpacity(0.4)
                      : const Color(0xFFEC4899).withOpacity(0.3),
            ),
          );
        },
      ),
    );
  }
}
