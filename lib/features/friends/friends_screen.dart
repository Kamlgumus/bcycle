import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/friend_model.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';

final friendsProvider = StateNotifierProvider<FriendsNotifier, List<FriendModel>>(
  (ref) => FriendsNotifier(),
);

class FriendsNotifier extends StateNotifier<List<FriendModel>> {
  FriendsNotifier() : super([]) {
    _load();
  }

  void _load() {
    final box = Hive.box<FriendModel>('friends');
    state = box.values.toList();
  }

  Future<void> sendRequest(String username, String displayName) async {
    // Zaten eklendi mi?
    if (state.any((f) => f.username.toLowerCase() == username.toLowerCase())) {
      throw Exception('Bu kullanıcı zaten arkadaş listenizde!');
    }

    final friend = FriendModel(
      id: const Uuid().v4(),
      username: username,
      displayName: displayName.isNotEmpty ? displayName : username,
      status: 'pending_sent', // Ben istek gönderdim
      addedAt: DateTime.now(),
    );

    final box = Hive.box<FriendModel>('friends');
    await box.put(friend.id, friend);
    _load();
  }

  Future<void> acceptRequest(String friendId) async {
    final box = Hive.box<FriendModel>('friends');
    final friend = box.get(friendId);
    if (friend == null) return;

    final updated = friend.copyWith(status: 'accepted');
    await box.put(friendId, updated);
    _load();
  }

  Future<void> rejectRequest(String friendId) async {
    final box = Hive.box<FriendModel>('friends');
    await box.delete(friendId);
    _load();
  }

  Future<void> removeFriend(String friendId) async {
    final box = Hive.box<FriendModel>('friends');
    await box.delete(friendId);
    _load();
  }

