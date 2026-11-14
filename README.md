# 🚴 BCycle - Akıllı Bisiklet, Müzik & Arkadaş Uygulaması

> **Grok Stili Modern Koyu Gradient Tema • Çevrimdışı Müzik • Canlı GPS & Anne Takip Modu • Aikela Akıllı Saat Entegrasyonu • Sensör Destekli Pedal & Adım Sayacı • Çevrimdışı Oyunlar**

---

## 🌟 Öne Çıkan Özellikler

### 1. 🚴 Bisiklet Sürüşü & Zorunlu Pedal Sayacı (`ride_screen.dart`, `ride_service.dart`)
- **İvmeölçer ile Gerçek Pedal/Kadans Sayımı:** Telefon cebe veya bisiklet gidonuna takıldığında Z ekseni salınımını ve ivmeyi filtreleyerek pedal dönüşlerini sayar (20-200 RPM filtreli).
- **Hız & Mesafe:** GPS üzerinden anlık km/h, ortalama hız, maksimum hız ve kat edilen mesafe hesabı.
- **Dönen Dişli/Pedal Animasyonu & Hız Göstergesi (Speed Gauge).**
- **Kalori Hesabı:** Pedal ve hıza bağlı anlık yakılan kalori.

### 2. 🎵 Çevrimdışı Müzik Çalar (`music_screen.dart`, `music_service.dart`)
- **15+ Entegre Çevrimdışı Şarkı:** İnternet bağlantısı olmasa bile çalabilen telifsiz müzik kütüphanesi.
- **Arka Planda Çalma:** `just_audio_background` ile ekran kapalıyken veya kilit ekranında bildirim üzerinden kontrol.
- **Gelişmiş Kontroller:** Karışık çal (Shuffle), Tekrar modları (Repeat One/All), Ses kontrolü, Arama & Tür filtreleri (Lo-Fi, Synthwave, Pop, Hip-Hop, Rock, Chill vb.).
- **Dönen Vinil Disk & Müzik Dalgaları Efekti.**
- **Mini Müzik Bar:** Ana ekranda ve gezinirken altta kesintisiz mini player.

### 3. 👥 Kullanıcı Adı Bazlı Arkadaş Ekleme (`friends_screen.dart`, `register_screen.dart`)
- **Özel Kullanıcı Adı:** Kayıt olurken benzersiz bir `@kullanici_adi` belirlenir.
- **Karşılıklı Kabul Sistemi:** Birisi kullanıcı adınızı yazıp istek gönderdiğinde, siz kabul etmeden arkadaş eklenmez.
- **İstekler Sekmesi:** Gelen ve gönderilen arkadaşlık isteklerini onaylama/reddetme.

### 4. 📍 Anne Takip Modu & Canlı GPS Harita (`location_screen.dart`)
- **Canlı OpenStreetMap Haritası:** `flutter_map` ve `latlong2` ile rota çizimi.
- **Anne Takip Modu Anahtarı:** Tek dokunuşla canlı konumu arkadaşlar ve aile ile paylaşma / gizleme.
- **Hız & Yükseklik Takibi:** Sürüş esnasındaki anlık konum ve rota geçmişi.

### 5. 🏃 Adım Sayar & Silinmeyen Bildirim (`notification_service.dart`, `step_counter_service.dart`)
- **Android Donanım Adım Sayacı:** `pedometer` ile arka planda kesintisiz adım sayımı.
- **Silinemeyen Bildirim (Ongoing Notification):** Android durum çubuğunda kapatılamayan, canlı ilerleme çubuğu `[██████░░░░] 60%`, adım sayısı ve kalori gösteren bildirim.

### 6. ⌚ Aikela Akıllı Saat Bağlantısı (`watch_connect_screen.dart`, `watch_service.dart`)
- **Özel Aikela Bağlantı Ekranı:** Dijital saat yüzü animasyonu ve Bluetooth LE tarama.
- **GATT Servisleri:**
  - Nabız (Heart Rate Service: `0x180D`, `0x2A37`)
  - Pil Düzeyi (Battery Service: `0x180F`, `0x2A19`)
  - Adım Senkronizasyonu

