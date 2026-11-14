import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import 'friends_screen.dart';

class FriendRequestScreen extends ConsumerWidget {
  const FriendRequestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friends = ref.watch(friendsProvider);
    final received = friends.where((f) => f.status == 'pending_received').toList();

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.go('/home/friends'),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: const Text('📬 Gelen İstekler',
            style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0A0F), Color(0xFF1A0A2E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: received.isEmpty
            ? const Center(
                child: Text(
                  'Bekleyen istek yok 🎉',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontFamily: 'Nunito',
                    fontSize: 16,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: received.length,
                itemBuilder: (context, i) {
                  final f = received[i];
                  return Card(
                    color: const Color(0xFF13131F),
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.accent.withOpacity(0.3),
                            child: Text(f.displayName[0].toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w900)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(f.displayName,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Nunito',
                                        fontWeight: FontWeight.w700)),
                                Text('@${f.username}',
                                    style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontFamily: 'Nunito',
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => ref
                                    .read(friendsProvider.notifier)
                                    .rejectRequest(f.id),
                              ),
                              IconButton(
                                icon: const Icon(Icons.check,
                                    color: AppTheme.green),
                                onPressed: () => ref
                                    .read(friendsProvider.notifier)
                                    .acceptRequest(f.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
