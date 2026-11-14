import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/glass_card.dart';

// ========= OYUN 1: Kelime Tahmin =========

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  int _selectedGame = -1; // -1 = menu

  @override
  Widget build(BuildContext context) {
    if (_selectedGame == 0) return _WordGuessGame(onBack: () => setState(() => _selectedGame = -1));
    if (_selectedGame == 1) return _MathChallengeGame(onBack: () => setState(() => _selectedGame = -1));
    if (_selectedGame == 2) return _TruthOrDareGame(onBack: () => setState(() => _selectedGame = -1));
    if (_selectedGame == 3) return _EmojiQuizGame(onBack: () => setState(() => _selectedGame = -1));

    // Ana menü
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A0A30), Color(0xFF0A0A0F), Color(0xFF0A1020)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
                      '🎮 Oyunlar',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '📶 Çevrimdışı',
                        style: TextStyle(
                          color: AppTheme.green,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        'Arkadaşınla veya kendi kendine oyna!\nİnternet gerekmez 🚀',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontFamily: 'Nunito',
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          children: [
                            _gameCard(
                              emoji: '🔤',
                              title: 'Kelime\nTahmin',
                              subtitle: '1-2 Oyuncu',
                              description: 'Kelimeyi tahmin et!',
                              color: const Color(0xFF7C3AED),
                              onTap: () => setState(() => _selectedGame = 0),
                            ),
                            _gameCard(
                              emoji: '🔢',
                              title: 'Matematik\nMücadelesi',
                              subtitle: '1 Oyuncu',
                              description: 'Hızlı hesapla!',
                              color: const Color(0xFF059669),
                              onTap: () => setState(() => _selectedGame = 1),
                            ),
                            _gameCard(
                              emoji: '🎯',
                              title: 'Doğru mu\nYanlış mı?',
                              subtitle: '2 Oyuncu',
                              description: 'Yürekli ol!',
                              color: const Color(0xFFEC4899),
                              onTap: () => setState(() => _selectedGame = 2),
                            ),
                            _gameCard(
                              emoji: '😂',
                              title: 'Emoji\nQuiz',
                              subtitle: '1-2 Oyuncu',
                              description: 'Tahmin et!',
                              color: const Color(0xFFD97706),
                              onTap: () => setState(() => _selectedGame = 3),
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
    );
  }

  Widget _gameCard({
    required String emoji,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
          ),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 36)),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: color,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontFamily: 'Nunito',
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }
}

// ========= OYUN 1: Kelime Tahmin =========
class _WordGuessGame extends StatefulWidget {
  final VoidCallback onBack;
  const _WordGuessGame({required this.onBack});

  @override
  State<_WordGuessGame> createState() => _WordGuessGameState();
}

class _WordGuessGameState extends State<_WordGuessGame> {
  final List<Map<String, String>> _words = [
    {'word': 'BİSİKLET', 'hint': '2 tekerlekli araç 🚴'},
    {'word': 'PEDAL', 'hint': 'Ayakla çevirilen kısım'},
    {'word': 'MÜZIK', 'hint': 'Kulağa hoş gelen 🎵'},
    {'word': 'ARKADAŞ', 'hint': 'Birlikte bisiklet sürdüğün kişi'},
    {'word': 'HIZLI', 'hint': 'Yavaşın zıttı'},
    {'word': 'RÜZGAR', 'hint': 'Sürüşte hissedilen 💨'},
    {'word': 'ŞARKI', 'hint': 'Sesli müzik parçası'},
    {'word': 'KAZAN', 'hint': 'Galip olmak'},
    {'word': 'YARIŞ', 'hint': 'Hız yarışması 🏁'},
    {'word': 'MACERA', 'hint': 'Heyecanlı yolculuk'},
  ];

  late String _currentWord;
  late String _hint;
  late List<String?> _guessed;
  late List<String> _wrongLetters;
  final Set<String> _usedLetters = {};
  bool _won = false;
  bool _lost = false;
  int _maxWrong = 6;

  final List<String> _alphabet = [
    'A','B','C','Ç','D','E','F','G','Ğ','H','I','İ','J','K','L','M',
    'N','O','Ö','P','R','S','Ş','T','U','Ü','V','Y','Z'
  ];

  @override
  void initState() {
    super.initState();
    _newWord();
  }

  void _newWord() {
    final random = math.Random();
    final entry = _words[random.nextInt(_words.length)];
    _currentWord = entry['word']!;
    _hint = entry['hint']!;
    _guessed = List.filled(_currentWord.length, null);
    _wrongLetters = [];
    _usedLetters.clear();
    _won = false;
    _lost = false;
    setState(() {});
  }

