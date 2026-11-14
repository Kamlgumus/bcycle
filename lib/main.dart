// BCycle - Ana giriş noktası
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/step_counter_service.dart';
import 'data/models/user_model.dart';
import 'data/models/friend_model.dart';
import 'data/models/song_model.dart';
import 'data/models/ride_model.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Yatay mod engelle
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Hive başlat
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(FriendModelAdapter());
  Hive.registerAdapter(SongModelAdapter());
  Hive.registerAdapter(RideModelAdapter());

  await Hive.openBox<UserModel>('users');
  await Hive.openBox<FriendModel>('friends');
  await Hive.openBox<SongModel>('songs');
  await Hive.openBox<RideModel>('rides');
  await Hive.openBox('settings');

  // Arka plan müzik servisi
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.bcycle.music',
    androidNotificationChannelName: 'BCycle Müzik',
    androidNotificationOngoing: false,
    androidStopForegroundOnPause: true,
  );

  // Bildirim servisi başlat
  await NotificationService.initialize(flutterLocalNotificationsPlugin);

  // Durum çubuğu rengi
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: BCycleApp(),
    ),
  );
}

class BCycleApp extends ConsumerWidget {
  const BCycleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'BCycle',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
