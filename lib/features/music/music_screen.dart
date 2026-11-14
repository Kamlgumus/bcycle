import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/music_service.dart';
import '../../data/models/song_model.dart';
import '../../shared/widgets/glass_card.dart';

class MusicScreen extends ConsumerStatefulWidget {
  const MusicScreen({super.key});

  @override
  ConsumerState<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends ConsumerState<MusicScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedGenre = 'Tümü';
  late AnimationController _vinylController;
  late AnimationController _waveController;

  final List<String> _genres = [
    'Tümü', 'Lo-Fi', 'Pop', 'Synthwave', 'Ambient',
    'Electronic', 'Hip-Hop', 'Jazz', 'Rock', 'Chill', 'Indie',
  ];

  @override
  void initState() {
    super.initState();
    _vinylController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _vinylController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final musicState = ref.watch(musicServiceProvider);
    final musicService = ref.read(musicServiceProvider.notifier);

    // Vinyl döndür/durdur
    if (musicState.isPlaying) {
      _vinylController.repeat();
    } else {
      _vinylController.stop();
    }

    // Şarkıları filtrele
    var filteredSongs = musicService.searchSongs(_searchQuery);
    if (_selectedGenre != 'Tümü') {
      filteredSongs =
          filteredSongs.where((s) => s.genre == _selectedGenre).toList();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0A30), Color(0xFF0A0A0F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Üst
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
                    const Expanded(
                      child: Text(
                        '🎵 Müzik Çalar',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    const Text(
                      '📶 Çevrimdışı',
                      style: TextStyle(
                        color: AppTheme.green,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Şu an çalan
              if (musicState.currentSong != null) ...[
                const SizedBox(height: 20),
                _buildNowPlaying(musicState, musicService),
              ],

              const SizedBox(height: 16),

              // Arama
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(color: Colors.white, fontFamily: 'Nunito'),
                  decoration: InputDecoration(
                    hintText: 'Şarkı, sanatçı veya tür ara...',
                    hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.4), fontFamily: 'Nunito'),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: const Icon(Icons.clear, color: AppTheme.textSecondary),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.07),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Tür filtreleri
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _genres.length,
                  itemBuilder: (context, i) {
                    final genre = _genres[i];
                    final selected = genre == _selectedGenre;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedGenre = genre),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: selected
                              ? const LinearGradient(
                                  colors: [AppTheme.primary, AppTheme.secondary])
                              : null,
                          color: selected
                              ? null
                              : Colors.white.withOpacity(0.07),
                        ),
                        child: Text(
                          genre,
                          style: TextStyle(
                            color: selected ? Colors.white : AppTheme.textSecondary,
                            fontFamily: 'Nunito',
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Şarkı listesi
              Expanded(
                child: filteredSongs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🎵', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            Text(
                              'Şarkı bulunamadı',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontFamily: 'Nunito',
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filteredSongs.length,
                        itemBuilder: (context, i) {
                          final song = filteredSongs[i];
                          final isPlaying =
                              musicState.currentSong?.id == song.id &&
                                  musicState.isPlaying;
                          return _buildSongTile(
                              song, isPlaying, musicService, musicState);
                        },
                      ),
              ),

              // Player kontrolleri (altta sabit)
              if (musicState.currentSong != null)
                _buildPlayerControls(musicState, musicService),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNowPlaying(MusicState state, MusicService service) {
    final song = state.currentSong!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        gradient: const LinearGradient(
          colors: [Color(0xFF4C1D95), Color(0xFF1E1B4B)],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Vinyl disk animasyonu
              RotationTransition(
                turns: _vinylController,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, Color(0xFF1A0A2E)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.4),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(song.emoji,
                        style: const TextStyle(fontSize: 24)),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      song.artist,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontFamily: 'Nunito',
                        fontSize: 13,
                      ),
                    ),
                    // İlerleme çubuğu
                    if (state.duration.inSeconds > 0) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: state.duration.inSeconds > 0
                            ? state.position.inSeconds /
                                state.duration.inSeconds
                            : 0,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryLight),
                        minHeight: 3,
                      ),
                    ],
                  ],
                ),
              ),

              // Wave animasyonu (çalıyorsa)
              AnimatedBuilder(
                animation: _waveController,
                builder: (context, _) {
                  return Row(
                    children: List.generate(
                      4,
                      (i) => Container(
                        width: 3,
                        height: state.isPlaying
                            ? 10 +
                                15 *
                                    (i % 2 == 0
                                        ? _waveController.value
                                        : 1 - _waveController.value)
                            : 5,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSongTile(
    SongModel song,
    bool isPlaying,
    MusicService service,
    MusicState state,
  ) {
    return GestureDetector(
      onTap: () => service.playSong(song),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: isPlaying
              ? LinearGradient(
                  colors: [
                    AppTheme.primary.withOpacity(0.3),
                    AppTheme.primary.withOpacity(0.1),
                  ],
                )
              : null,
          color: isPlaying ? null : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: isPlaying
                ? AppTheme.primary.withOpacity(0.5)
                : Colors.white.withOpacity(0.07),
          ),
        ),
        child: Row(
          children: [
            // Emoji/Disk
            Text(song.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: TextStyle(
                      color: isPlaying ? AppTheme.primaryLight : Colors.white,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Text(
                        song.artist,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontFamily: 'Nunito',
                          fontSize: 12,
                        ),
                      ),
                      const Text(' • ',
                          style: TextStyle(color: AppTheme.textMuted)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          song.genre,
                          style: const TextStyle(
                            color: AppTheme.primaryLight,
                            fontFamily: 'Nunito',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  song.duration,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontFamily: 'Nunito',
                    fontSize: 12,
                  ),
                ),
                if (isPlaying)
                  const Icon(Icons.equalizer_rounded,
                      color: AppTheme.primaryLight, size: 18),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 50)).slideX(
          begin: 0.05,
          end: 0,
        );
  }

  Widget _buildPlayerControls(MusicState state, MusicService service) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A0A2E).withOpacity(0.0),
            const Color(0xFF1A0A2E),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Karıştır
          IconButton(
            icon: Icon(
              Icons.shuffle,
              color: state.isShuffled ? AppTheme.primaryLight : AppTheme.textMuted,
              size: 24,
            ),
            onPressed: service.toggleShuffle,
          ),
          // Önceki
          IconButton(
            icon: const Icon(Icons.skip_previous_rounded,
                color: Colors.white, size: 32),
            onPressed: service.previous,
          ),
          // Oynat/Durdur
          GestureDetector(
            onTap: service.togglePlay,
            child: Container(
              width: 64,
              height: 64,
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
              child: state.isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : Icon(
                      state.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
            ),
          ),
          // Sonraki
          IconButton(
            icon: const Icon(Icons.skip_next_rounded,
                color: Colors.white, size: 32),
            onPressed: service.next,
          ),
          // Tekrar
          IconButton(
            icon: Icon(
              state.loopMode == LoopMode.one
                  ? Icons.repeat_one
                  : Icons.repeat,
              color: state.loopMode != LoopMode.off
                  ? AppTheme.primaryLight
                  : AppTheme.textMuted,
              size: 24,
            ),
            onPressed: service.cycleLoopMode,
          ),
        ],
      ),
    );
  }
}
