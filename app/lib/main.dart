import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme.dart';
import 'features/onboarding/intake_form_screen.dart';
import 'features/pro/billing.dart';
import 'features/home_shell.dart';
import 'state/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(
      ['Courier Prime'],
      await rootBundle.loadString('assets/fonts/OFL.txt'),
    );
  });
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    child: const FuckCorpoApp(),
  ));
}

class FuckCorpoApp extends ConsumerWidget {
  const FuckCorpoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasProfile = ref.watch(profileProvider.select((p) => p != null));
    // Start billing at launch so purchases from earlier sessions get
    // delivered and acknowledged even if the paywall is never opened.
    if (!unlockProForThisBuild) ref.watch(billingProvider);
    return MaterialApp(
      title: 'F*ck Corpo',
      debugShowCheckedModeBanner: false,
      theme: payslipLight,
      darkTheme: payslipNightShift,
      themeMode: ref.watch(themeModeProvider),
      home: hasProfile ? const HomeShell() : const IntakeFormScreen(),
    );
  }
}
