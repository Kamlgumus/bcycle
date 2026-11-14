import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/user_model.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/glass_card.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _displayNameCtrl = TextEditingController();

  bool _isLoading = false;
  String? _error;

  // Kullanıcı adı doğrulama: sadece harf, rakam, alt çizgi, 3-20 karakter
  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Kullanıcı adı gerekli';
    if (value.length < 3) return 'En az 3 karakter olmalı';
    if (value.length > 20) return 'En fazla 20 karakter olmalı';
    final regex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!regex.hasMatch(value)) return 'Sadece harf, rakam ve _ kullanılabilir';

    // Aynı kullanıcı adı var mı?
    final box = Hive.box<UserModel>('users');
    final exists = box.values.any(
        (u) => u.username.toLowerCase() == value.toLowerCase());
    if (exists) return 'Bu kullanıcı adı zaten alınmış';
    return null;
  }

  String? _validateDisplayName(String? value) {
    if (value == null || value.isEmpty) return 'İsim gerekli';
    if (value.length < 2) return 'En az 2 karakter olmalı';
    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });

    try {
      final user = UserModel(
        id: const Uuid().v4(),
        username: _usernameCtrl.text.trim(),
        displayName: _displayNameCtrl.text.trim(),
        age: 0, // Sağlık bilgileri ekranında doldurulacak
        weightKg: 0,
        heightCm: 0,
        gender: '',
        createdAt: DateTime.now(),
      );

      final box = Hive.box<UserModel>('users');
      await box.put(user.id, user);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user_id', user.id);

      if (mounted) context.go('/health-info');
    } catch (e) {
      setState(() { _error = 'Kayıt hatası: $e'; _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _displayNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0A0F), Color(0xFF1A0A2E), Color(0xFF0A0A0F)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Geri butonu
                  GestureDetector(
                    onTap: () => context.go('/onboarding'),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 18),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Başlık
                  const Text(
                    'Hesap Oluştur',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontFamily: 'Nunito',
                    ),
                  ).animate().fadeIn().slideX(begin: -0.2, end: 0),

                  const SizedBox(height: 8),

                  Text(
                    'Kullanıcı adın benzersiz olacak — arkadaşların seni bununla bulacak!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 40),

                  // Form alanları
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Kullanıcı adı
                          _buildField(
                            controller: _usernameCtrl,
                            label: 'Kullanıcı Adı',
                            hint: 'ornek_ad123',
                            icon: Icons.alternate_email,
                            validator: _validateUsername,
                            onChanged: (_) => setState(() {}),
                          ),

                          const SizedBox(height: 20),

                          // Görünen ad
                          _buildField(
                            controller: _displayNameCtrl,
                            label: 'Görünen İsim',
                            hint: 'Adın veya takma adın',
                            icon: Icons.person_outline,
                            validator: _validateDisplayName,
                          ),

                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.red.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: Colors.red, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(_error!,
                                        style: const TextStyle(
                                            color: Colors.red,
                                            fontFamily: 'Nunito',
                                            fontSize: 13)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 32),

                  // Kayıt Butonu
                  GradientButton(
                    onPressed: _isLoading ? null : _register,
                    label: _isLoading ? 'Kaydediliyor...' : 'Devam Et →',
                    icon: _isLoading ? null : Icons.arrow_forward,
                    isLoading: _isLoading,
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 20),

                  // Not
                  Center(
                    child: Text(
                      '📌 Kullanıcı adın değiştirilemez, dikkatli seç!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontFamily: 'Nunito',
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(
        color: Colors.white,
        fontFamily: 'Nunito',
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
        labelStyle:
            const TextStyle(color: AppTheme.textSecondary, fontFamily: 'Nunito'),
        hintStyle:
            const TextStyle(color: AppTheme.textMuted, fontFamily: 'Nunito'),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        errorStyle: const TextStyle(fontFamily: 'Nunito', color: Colors.red),
      ),
    );
  }
}