### 7. 🏥 İlk Açılış Sağlık Bilgileri (`health_info_screen.dart`)
- Yaş, Cinsiyet, Boy, Kilo ve Günlük Adım Hedefi belirleme.
- Otomatik **VKİ (BMI)** ve kategori (Normal, Zayıf, Fazla Kilolu) hesaplama.
- Android yerel izin yöneticisi ile tam uyumlu izin isteme.

### 8. 🎮 Çevrimdışı Bisiklet Oyunları (`games_screen.dart`)
İnternetsiz arkadaşınızla mola verirken veya sürüş sırasında oynayabileceğiniz 4 oyun:
1. **Kelime Tahmin:** Harf klavyeli bisiklet & macera temalı kelime bulmaca.
2. **Matematik Mücadelesi:** Süreli refleks ve işlem oyunu.
3. **Doğru mu Yanlış mı? (Truth or Dare):** Eğlenceli sürüş görevleri ve sorular.
4. **Emoji Quiz:** Emoji kombinasyonlarından nesne tahmin etme.

---

## 🚀 Proje Dosya Ağacı

```
bcycle/
├── android/
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── AndroidManifest.xml   <-- Tüm izinler, servisler, bildirimler
│   │   │   └── kotlin/com/bcycle/app/MainActivity.kt
│   │   └── build.gradle             <-- compileSdk 34, multiDex
│   ├── build.gradle
│   └── settings.gradle
├── assets/
│   ├── images/
│   └── music/                       <-- 15 adet çevrimdışı ses dosyası
├── lib/
│   ├── core/
│   │   ├── router/app_router.dart   <-- GoRouter navigasyon ağacı
│   │   ├── services/
│   │   │   ├── music_service.dart   <-- Çevrimdışı müzik motoru
│   │   │   ├── notification_service.dart <-- Silinemeyen Android bildirimi
│   │   │   ├── ride_service.dart    <-- İvmeölçer pedal & GPS hız servisi
│   │   │   ├── step_counter_service.dart <-- Arka plan adım sayar
│   │   │   └── watch_service.dart   <-- Aikela Bluetooth LE bağlantısı
│   │   └── theme/app_theme.dart     <-- Grok neon gradient koyu tema
│   ├── data/models/                 <-- Hive veritabanı modelleri & adaptörleri
│   ├── features/
│   │   ├── auth/                    <-- Kayıt & Sağlık bilgisi ekranları
│   │   ├── friends/                 <-- Arkadaş ekleme & İstekler
│   │   ├── games/                   <-- 4 Adet Çevrimdışı Oyun
│   │   ├── home/                    <-- Ana Ekran Dashboard
│   │   ├── location/                <-- Canlı GPS Harita & Anne Takip
│   │   ├── music/                   <-- Müzik Çalar & Tür filtreleri
│   │   ├── onboarding/              <-- Tanıtım slaytları
│   │   ├── profile/                 <-- Profil & Rozetler & Ayarlar
│   │   ├── ride/                    <-- Sürüş Ekranı & Pedal Takibi
│   │   ├── splash/                  <-- Animasyonlu Karşılama Ekranı
│   │   └── stats/                   <-- İstatistikler & Haftalık Grafik
│   ├── shared/widgets/              <-- GlassCard, GradientButton, MiniMusicBar
│   └── main.dart                    <-- Hive & Servis başlatıcı
└── pubspec.yaml
```

---

## 📦 APK Üretme Rehberi (Nasıl APK Yapılır?)

Bu proje standart bir Flutter projesidir. Bilgisayarınızda veya herhangi bir ortamda APK üretmek için:

### 1. Adım: Bağımlılıkları Yükleyin
```bash
flutter pub get
```

### 2. Adım: Hızlı Test (Telefonda Çalıştırma)
Telefonunuzu USB ile bağlayıp USB Hata Ayıklama modunu açın:
```bash
flutter run
```

### 3. Adım: Yüklenebilir APK Dosyası Oluşturma (Release APK)
```bash
flutter build apk --release
```
İşlem tamamlandığında APK dosyanız şurada hazır olacaktır:
`build/app/outputs/flutter-apk/app-release.apk`
Bu dosyayı doğrudan telefonunuza atıp kurabilirsiniz!

### 4. Adım: Google Play Store İçin AAB (Android App Bundle) Üretme
Play Store'a yüklerken APK yerine AAB formatı istenir:
```bash
flutter build appbundle --release
```
Dosya konumu:
`build/app/outputs/bundle/release/app-release.aab`
