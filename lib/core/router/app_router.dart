import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/health_info_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/ride/ride_screen.dart';
import '../../features/music/music_screen.dart';
import '../../features/friends/friends_screen.dart';
import '../../features/friends/friend_request_screen.dart';
import '../../features/location/location_screen.dart';
import '../../features/watch/watch_connect_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/stats/stats_screen.dart';
import '../../features/games/games_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/health-info',
        builder: (context, state) => const HealthInfoScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'ride',
            builder: (context, state) => const RideScreen(),
          ),
          GoRoute(
            path: 'music',
            builder: (context, state) => const MusicScreen(),
          ),
          GoRoute(
            path: 'friends',
            builder: (context, state) => const FriendsScreen(),
            routes: [
              GoRoute(
                path: 'requests',
                builder: (context, state) => const FriendRequestScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'location',
            builder: (context, state) => const LocationScreen(),
          ),
          GoRoute(
            path: 'watch',
            builder: (context, state) => const WatchConnectScreen(),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: 'stats',
            builder: (context, state) => const StatsScreen(),
          ),
          GoRoute(
            path: 'games',
            builder: (context, state) => const GamesScreen(),
          ),
        ],
      ),
    ],
  );
});
