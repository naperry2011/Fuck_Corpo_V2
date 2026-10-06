import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/break_mode.dart';
import '../core/receipt_styles.dart';
import '../core/pay_profile.dart';
import '../data/database.dart';
import '../data/settings_repository.dart';

final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override in main()'),
);

final settingsProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(sharedPrefsProvider)),
);

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final sessionsProvider = StreamProvider<List<Session>>(
  (ref) => ref.watch(databaseProvider).watchSessions(),
);

class ProfileNotifier extends Notifier<PayProfile?> {
  @override
  PayProfile? build() => ref.watch(settingsProvider).loadProfile();

  Future<void> save(PayProfile profile) async {
    await ref.read(settingsProvider).saveProfile(profile);
    state = profile;
  }
}

final profileProvider =
    NotifierProvider<ProfileNotifier, PayProfile?>(ProfileNotifier.new);

/// Pro entitlement. TEST MODE: unlock() just flips a local flag. Swap the
/// body for a Play Billing / RevenueCat purchase before release.
class ProNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(settingsProvider).proUnlocked;

  Future<void> unlock() async {
    await ref.read(settingsProvider).setProUnlocked(true);
    state = true;
  }

  Future<void> relock() async {
    await ref.read(settingsProvider).setProUnlocked(false);
    state = false;
  }
}

final proProvider = NotifierProvider<ProNotifier, bool>(ProNotifier.new);

class ReceiptStyleNotifier extends Notifier<ReceiptStyle> {
  @override
  ReceiptStyle build() {
    final isPro = ref.watch(proProvider);
    final saved = ref.watch(settingsProvider).cardTheme;
    final theme = ReceiptStyle.values
        .firstWhere((t) => t.name == saved, orElse: () => ReceiptStyle.classic);
    return theme.pro && !isPro ? ReceiptStyle.classic : theme;
  }

  Future<void> select(ReceiptStyle theme) async {
    await ref.read(settingsProvider).setCardTheme(theme.name);
    state = theme;
  }
}

final receiptStyleProvider =
    NotifierProvider<ReceiptStyleNotifier, ReceiptStyle>(ReceiptStyleNotifier.new);

class ActiveSessionNotifier extends Notifier<ActiveSession?> {
  @override
  ActiveSession? build() => ref.watch(settingsProvider).loadActive();

  Future<void> start(BreakMode mode) async {
    final session = ActiveSession(mode: mode, startedAt: DateTime.now());
    await ref.read(settingsProvider).saveActive(session);
    state = session;
  }

  Future<Session> stop() async {
    final active = state!;
    final ms = DateTime.now().difference(active.startedAt).inMilliseconds;
    final elapsed = Duration(milliseconds: ms < 0 ? 0 : ms);
    final rate = ref.read(profileProvider)!.rate;
    final row = await ref.read(databaseProvider).addSession(
          SessionsCompanion.insert(
            mode: active.mode,
            startedAt: active.startedAt,
            durationMs: elapsed.inMilliseconds,
            earned: rate.earned(elapsed),
          ),
        );
    await ref.read(settingsProvider).clearActive();
    state = null;
    return row;
  }
}

final activeSessionProvider =
    NotifierProvider<ActiveSessionNotifier, ActiveSession?>(
        ActiveSessionNotifier.new);