  /// Simülasyon: birinin bize istek göndermesi (test amaçlı)
  Future<void> simulateIncomingRequest(String username) async {
    final friend = FriendModel(
      id: const Uuid().v4(),
      username: username,
      displayName: username,
      status: 'pending_received', // Bize istek gönderildi
      addedAt: DateTime.now(),
    );
    final box = Hive.box<FriendModel>('friends');
    await box.put(friend.id, friend);
    _load();
  }
}

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friends = ref.watch(friendsProvider);
    final accepted = friends.where((f) => f.status == 'accepted').toList();
    final pendingReceived =
        friends.where((f) => f.status == 'pending_received').toList();
    final pendingSent =
        friends.where((f) => f.status == 'pending_sent').toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A1628), Color(0xFF0A0A0F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Üst çubuk
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
                        '👥 Arkadaşlar',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    if (pendingReceived.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${pendingReceived.length} istek',
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Sekme çubuğu
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.secondary],
                    ),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppTheme.textMuted,
                  labelStyle: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(text: 'Arkadaşlar (${accepted.length})'),
                    Tab(text: 'İstekler (${pendingReceived.length})'),
                    const Tab(text: 'Ekle'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFriendsList(accepted),
                    _buildRequestsList(pendingReceived, pendingSent),
                    _buildAddFriend(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFriendsList(List<FriendModel> friends) {
    if (friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('👥', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              'Henüz arkadaşın yok!',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '"Ekle" sekmesinden arkadaş ekleyebilirsin',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontFamily: 'Nunito',
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: friends.length,
      itemBuilder: (context, i) {
        final friend = friends[i];
        return _friendCard(friend);
      },
    );
  }

  Widget _friendCard(FriendModel friend) {
    return GestureDetector(
      onTap: () => context.go('/home/location'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.06),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppTheme.secondary, AppTheme.primary],
                ),
              ),
              child: Center(
                child: Text(
                  friend.displayName.isNotEmpty
                      ? friend.displayName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
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
                    friend.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '@${friend.username}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontFamily: 'Nunito',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: friend.isOnline ? AppTheme.green : AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      friend.isOnline ? 'Çevrimiçi' : 'Çevrimdışı',
                      style: TextStyle(
                        color: friend.isOnline ? AppTheme.green : AppTheme.textMuted,
                        fontFamily: 'Nunito',
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    ref
                        .read(friendsProvider.notifier)
                        .removeFriend(friend.id);
                  },
                  child: Text(
                    'Çıkar',
                    style: TextStyle(
                      color: Colors.red.withOpacity(0.7),
                      fontFamily: 'Nunito',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  Widget _buildRequestsList(
      List<FriendModel> received, List<FriendModel> sent) {
    if (received.isEmpty && sent.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📬', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'Bekleyen istek yok',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontFamily: 'Nunito',
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        if (received.isNotEmpty) ...[
          const Text(
            'Gelen İstekler',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          ...received.map((f) => _requestCard(f, true)),
          const SizedBox(height: 20),
        ],
        if (sent.isNotEmpty) ...[
          const Text(
            'Gönderilen İstekler',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          ...sent.map((f) => _requestCard(f, false)),
        ],
      ],
    );
  }

  Widget _requestCard(FriendModel friend, bool isReceived) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.06),
        border: Border.all(
          color: isReceived
              ? AppTheme.accent.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isReceived ? AppTheme.accent : AppTheme.secondary)
                  .withOpacity(0.2),
            ),
            child: Center(
              child: Text(
                friend.displayName.isNotEmpty
                    ? friend.displayName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '@${friend.username} • ${isReceived ? "arkadaş isteği gönderdi" : "istek gönderildi"}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontFamily: 'Nunito',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isReceived)
            Row(
              children: [
                GestureDetector(
                  onTap: () => ref
                      .read(friendsProvider.notifier)
                      .rejectRequest(friend.id),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.close, color: Colors.red, size: 18),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => ref
                      .read(friendsProvider.notifier)
                      .acceptRequest(friend.id),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.check, color: AppTheme.green, size: 18),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Bekliyor...',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontFamily: 'Nunito',
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddFriend() {
    final usernameCtrl = TextEditingController();
    bool isLoading = false;
    String? error;
    String? success;

    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '➕ Arkadaş Ekle',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Kullanıcı adını yaz, arkadaşın kabul etsin!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontFamily: 'Nunito',
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: usernameCtrl,
                        style: const TextStyle(
                            color: Colors.white, fontFamily: 'Nunito'),
                        decoration: InputDecoration(
                          labelText: 'Kullanıcı adı',
                          hintText: '@kullanici_adi',
                          prefixIcon: const Icon(Icons.alternate_email,
                              color: AppTheme.primary, size: 20),
                          labelStyle: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontFamily: 'Nunito'),
                          hintStyle: const TextStyle(
                              color: AppTheme.textMuted, fontFamily: 'Nunito'),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: AppTheme.primary, width: 2),
                          ),
                        ),
                      ),

                      if (error != null) ...[
                        const SizedBox(height: 10),
                        Text(error!,
                            style: const TextStyle(
                                color: Colors.red, fontFamily: 'Nunito')),
                      ],
                      if (success != null) ...[
                        const SizedBox(height: 10),
                        Text(success!,
                            style: const TextStyle(
                                color: AppTheme.green, fontFamily: 'Nunito')),
                      ],

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  final username =
                                      usernameCtrl.text.trim();
                                  if (username.isEmpty) {
                                    setState(() =>
                                        error = 'Kullanıcı adı gerekli');
                                    return;
                                  }

                                  setState(() {
                                    isLoading = true;
                                    error = null;
                                    success = null;
                                  });

                                  try {
                                    await ref
                                        .read(friendsProvider.notifier)
                                        .sendRequest(username, username);
                                    setState(() {
                                      success =
                                          '✅ İstek gönderildi! @$username kabul edince arkadaş olacaksınız.';
                                      usernameCtrl.clear();
                                    });
                                  } catch (e) {
                                    setState(() =>
                                        error = e.toString().replaceAll('Exception: ', ''));
                                  } finally {
                                    setState(() => isLoading = false);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'İstek Gönder 📨',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Test: simüle gelen istek
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🧪 Test Modu',
                        style: TextStyle(
                          color: AppTheme.gold,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Birinin sana istek gönderdiğini simüle et:',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontFamily: 'Nunito',
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () async {
                          await ref
                              .read(friendsProvider.notifier)
                              .simulateIncomingRequest('test_arkadas');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('test_arkadas sana istek gönderdi!'),
                              backgroundColor: AppTheme.primary,
                            ),
                          );
                        },
                        child: const Text(
                          'test_arkadas simüle et',
                          style: TextStyle(
                              color: AppTheme.primary, fontFamily: 'Nunito'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