  void _guess(String letter) {
    if (_usedLetters.contains(letter) || _won || _lost) return;
    _usedLetters.add(letter);

    bool found = false;
    for (int i = 0; i < _currentWord.length; i++) {
      if (_currentWord[i] == letter) {
        _guessed[i] = letter;
        found = true;
      }
    }

    if (!found) _wrongLetters.add(letter);

    if (!_guessed.contains(null)) _won = true;
    if (_wrongLetters.length >= _maxWrong) _lost = true;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4C1D95), Color(0xFF0A0A0F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Üst
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onBack,
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      '🔤 Kelime Tahmin',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_wrongLetters.length}/$_maxWrong ❌',
                      style: const TextStyle(
                        color: Colors.red,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // İpucu
              Text(
                '💡 ${_hint}',
                style: const TextStyle(
                  color: AppTheme.gold,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 20),

              // Kelime kutuları
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: List.generate(_currentWord.length, (i) {
                    return Container(
                      width: 36,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _guessed[i] != null
                              ? AppTheme.green
                              : Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                        color: _guessed[i] != null
                            ? AppTheme.green.withOpacity(0.2)
                            : Colors.white.withOpacity(0.07),
                      ),
                      child: Center(
                        child: Text(
                          _guessed[i] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 10),

              // Yanlış harfler
              if (_wrongLetters.isNotEmpty)
                Text(
                  'Yanlış: ${_wrongLetters.join(', ')}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontFamily: 'Nunito',
                    fontSize: 14,
                  ),
                ),

              const Spacer(),

              // Sonuç
              if (_won)
                _resultBanner('🎉 Tebrikler! Doğru buldun!', AppTheme.green)
              else if (_lost)
                _resultBanner('💀 Kaybettin! Kelime: $_currentWord', Colors.red)
              else ...[
                // Harf klavyesi
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: _alphabet.map((letter) {
                      final used = _usedLetters.contains(letter);
                      final wrong = _wrongLetters.contains(letter);
                      return GestureDetector(
                        onTap: () => _guess(letter),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: used
                                ? (wrong
                                    ? Colors.red.withOpacity(0.3)
                                    : AppTheme.green.withOpacity(0.3))
                                : Colors.white.withOpacity(0.1),
                          ),
                          child: Center(
                            child: Text(
                              letter,
                              style: TextStyle(
                                color: used ? Colors.white.withOpacity(0.4) : Colors.white,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              if (_won || _lost)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: _newWord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Yeni Kelime ➡️',
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.white)),
                  ),
                ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultBanner(String text, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    ).animate().scale();
  }
}

// ========= OYUN 2: Matematik Mücadelesi =========
class _MathChallengeGame extends StatefulWidget {
  final VoidCallback onBack;
  const _MathChallengeGame({required this.onBack});

  @override
  State<_MathChallengeGame> createState() => _MathChallengeGameState();
}

class _MathChallengeGameState extends State<_MathChallengeGame> {
  final _rng = math.Random();
  int _a = 0, _b = 0, _correctAnswer = 0;
  String _op = '+';
  int _score = 0;
  int _timeLeft = 30;
  bool _gameOver = false;
  List<int> _choices = [];
  Timer? _timer;
  int? _selectedAnswer;
  bool? _correct;

  @override
  void initState() {
    super.initState();
    _newQuestion();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _gameOver = true;
          _timer?.cancel();
        }
      });
    });
  }

  void _newQuestion() {
    _a = _rng.nextInt(20) + 1;
    _b = _rng.nextInt(20) + 1;
    _op = ['+', '-', '×'][_rng.nextInt(3)];

    switch (_op) {
      case '+':
        _correctAnswer = _a + _b;
        break;
      case '-':
        if (_b > _a) { final t = _a; _a = _b; _b = t; }
        _correctAnswer = _a - _b;
        break;
      case '×':
        _a = _rng.nextInt(10) + 1;
        _b = _rng.nextInt(10) + 1;
        _correctAnswer = _a * _b;
        break;
    }

    // 4 seçenek: doğru + 3 yanlış
    final wrongs = <int>{};
    while (wrongs.length < 3) {
      final wrong = _correctAnswer + _rng.nextInt(10) - 5;
      if (wrong != _correctAnswer && wrong >= 0) wrongs.add(wrong);
    }
    _choices = [...wrongs, _correctAnswer]..shuffle();
    _selectedAnswer = null;
    _correct = null;
  }

  void _answer(int choice) {
    if (_selectedAnswer != null) return;
    _selectedAnswer = choice;
    _correct = choice == _correctAnswer;
    if (_correct!) _score++;
    setState(() {});

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _newQuestion());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF064E3B), Color(0xFF0A0A0F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onBack,
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 16),
                    const Text('🔢 Matematik',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w900,
                            fontSize: 20)),
                    const Spacer(),
                    Text('Puan: $_score',
                        style: const TextStyle(
                            color: AppTheme.gold,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                  ],
                ),

                const SizedBox(height: 20),

                // Süre çubuğu
                LinearProgressIndicator(
                  value: _timeLeft / 30,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _timeLeft > 10 ? AppTheme.green : Colors.red,
                  ),
                  minHeight: 10,
                ),
                Text('$_timeLeft sn',
                    style: const TextStyle(
                        color: Colors.white, fontFamily: 'Nunito')),

                const Spacer(),

                if (_gameOver) ...[
                  Text('🎮 Oyun Bitti!',
                      style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w900,
                          fontSize: 32)),
                  const SizedBox(height: 10),
                  Text('Puanın: $_score',
                      style: const TextStyle(
                          color: AppTheme.gold,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          fontSize: 24)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _score = 0;
                        _timeLeft = 30;
                        _gameOver = false;
                      });
                      _newQuestion();
                      _startTimer();
                    },
                    child: const Text('Tekrar Oyna',
                        style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ] else ...[
                  // Soru
                  Text(
                    '$_a $_op $_b = ?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      fontSize: 48,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Seçenekler
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.5,
                    children: _choices.map((c) {
                      Color btnColor;
                      if (_selectedAnswer == null) {
                        btnColor = Colors.white.withOpacity(0.1);
                      } else if (c == _correctAnswer) {
                        btnColor = AppTheme.green.withOpacity(0.4);
                      } else if (c == _selectedAnswer) {
                        btnColor = Colors.red.withOpacity(0.4);
                      } else {
                        btnColor = Colors.white.withOpacity(0.07);
                      }

                      return GestureDetector(
                        onTap: () => _answer(c),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: btnColor,
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Center(
                            child: Text(
                              '$c',
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ========= OYUN 3: Doğru mu Yanlış mı? =========
class _TruthOrDareGame extends StatefulWidget {
  final VoidCallback onBack;
  const _TruthOrDareGame({required this.onBack});

  @override
  State<_TruthOrDareGame> createState() => _TruthOrDareGameState();
}

class _TruthOrDareGameState extends State<_TruthOrDareGame> {
  final _rng = math.Random();
  
  final List<String> _truths = [
    'En büyük sırrın ne? 🤫',
    'En utandığın an hangisi?',
    'Şu an aklından kim geçiyor?',
    'En korktuğun şey ne?',
    'Hiç yalan söyledin mi? 😄',
    'En sevdiğin bisiklet rotası?',
    'Bugün en mutlu anın hangisiydi?',
    'Favori şarkın hangisi?',
  ];

  final List<String> _dares = [
    'Şarkı söyle! 🎤',
    '10 saniye komik yüz yap! 😜',
    'Bisiklete binerken el bırak! (güvenli yerde)',
    'En hızlı pedal çevir! ⚡',
    'Arkadaşını taklit et! 😂',
    'Hiç durmadan 60 saniye şarkı söyle!',
    'Gözlerin kapalıyken bisikletten in!',
  ];

  String? _current;
  bool _isTruth = true;

  void _pick(bool truth) {
    setState(() {
      _isTruth = truth;
      if (truth) {
        _current = _truths[_rng.nextInt(_truths.length)];
      } else {
        _current = _dares[_rng.nextInt(_dares.length)];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF831843), Color(0xFF0A0A0F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onBack,
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 16),
                    const Text('🎯 Doğru mu Yanlış mı?',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w900,
                            fontSize: 18)),
                  ],
                ),

                const Spacer(),

                if (_current != null) ...[
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        colors: _isTruth
                            ? [AppTheme.secondary.withOpacity(0.3), AppTheme.primary.withOpacity(0.1)]
                            : [AppTheme.accent.withOpacity(0.3), Colors.red.withOpacity(0.1)],
                      ),
                      border: Border.all(
                        color: _isTruth ? AppTheme.secondary : AppTheme.accent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _isTruth ? '💭 DOĞRU' : '🎭 MEYDAN OKUMA',
                          style: TextStyle(
                            color: _isTruth ? AppTheme.secondary : AppTheme.accent,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _current!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ] else ...[
                  const Text('🎮', style: TextStyle(fontSize: 80)),
                  const SizedBox(height: 20),
                  const Text(
                    'Birini seç!',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pick(true),
                        child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [AppTheme.secondary, Color(0xFF0891B2)],
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('💭', style: TextStyle(fontSize: 24)),
                              Text('Doğru',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pick(false),
                        child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [AppTheme.accent, Color(0xFF831843)],
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('🎭', style: TextStyle(fontSize: 24)),
                              Text('Meydan Okuma',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ========= OYUN 4: Emoji Quiz =========
class _EmojiQuizGame extends StatefulWidget {
  final VoidCallback onBack;
  const _EmojiQuizGame({required this.onBack});

  @override
  State<_EmojiQuizGame> createState() => _EmojiQuizGameState();
}

class _EmojiQuizGameState extends State<_EmojiQuizGame> {
  final _rng = math.Random();
  int _score = 0;
  int _total = 0;

  final List<Map<String, dynamic>> _questions = [
    {'emoji': '🚴🎵', 'answer': 'BCycle', 'options': ['BCycle', 'Araba', 'Yüzme', 'Futbol']},
    {'emoji': '🌙🎸', 'answer': 'Gece Rockı', 'options': ['Gece Rockı', 'Sabah Şarkısı', 'Öğle Melodisi', 'Akşam Pop']},
    {'emoji': '🏔️🚴', 'answer': 'Dağ Bisikleti', 'options': ['Dağ Bisikleti', 'Şehir Turu', 'Plaj Yolu', 'Park Keyfi']},
    {'emoji': '👨‍👩‍👧⌚', 'answer': 'Aile Saati', 'options': ['Aile Saati', 'Yalnız Zaman', 'İş Toplantısı', 'Oyun Vakti']},
    {'emoji': '🎵🌙😴', 'answer': 'Uyku Müziği', 'options': ['Uyku Müziği', 'Sabah Egzersizi', 'Parti Müziği', 'Dans Şarkısı']},
  ];

  int _current = 0;
  String? _selected;
  bool? _correct;

  void _answer(String choice) {
    if (_selected != null) return;
    final q = _questions[_current];
    _selected = choice;
    _correct = choice == q['answer'];
    if (_correct!) _score++;
    _total++;
    setState(() {});

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          if (_current < _questions.length - 1) {
            _current++;
            _selected = null;
            _correct = null;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_total == _questions.length) {
      return _buildResult(context);
    }

    final q = _questions[_current];
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF78350F), Color(0xFF0A0A0F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onBack,
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 16),
                    const Text('😂 Emoji Quiz',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w900,
                            fontSize: 20)),
                    const Spacer(),
                    Text('${_current + 1}/${_questions.length}',
                        style: const TextStyle(
                            color: AppTheme.gold, fontFamily: 'Nunito')),
                  ],
                ),

                const Spacer(),

                Text(
                  q['emoji'],
                  style: const TextStyle(fontSize: 72),
                ),

                const SizedBox(height: 20),

                const Text('Bu ne?',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 20)),

                const SizedBox(height: 30),

                ...List<String>.from(q['options']).map((opt) {
                  Color btnColor;
                  if (_selected == null) {
                    btnColor = Colors.white.withOpacity(0.1);
                  } else if (opt == q['answer']) {
                    btnColor = AppTheme.green.withOpacity(0.4);
                  } else if (opt == _selected) {
                    btnColor = Colors.red.withOpacity(0.4);
                  } else {
                    btnColor = Colors.white.withOpacity(0.05);
                  }

                  return GestureDetector(
                    onTap: () => _answer(opt),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: btnColor,
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Text(
                        opt,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF78350F), Color(0xFF0A0A0F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 80)),
                  const SizedBox(height: 20),
                  const Text('Oyun Bitti!',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w900,
                          fontSize: 28)),
                  const SizedBox(height: 10),
                  Text(
                    '$_score / ${_questions.length} Doğru',
                    style: const TextStyle(
                        color: AppTheme.gold,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 20),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _current = 0;
                        _score = 0;
                        _total = 0;
                        _selected = null;
                        _correct = null;
                      });
                    },
                    child: const Text('Tekrar Oyna',
                        style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: widget.onBack,
                    child: const Text('← Oyun Menüsü',
                        style: TextStyle(color: AppTheme.textSecondary, fontFamily: 'Nunito')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
