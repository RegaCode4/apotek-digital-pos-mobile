import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'shared/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/pos/screens/pos_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Force app orientation to always landscape
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  await initializeDateFormatting('id_ID', null);

  runApp(
    const ProviderScope(
      child: ApotekDigitalPosApp(),
    ),
  );
}

class ApotekDigitalPosApp extends ConsumerWidget {
  const ApotekDigitalPosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Apotek Digital POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: authState.isLoading
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : authState.isAuthenticated
              ? const PosScreen()
              : const LoginScreen(),
    );
  }
}
