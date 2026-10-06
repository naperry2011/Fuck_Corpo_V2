import 'package:shared_preferences/shared_preferences.dart';

import '../core/break_mode.dart';
import '../core/pay_profile.dart';
import '../core/rate.dart';

class ActiveSession {
  const ActiveSession({required this.mode, required this.startedAt});

  final BreakMode mode;
  final DateTime startedAt;
}

class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _payType = 'pay_type';
  static const _amount = 'pay_amount';
  static const _hours = 'hours_per_week';
  static const _currency = 'currency';
  static const _boss = 'boss_name';
  static const _activeMode = 'active_mode';
  static const _activeStart = 'active_started_ms';

  PayProfile? loadProfile() {
    final type = _prefs.getString(_payType);
    final amount = _prefs.getDouble(_amount);
    final hours = _prefs.getDouble(_hours);
    if (type == null || amount == null || hours == null) return null;
    return PayProfile(
      type: PayType.values.byName(type),
      amount: amount,
      hoursPerWeek: hours,
      currency: _prefs.getString(_currency) ?? r'$',
      bossName: _prefs.getString(_boss) ?? 'the boss',
    );
  }

  Future<void> saveProfile(PayProfile p) async {
    await _prefs.setString(_payType, p.type.name);
    await _prefs.setDouble(_amount, p.amount);
    await _prefs.setDouble(_hours, p.hoursPerWeek);
    await _prefs.setString(_currency, p.currency);
    await _prefs.setString(_boss, p.bossName);
  }

  static const _themeMode = 'theme_mode';

  String? get themeMode => _prefs.getString(_themeMode);

  Future<void> setThemeMode(String name) =>
      _prefs.setString(_themeMode, name);

  static const _pro = 'pro_unlocked';
  static const _cardTheme = 'card_theme';

  bool get proUnlocked => _prefs.getBool(_pro) ?? false;

  Future<void> setProUnlocked(bool value) => _prefs.setBool(_pro, value);

  String? get cardTheme => _prefs.getString(_cardTheme);

  Future<void> setCardTheme(String name) =>
      _prefs.setString(_cardTheme, name);

  ActiveSession? loadActive() {
    final mode = _prefs.getString(_activeMode);
    final start = _prefs.getInt(_activeStart);
    if (mode == null || start == null) return null;
    return ActiveSession(
      mode: BreakMode.values.byName(mode),
      startedAt: DateTime.fromMillisecondsSinceEpoch(start),
    );
  }

  Future<void> saveActive(ActiveSession s) async {
    await _prefs.setString(_activeMode, s.mode.name);
    await _prefs.setInt(_activeStart, s.startedAt.millisecondsSinceEpoch);
  }

  Future<void> clearActive() async {
    await _prefs.remove(_activeMode);
    await _prefs.remove(_activeStart);
  }
}
