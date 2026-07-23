import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'shared/theme/app_theme.dart';
import 'features/splash/screens/splash_screen.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Force app orientation to always landscape (mobile only)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
  
  await initializeDateFormatting('id_ID', null);

  runApp(
    const ProviderScope(
      child: ApotekDigitalPosApp(),
    ),
  );
}

class ApotekDigitalPosApp extends StatelessWidget {
  const ApotekDigitalPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apotek Digital POS',
      debugShowCheckedModeBanner: false,
      scrollBehavior: AppScrollBehavior(),
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
