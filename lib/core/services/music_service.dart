import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/song_model.dart';

class MusicState {
  final List<SongModel> songs;
  final SongModel? currentSong;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double volume;
  final bool isShuffled;
  final LoopMode loopMode;
  final bool isLoading;
  final String? error;

  const MusicState({
    this.songs = const [],
    this.currentSong,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.isShuffled = false,
    this.loopMode = LoopMode.off,
    this.isLoading = false,
    this.error,
  });

  MusicState copyWith({
    List<SongModel>? songs,
    SongModel? currentSong,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    double? volume,
    bool? isShuffled,
    LoopMode? loopMode,
    bool? isLoading,
    String? error,
  }) {
    return MusicState(
      songs: songs ?? this.songs,
      currentSong: currentSong ?? this.currentSong,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      isShuffled: isShuffled ?? this.isShuffled,
      loopMode: loopMode ?? this.loopMode,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Çevrimdışı çalışan telif ücretsiz şarkılar listesi
final List<Map<String, String>> _defaultSongs = [
  {
    'id': '1',
    'title': 'Midnight Breeze',
    'artist': 'Chill Vibes',
    'album': 'Lo-Fi Dreams',
    'assetPath': 'assets/music/midnight_breeze.mp3',
    'duration': '3:24',
    'genre': 'Lo-Fi',
    'emoji': '🌙',
  },
  {
    'id': '2',
    'title': 'Summer Ride',
    'artist': 'Adventure Sound',
    'album': 'Open Road',
    'assetPath': 'assets/music/summer_ride.mp3',
    'duration': '2:58',
    'genre': 'Pop',
    'emoji': '☀️',
  },
  {
    'id': '3',
    'title': 'Neon City',
    'artist': 'Synthwave Rush',
    'album': 'Electric Dreams',
    'assetPath': 'assets/music/neon_city.mp3',
    'duration': '4:12',
    'genre': 'Synthwave',
    'emoji': '🌆',
  },
  {
    'id': '4',
    'title': 'Forest Path',
    'artist': 'Nature Sounds',
    'album': 'Calm Journey',
    'assetPath': 'assets/music/forest_path.mp3',
    'duration': '3:45',
    'genre': 'Ambient',
    'emoji': '🌲',
  },
  {
    'id': '5',
    'title': 'Speed Rush',
    'artist': 'Energy Beats',
    'album': 'Full Power',
    'assetPath': 'assets/music/speed_rush.mp3',
    'duration': '2:30',
    'genre': 'Electronic',
    'emoji': '⚡',
  },
  {
    'id': '6',
    'title': 'Morning Glow',
    'artist': 'Dawn Riders',
    'album': 'New Day',
    'assetPath': 'assets/music/morning_glow.mp3',
    'duration': '3:15',
    'genre': 'Indie',
    'emoji': '🌅',
  },
  {
    'id': '7',
    'title': 'Hip Hop Cruise',
    'artist': 'Street Beat',
    'album': 'Urban Vibes',
    'assetPath': 'assets/music/hiphop_cruise.mp3',
    'duration': '3:50',
    'genre': 'Hip-Hop',
    'emoji': '🎤',
  },
  {
    'id': '8',
    'title': 'Jazz Ride',
    'artist': 'Smooth Notes',
    'album': 'Evening Jazz',
    'assetPath': 'assets/music/jazz_ride.mp3',
    'duration': '4:30',
    'genre': 'Jazz',
    'emoji': '🎷',
  },
  {
    'id': '9',
    'title': 'Rock Downhill',
    'artist': 'Thunder Wheels',
    'album': 'Adrenaline',
    'assetPath': 'assets/music/rock_downhill.mp3',
    'duration': '3:05',
    'genre': 'Rock',
    'emoji': '🎸',
  },
  {
    'id': '10',
    'title': 'Chill Sunset',
    'artist': 'Horizon Beats',
    'album': 'Golden Hour',
    'assetPath': 'assets/music/chill_sunset.mp3',
    'duration': '4:00',
    'genre': 'Chill',
    'emoji': '🌇',
  },
  {
    'id': '11',
    'title': 'City Lights',
    'artist': 'Urban Explorer',
    'album': 'Night City',
    'assetPath': 'assets/music/city_lights.mp3',
    'duration': '3:33',
    'genre': 'Ambient',
    'emoji': '🏙️',
  },
  {
    'id': '12',
    'title': 'Mountain High',
    'artist': 'Peak Riders',
    'album': 'Summit',
    'assetPath': 'assets/music/mountain_high.mp3',
    'duration': '2:45',
    'genre': 'Electronic',
    'emoji': '⛰️',
  },
  {
    'id': '13',
    'title': 'Rain Ride',
    'artist': 'Storm Chasers',
    'album': 'Wet Season',
    'assetPath': 'assets/music/rain_ride.mp3',
    'duration': '3:20',
    'genre': 'Ambient',
    'emoji': '🌧️',
  },
  {
    'id': '14',
    'title': 'Tropical Spin',
    'artist': 'Island Vibes',
    'album': 'Paradise',
    'assetPath': 'assets/music/tropical_spin.mp3',
    'duration': '2:55',
    'genre': 'Pop',
    'emoji': '🌴',
  },
  {
    'id': '15',
    'title': 'Dark Ride',
    'artist': 'Midnight Crew',
    'album': 'After Hours',
    'assetPath': 'assets/music/dark_ride.mp3',
    'duration': '4:15',
    'genre': 'Electronic',
    'emoji': '🌑',
  },
];

class MusicService extends StateNotifier<MusicState> {
  MusicService() : super(const MusicState()) {
    _init();
  }

  late AudioPlayer _player;
  List<SongModel> _playlist = [];
  int _currentIndex = 0;

  Future<void> _init() async {
    _player = AudioPlayer();

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Şarkıları yükle
    final songs = _defaultSongs.map((s) => SongModel.fromMap(s)).toList();
    _playlist = songs;
    state = state.copyWith(songs: songs);

    // Olay dinleyicileri
    _player.playerStateStream.listen((playerState) {
      state = state.copyWith(
        isPlaying: playerState.playing,
        isLoading: playerState.processingState == ProcessingState.loading ||
            playerState.processingState == ProcessingState.buffering,
      );

      if (playerState.processingState == ProcessingState.completed) {
        next();
      }
    });

    _player.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });

    _player.durationStream.listen((duration) {
      if (duration != null) state = state.copyWith(duration: duration);
    });
  }

  Future<void> playSong(SongModel song) async {
    try {
      _currentIndex = _playlist.indexWhere((s) => s.id == song.id);
      state = state.copyWith(currentSong: song, isLoading: true);

      await _player.setAudioSource(
        AudioSource.asset(
          song.assetPath,
          tag: MediaItem(
            id: song.id,
            title: song.title,
            artist: song.artist,
            album: song.album,
            artUri: null,
          ),
        ),
      );
      await _player.play();
    } catch (e) {
      state = state.copyWith(error: 'Şarkı çalınamadı: $e', isLoading: false);
    }
  }

  Future<void> togglePlay() async {
    if (state.isPlaying) {
      await _player.pause();
    } else {
      if (state.currentSong == null && _playlist.isNotEmpty) {
        await playSong(_playlist[0]);
      } else {
        await _player.play();
      }
    }
  }

  Future<void> next() async {
    if (_playlist.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % _playlist.length;
    await playSong(_playlist[_currentIndex]);
  }

  Future<void> previous() async {
    if (_playlist.isEmpty) return;
    if (state.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
    } else {
      _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
      await playSong(_playlist[_currentIndex]);
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
    state = state.copyWith(volume: volume);
  }

  Future<void> toggleShuffle() async {
    final newShuffled = !state.isShuffled;
    await _player.setShuffleModeEnabled(newShuffled);
    state = state.copyWith(isShuffled: newShuffled);
  }

  Future<void> cycleLoopMode() async {
    LoopMode next;
    switch (state.loopMode) {
      case LoopMode.off:
        next = LoopMode.all;
        break;
      case LoopMode.all:
        next = LoopMode.one;
        break;
      case LoopMode.one:
        next = LoopMode.off;
        break;
    }
    await _player.setLoopMode(next);
    state = state.copyWith(loopMode: next);
  }

  List<SongModel> searchSongs(String query) {
    if (query.isEmpty) return _playlist;
    return _playlist
        .where((s) =>
            s.title.toLowerCase().contains(query.toLowerCase()) ||
            s.artist.toLowerCase().contains(query.toLowerCase()) ||
            s.genre.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

final musicServiceProvider =
    StateNotifierProvider<MusicService, MusicState>((ref) => MusicService());
