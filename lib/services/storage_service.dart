import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _kState = 'app_state_v1';

  Future<void> saveState(Map<String, dynamic> json) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kState, jsonEncode(json));
  }

  Future<Map<String, dynamic>?> loadState() async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString(_kState);
    if (s == null) return null;
    return jsonDecode(s) as Map<String, dynamic>;
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kState);
  }
}
