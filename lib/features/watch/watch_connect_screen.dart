import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/watch_service.dart';
import '../../shared/widgets/glass_card.dart';

class WatchConnectScreen extends ConsumerStatefulWidget {
  const WatchConnectScreen({super.key});

  @override
  ConsumerState<WatchConnectScreen> createState() => _WatchConnectScreenState();
}

class _WatchConnectScreenState extends ConsumerState<WatchConnectScreen>
    with TickerProviderStateMixin {
  late AnimationController _watchFaceController;
  late AnimationController _scanController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _watchFaceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _watchFaceController.dispose();
    _scanController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final watchData = ref.watch(watchServiceProvider);
    final watchService = ref.read(watchServiceProvider.notifier);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0A10),
              Color(0xFF0A0A0F),
              Color(0xFF0A1020),
            ],
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
                    const Text(
                      '⌚ Aikela Saat Bağla',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Özel saat bağlantı ekranı
                      _buildWatchFace(watchData),

                      const SizedBox(height: 32),

                      // Durum kartı
                      _buildStatusCard(watchData),

                      const SizedBox(height: 20),

                      // Bağlı ise veri kartları
                      if (watchData.status == WatchStatus.connected) ...[
                        _buildWatchDataCards(watchData),
                        const SizedBox(height: 20),
                      ],

                      // Cihaz listesi
                      if (watchData.status == WatchStatus.scanning ||
                          watchData.availableDevices.isNotEmpty)
                        _buildDeviceList(watchData, watchService),

                      const SizedBox(height: 20),

                      // Butonlar
                      _buildButtons(watchData, watchService),

                      const SizedBox(height: 20),

                      // Özellik listesi
                      _buildFeatureList(),
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

  Widget _buildWatchFace(WatchData watchData) {
    final isConnected = watchData.status == WatchStatus.connected;
    final isScanning = watchData.status == WatchStatus.scanning;

    return AnimatedBuilder(
      animation: _watchFaceController,
      builder: (context, child) {
        return Column(
          children: [
            // Saat çerçevesi — özel tasarım
            Container(
              width: 180,
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isConnected
                      ? [const Color(0xFFD97706), const Color(0xFF78350F)]
                      : [const Color(0xFF374151), const Color(0xFF111827)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: isConnected
                        ? const Color(0xFFD97706).withOpacity(
                            0.3 + 0.3 * _watchFaceController.value)
                        : Colors.black.withOpacity(0.5),
                    blurRadius: isConnected ? 40 : 20,
                    spreadRadius: isConnected ? 10 : 0,
                  ),
                ],
                border: Border.all(
                  color: isConnected
                      ? const Color(0xFFFBBF24).withOpacity(0.5)
                      : Colors.white.withOpacity(0.1),
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Saat yüzü içeriği
                    if (isConnected) ...[
                      Text(
                        '${watchData.heartRate}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w900,
                          fontSize: 42,
                        ),
                      ),
                      const Text('❤️ bpm', style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 10),
                      Text(
                        '🔋 ${watchData.battery.round()}%',
                        style: const TextStyle(
                          color: Color(0xFFFBBF24),
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '👟 ${watchData.steps}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Nunito',
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.green.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '✅ Bağlı',
                          style: TextStyle(
                            color: AppTheme.green,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ] else if (isScanning) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFD97706)),
                          backgroundColor: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Taranıyor...',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ] else ...[
                      const Text('⌚', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 10),
                      const Text(
                        'Aikela',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'Bağlantı bekleniyor',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontFamily: 'Nunito',
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Saat kayışı efekti
            Container(
              width: 60,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF374151),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
            ),
          ],
        );
      },
    ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildStatusCard(WatchData watchData) {
    String message;
    Color color;
    IconData icon;

    switch (watchData.status) {
      case WatchStatus.connected:
        message = '${watchData.deviceName ?? "Aikela Saat"} bağlandı! 🎉';
        color = AppTheme.green;
        icon = Icons.check_circle_rounded;
        break;
      case WatchStatus.scanning:
        message = 'Yakındaki Bluetooth cihazları taranıyor...';
        color = AppTheme.gold;
        icon = Icons.radar_rounded;
        break;
      case WatchStatus.connecting:
        message = 'Cihaza bağlanılıyor...';
        color = AppTheme.secondary;
        icon = Icons.sync_rounded;
        break;
      case WatchStatus.error:
        message = watchData.errorMessage ?? 'Bir hata oluştu';
        color = Colors.red;
        icon = Icons.error_rounded;
        break;
      default:
        message = 'Aikela saatini bağlamak için tara!';
        color = AppTheme.textSecondary;
        icon = Icons.info_outline_rounded;
    }

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: color,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchDataCards(WatchData watchData) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _watchDataCard('❤️ Nabız', '${watchData.heartRate} bpm', Colors.red),
        _watchDataCard('🔋 Pil', '${watchData.battery.round()}%', AppTheme.gold),
        _watchDataCard('👟 Adımlar', '${watchData.steps}', AppTheme.green),
        _watchDataCard('🌡️ Sıcaklık',
            '${watchData.temperature.toStringAsFixed(1)}°C', AppTheme.secondary),
      ],
    );
  }

  Widget _watchDataCard(String label, String value, Color color) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontFamily: 'Nunito',
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceList(WatchData watchData, WatchService service) {
    if (watchData.availableDevices.isEmpty) {
      return GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'Cihaz aranıyor... Bluetooth açık ve Aikela saatin açık olduğundan emin ol.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontFamily: 'Nunito',
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bulunan Cihazlar',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        ...watchData.availableDevices.map(
          (device) => GestureDetector(
            onTap: () => service.connectToDevice(device),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white.withOpacity(0.07),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFD97706).withOpacity(0.2),
                    ),
                    child: const Center(
                      child: Text('⌚', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.platformName.isNotEmpty
                              ? device.platformName
                              : 'Bilinmeyen Cihaz',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          device.remoteId.toString().substring(0, 17),
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontFamily: 'Nunito',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.bluetooth_rounded,
                      color: AppTheme.secondary, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(WatchData watchData, WatchService service) {
    return Column(
      children: [
        if (watchData.status != WatchStatus.connected) ...[
          if (watchData.status == WatchStatus.scanning)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Taranıyor... ⏳',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: service.startScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_rounded, color: Colors.white),
                    SizedBox(width: 10),
                    Text('Aikela Saat Ara',
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            color: Colors.white)),
                  ],
                ),
              ),
            ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: service.disconnect,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Bağlantıyı Kes',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFeatureList() {
    final features = [
      ('❤️', 'Nabız takibi', 'Gerçek zamanlı kalp atış hızı'),
      ('🔋', 'Pil takibi', 'Saat pil seviyesi'),
      ('👟', 'Adım sayımı', 'Saatteki adım verileri'),
      ('🌡️', 'Sıcaklık', 'Vücut/hava sıcaklığı'),
      ('📳', 'Titreşim', 'Önemli bildirimlerde saat titreşir'),
    ];

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⌚ Saat Özellikleri',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            ...features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Text(f.$1, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f.$2,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                          Text(f.$3,
                              style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontFamily: 'Nunito',
                                  fontSize: 12)),
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
    );
  }
}
