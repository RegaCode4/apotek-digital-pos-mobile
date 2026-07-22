import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/neubrutal_style.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import '../../pos/screens/pos_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: 'kasir@apotek.com');
  final _passwordController = TextEditingController(text: 'password');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = await ref.read(authProvider.notifier).login(email, password);

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PosScreen()),
      );
    }
  }

  void _showServerSettingsDialog() async {
    final storageService = ref.read(storageServiceProvider);
    final currentCustomUrl = await storageService.getBaseUrl();
    final urlController = TextEditingController(
      text: currentCustomUrl ?? ApiEndpoints.baseUrl,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.darkBrutal, width: 2),
          ),
          title: const Row(
            children: [
              HeroIcon(HeroIcons.cog6Tooth, color: AppColors.primary, size: 22),
              SizedBox(width: 8),
              Text(
                'Pengaturan Server API',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan URL backend Laravel API tempat server dijalankan:',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(
                  labelText: 'Base URL API',
                  hintText: 'http://localhost:8000/api',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pilihan Quick Preset:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ActionChip(
                    label: const Text('Web / Localhost (8000)', style: TextStyle(fontSize: 10)),
                    onPressed: () {
                      urlController.text = 'http://localhost:8000/api';
                    },
                  ),
                  ActionChip(
                    label: const Text('HP Hotspot (192.168.137.1)', style: TextStyle(fontSize: 10)),
                    onPressed: () {
                      urlController.text = 'http://192.168.137.1:8000/api';
                    },
                  ),
                  ActionChip(
                    label: const Text('Android Emulator (10.0.2.2)', style: TextStyle(fontSize: 10)),
                    onPressed: () {
                      urlController.text = 'http://10.0.2.2:8000/api';
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan & Hubungkan'),
              onPressed: () {
                final newUrl = urlController.text.trim();
                if (newUrl.isNotEmpty) {
                  ref.read(apiClientProvider).updateBaseUrl(newUrl);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('URL Server diubah ke: $newUrl'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                  Navigator.of(context).pop();
                  _handleLogin();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(32),
            decoration: NeubrutalStyle.card(
              shadowOffset: 5.0,
              borderRadius: 16.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Icon & Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 32),
                      const AppLogo(size: 52),
                      IconButton(
                        icon: const HeroIcon(HeroIcons.cog6Tooth, size: 22, color: AppColors.textMuted),
                        tooltip: 'Pengaturan Server API',
                        onPressed: _showServerSettingsDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Apotek Digital POS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBrutal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Silakan login menggunakan akun Kasir Anda',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Error alert banner
                  if (authState.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.dangerSoft,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.danger.withAlpha(77)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const HeroIcon(HeroIcons.exclamationCircle,
                                  color: AppColors.danger, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  authState.errorMessage!,
                                  style: const TextStyle(
                                    color: AppColors.danger,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _showServerSettingsDialog,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                HeroIcon(HeroIcons.wrench, size: 14, color: AppColors.danger),
                                SizedBox(width: 4),
                                Text(
                                  'Ubah URL Server API',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.danger,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Form Inputs
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email Kasir',
                    hint: 'masukkan email (contoh: kasir@apotek.com)',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email wajib diisi';
                      if (!v.contains('@')) return 'Format email tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'masukkan password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password wajib diisi';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  CustomButton(
                    text: 'Login Kasir',
                    isLoading: authState.isLoading,
                    onPressed: _handleLogin,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
