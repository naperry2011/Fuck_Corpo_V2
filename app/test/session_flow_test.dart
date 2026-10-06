import 'package:drift/native.dart';
import 'package:fcorpo/core/break_mode.dart';
import 'package:fcorpo/core/pay_profile.dart';
import 'package:fcorpo/core/rate.dart';
import 'package:fcorpo/data/database.dart';
import 'package:fcorpo/widgets/pixel_ceo.dart';
import 'package:fcorpo/state/providers.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _container() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final db = AppDatabase(NativeDatabase.memory());
  final container = ProviderContainer(overrides: [
    sharedPrefsProvider.overrideWithValue(prefs),
    databaseProvider.overrideWithValue(db),
  ]);
  addTearDown(() async {
    container.dispose();
    await db.close();
  });
  return container;
}

const _profile = PayProfile(
  type: PayType.hourly,
  amount: 36,
  hoursPerWeek: 40,
  currency: r'$',
  bossName: 'Karen',
);

void main() {
  test('profile persists across containers', () async {
    final c = await _container();
    expect(c.read(profileProvider), isNull);
    await c.read(profileProvider.notifier).save(_profile);

    final fresh = ProviderContainer(overrides: [
      sharedPrefsProvider.overrideWithValue(c.read(sharedPrefsProvider)),
    ]);
    addTearDown(fresh.dispose);
    expect(fresh.read(profileProvider)?.bossName, 'Karen');
  });

  test('clock in then out saves an earned session', () async {
    final c = await _container();
    await c.read(profileProvider.notifier).save(_profile);
    final active = c.read(activeSessionProvider.notifier);

    await active.start(BreakMode.smoke);
    expect(c.read(activeSessionProvider)?.mode, BreakMode.smoke);
    expect(c.read(settingsProvider).loadActive(), isNotNull);

    final session = await active.stop();
    expect(session.mode, BreakMode.smoke);
    expect(session.earned, closeTo(0.01 * session.durationMs / 1000, 1e-9));
    expect(c.read(activeSessionProvider), isNull);
    expect(c.read(settingsProvider).loadActive(), isNull);

    final db = c.read(databaseProvider);
    expect(await db.select(db.sessions).get(), hasLength(1));
  });

  test('theme mode defaults to system and persists', () async {
    final c = await _container();
    expect(c.read(themeModeProvider), ThemeMode.system);
    await c.read(themeModeProvider.notifier).select(ThemeMode.light);

    final fresh = ProviderContainer(overrides: [
      sharedPrefsProvider.overrideWithValue(c.read(sharedPrefsProvider)),
    ]);
    addTearDown(fresh.dispose);
    expect(fresh.read(themeModeProvider), ThemeMode.light);
  });

  test('anger escalates with earnings', () {
    expect([0.1, 0.5, 2.0, 10.0].map(angerFor), [0, 1, 2, 3]);
  });
}
