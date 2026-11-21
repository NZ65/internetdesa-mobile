import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/sound_effects.dart';
import '../../../data/services/storage_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/zzz_button.dart';
import '../../widgets/zzz_card.dart';
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
      backgroundColor: AppTheme.bgCardElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppTheme.borderSubtle),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.dns_rounded, color: AppTheme.primaryCyan, size: 20),
                SizedBox(width: 8),
                Text(
                  'SERVER API CONFIG',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textMain,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Masukkan domain atau IP server dashboard Internet Desa.',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              style: const TextStyle(color: AppTheme.textMain),
              decoration: InputDecoration(
                hintText: 'https://internetdesaku.my.id',
                hintStyle: const TextStyle(color: AppTheme.textLight),
                filled: true,
                fillColor: AppTheme.bgDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primaryCyan)),
                prefixIcon: const Icon(Icons.link_rounded, color: AppTheme.primaryCyan),
              ),
            ),
            const SizedBox(height: 20),
            ZzzButton(
              label: 'SIMPAN URL SERVER',
              icon: Icons.save_rounded,
              type: ZzzButtonType.cyan,
              onPressed: () async {
                final newUrl = controller.text.trim();
                if (newUrl.isNotEmpty) {
                  await StorageService.saveBaseUrl(newUrl);
                  if (mounted) Navigator.pop(ctx);
                }
              },
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
      backgroundColor: AppTheme.bgDark,
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
              const SizedBox(height: 16),

              // Tactical ZZZ Cyber Emblem
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppTheme.bgCardElevated,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.primaryCyan, width: 2),
                  boxShadow: AppTheme.cyanGlow,
                ),
                child: const Center(
                  child: Icon(
                    Icons.wifi_tethering,
                    color: AppTheme.primaryCyan,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title Header
              const Text(
                'INTERNET DESA',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textMain,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.accentYellow,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'TACTICAL NOC & FIBER COMMAND SYSTEM',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                      color: AppTheme.primaryCyan,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Login Form Card
              ZzzCard(
                tag: 'LOGIN // AUTHENTICATION',
                isAccent: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'USERNAME',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                        color: AppTheme.textMuted,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _usernameController,
                      style: const TextStyle(color: AppTheme.textMain),
                      decoration: InputDecoration(
                        hintText: 'admin / rudi / haryanto',
                        hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textLight),
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: AppTheme.primaryCyan, size: 20),
                        filled: true,
                        fillColor: AppTheme.bgDark,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.borderSubtle),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.borderSubtle),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.primaryCyan, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'PASSWORD',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                        color: AppTheme.textMuted,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: AppTheme.textMain),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textLight),
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.primaryCyan, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppTheme.textLight,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        filled: true,
                        fillColor: AppTheme.bgDark,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.borderSubtle),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.borderSubtle),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.primaryCyan, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Primary Login Button
                    ZzzButton(
                      label: 'MASUK KE SISTEM NOC',
                      icon: Icons.login_rounded,
                      type: ZzzButtonType.cyan,
                      isLoading: auth.isLoading,
                      onPressed: auth.isLoading ? null : _submitLogin,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // GitHub OAuth Alternative
              ZzzButton(
                label: 'MASUK DENGAN GITHUB',
                icon: Icons.code_rounded,
                type: ZzzButtonType.muted,
                onPressed: _launchGitHubOAuth,
              ),
              const SizedBox(height: 24),

              // Version info footer
              Text(
                'v${AppConfig.appVersion} (BUILD ${AppConfig.appVersionCode}) // ZZZ INTERFACE',
                style: const TextStyle(
                  fontSize: 10,
                  fontFamily: 'monospace',
                  color: AppTheme.textLight,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
