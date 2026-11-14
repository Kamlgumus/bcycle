import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/music_service.dart';
import '../../core/theme/app_theme.dart';
import 'glass_card.dart';

class MiniMusicBar extends ConsumerWidget {
  final VoidCallback onTap;

  const MiniMusicBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicState = ref.watch(musicServiceProvider);
    final musicService = ref.read(musicServiceProvider.notifier);
    final song = musicState.currentSong;

    if (song == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          borderRadius: 16,
          gradient: const LinearGradient(
            colors: [Color(0xFF28114B), Color(0xFF13152C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                // Emoji Icon / Avatar
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.secondary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      song.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Bilgiler
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        song.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Nunito',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${song.artist} • ${song.genre}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontFamily: 'Nunito',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Oynat / Durdur Butonu
                IconButton(
                  icon: Icon(
                    musicState.isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                    color: AppTheme.primaryLight,
                    size: 34,
                  ),
                  onPressed: musicService.togglePlay,
                ),

                // Sonraki
                IconButton(
                  icon: const Icon(
                    Icons.skip_next_rounded,
                    color: Colors.white70,
                    size: 26,
                  ),
                  onPressed: musicService.next,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
