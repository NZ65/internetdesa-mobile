import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/sound_effects.dart';
import '../../../data/services/storage_service.dart';
import '../../providers/auth_provider.dart';
import '../main_shell_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username dan password wajib diisi.'),
          backgroundColor: AppTheme.accentOrange,
        ),
      );
      return;
    }

    SoundEffects.playTap();
    final auth = context.read<AuthProvider>();
    final success = await auth.login(username, password);

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
      );
    } else if (mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage!),
          backgroundColor: AppTheme.accentRed,
        ),
      );
    }
  }

  void _launchGitHubOAuth() async {
    SoundEffects.playTap();
    final url = Uri.parse('${AppConfig.defaultBaseUrl}${AppConfig.epGithubUrl}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showServerSettings() {
    final controller = TextEditingController(text: StorageService.getBaseUrl());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pengaturan Server API',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMain),
            ),
            const SizedBox(height: 8),
            const Text(
              'Masukkan domain atau IP server dashboard Internet Desa.',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'https://internetdesaku.my.id',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.dns_rounded),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final newUrl = controller.text.trim();
                if (newUrl.isNotEmpty) {
                  await StorageService.saveBaseUrl(newUrl);
                  if (mounted) Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Simpan URL Server'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.iceBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Server URL Config Shortcut on Top Right
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined, color: AppTheme.textMuted, size: 22),
                  onPressed: _showServerSettings,
                ),
              ),
              const SizedBox(height: 8),

              // Airi Mascot Character Illustration & Halo Speech Bubble
              Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE0F2FE), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.18),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3), width: 3),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/mascot_happy.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.face, size: 60, color: AppTheme.primaryBlue),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Speech Bubble Greeting
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('✨ ', style: TextStyle(fontSize: 14)),
                    Flexible(
                      child: Text(
                        'Sensei / Operator, selamat datang di Komando Sukorejo!',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Header Titles
              const Text(
                'INTERNET DESA',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryNavy,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Portal Manajemen Admin, Teknisi, & Sales',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),

              // Login Form Card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppTheme.softShadow,
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Username',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textMain),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'admin / rudi / haryanto',
                        hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textLight),
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: AppTheme.primaryBlue, size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Password',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textMain),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textLight),
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.primaryBlue, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppTheme.textLight,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Primary Login Button
                    ElevatedButton(
                      onPressed: auth.isLoading ? null : _submitLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: auth.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Masuk ke Sistem',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // GitHub OAuth Alternative
              OutlinedButton.icon(
                onPressed: _launchGitHubOAuth,
                icon: const Icon(Icons.code_rounded, size: 18),
                label: const Text('Masuk dengan Akun GitHub'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textMain,
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
