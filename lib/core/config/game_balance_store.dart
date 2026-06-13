import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'game_balance.dart';

/// Dev-only persistence for [GameBalance] tweaks made in the debug tuning
/// panel, so a tuning session survives app restarts.
///
/// This is intentionally **outside** the per-account Drift database and the
/// sync outbox — tuned values are local developer data, never synced. It is
/// only ever loaded/saved behind a `kDebugMode` guard, so release builds keep
/// `GameBalance.I` at its shipped defaults.
abstract final class GameBalanceStore {
  static const _key = 'dev.game_balance.v1';

  static SharedPreferences? _prefs;

  /// Load any previously-saved tweaks into the live config. Call once at
  /// startup (debug only). Corrupt/old blobs are ignored.
  static Future<void> load() async {
    final prefs = _prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) GameBalance.I.applyJson(decoded);
    } catch (_) {
      // Stored blob is unreadable (schema drift / corruption) — drop it.
      await prefs.remove(_key);
    }
  }

  /// Persist the current values. Fire-and-forget; safe to call on every slider
  /// change. No-op if [load] was never called (release build).
  static void save() {
    final prefs = _prefs;
    if (prefs == null) return;
    prefs.setString(_key, jsonEncode(GameBalance.I.toJson()));
  }

  /// Forget all saved tweaks (used by the panel's reset-to-defaults).
  static void clear() {
    _prefs?.remove(_key);
  }
}
