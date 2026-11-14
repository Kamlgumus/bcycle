import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage {
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;

  const OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      emoji: '🚴',
      title: 'Pedal Say, Hisset!',
      subtitle:
          'Bisiklet sürerken ivmeölçer ile pedal sayımı yapılır. Hızın, mesafen ve kadansın gerçek zamanlı takip edilir.',
      gradientColors: [const Color(0xFF7C3AED), const Color(0xFF4C1D95)],
    ),
    OnboardingPage(
      emoji: '🎵',
      title: 'Çevrimdışı Müzik',
      subtitle:
          'İnternet olmadan da çalışır! 15+ şarkı ile parkurunda en güzel müzikleri dinle. Shuffle, repeat, volume — tam kontrol.',
      gradientColors: [const Color(0xFF0891B2), const Color(0xFF1E1B4B)],
    ),
    OnboardingPage(
      emoji: '👥',
      title: 'Arkadaşlarınla Bin!',
      subtitle:
          'Kullanıcı adı ile arkadaş ekle, birbirinizin konumunu görün. Annen de nerede olduğunu takip edebilir!',
      gradientColors: [const Color(0xFF059669), const Color(0xFF064E3B)],
    ),
    OnboardingPage(
      emoji: '⌚',
      title: 'Aikela Saat Desteği',
      subtitle:
          'Aikela akıllı saatini bağla! Kalp atış hızı, pil ve adım verileri doğrudan uygulamana gelsin.',
      gradientColors: [const Color(0xFFD97706), const Color(0xFF78350F)],
    ),
    OnboardingPage(
      emoji: '🎮',
      title: 'Eğlenmeyi Unutma!',
      subtitle:
          'Bisiklet sürerken oyunlar oyna! Kelime oyunları, tahmin oyunları ve daha fazlası — internet gerekmez.',
      gradientColors: [const Color(0xFFEC4899), const Color(0xFF831843)],
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0A0A0F),
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, i) => _buildPage(_pages[i]),
              ),
            ),

            // Navigasyon
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: i == _currentPage
                              ? const Color(0xFF7C3AED)
                              : Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Buton
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          context.go('/register');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage < _pages.length - 1
                            ? 'Devam Et →'
                            : 'Hadi Başlayalım! 🚀',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Nunito',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  if (_currentPage < _pages.length - 1) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: Text(
                        'Atla',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontFamily: 'Nunito',
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 80, 32, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji büyük
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: page.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: page.gradientColors[0].withOpacity(0.4),
                  blurRadius: 50,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Text(
                page.emoji,
                style: const TextStyle(fontSize: 72),
              ),
            ),
          )
              .animate()
              .scale(curve: Curves.elasticOut, duration: 600.ms)
              .fade(duration: 400.ms),

          const SizedBox(height: 48),

          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFamily: 'Nunito',
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),

          const SizedBox(height: 20),

          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.7),
              fontFamily: 'Nunito',
              height: 1.6,
            ),
          ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }
}
