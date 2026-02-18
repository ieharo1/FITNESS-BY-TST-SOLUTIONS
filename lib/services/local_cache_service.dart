import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalCacheService {
  static const String _userKey = 'cached_user';
  static const String _progressKey = 'cached_progress';
  static const String _workoutsKey = 'cached_workouts';
  static const String _routinesKey = 'cached_routines';
  static const String _goalsKey = 'cached_goals';
  static const String _tutorialKey = 'tutorial_completed';
  static const String _lastSyncKey = 'last_sync';

  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> cacheUser(Map<String, dynamic> userData) async {
    await _prefs?.setString(_userKey, jsonEncode(userData));
  }

  static Map<String, dynamic>? getCachedUser() {
    final data = _prefs?.getString(_userKey);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<void> cacheProgress(List<Map<String, dynamic>> progress) async {
    await _prefs?.setString(_progressKey, jsonEncode(progress));
  }

  static List<Map<String, dynamic>> getCachedProgress() {
    final data = _prefs?.getString(_progressKey);
    if (data != null) {
      final list = jsonDecode(data) as List;
      return list.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<void> cacheWorkouts(List<Map<String, dynamic>> workouts) async {
    await _prefs?.setString(_workoutsKey, jsonEncode(workouts));
  }

  static List<Map<String, dynamic>> getCachedWorkouts() {
    final data = _prefs?.getString(_workoutsKey);
    if (data != null) {
      final list = jsonDecode(data) as List;
      return list.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<void> cacheRoutines(List<Map<String, dynamic>> routines) async {
    await _prefs?.setString(_routinesKey, jsonEncode(routines));
  }

  static List<Map<String, dynamic>> getCachedRoutines() {
    final data = _prefs?.getString(_routinesKey);
    if (data != null) {
      final list = jsonDecode(data) as List;
      return list.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<void> cacheGoals(Map<String, dynamic> goals) async {
    await _prefs?.setString(_goalsKey, jsonEncode(goals));
  }

  static Map<String, dynamic>? getCachedGoals() {
    final data = _prefs?.getString(_goalsKey);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<void> setTutorialCompleted(bool completed) async {
    await _prefs?.setBool(_tutorialKey, completed);
  }

  static bool isTutorialCompleted() {
    return _prefs?.getBool(_tutorialKey) ?? false;
  }

  static Future<void> setLastSync(DateTime dateTime) async {
    await _prefs?.setString(_lastSyncKey, dateTime.toIso8601String());
  }

  static DateTime? getLastSync() {
    final data = _prefs?.getString(_lastSyncKey);
    if (data != null) {
      return DateTime.tryParse(data);
    }
    return null;
  }

  static Future<void> clearAll() async {
    await _prefs?.clear();
  }

  static bool hasOfflineData() {
    return getCachedUser() != null ||
        getCachedProgress().isNotEmpty ||
        getCachedWorkouts().isNotEmpty ||
        getCachedRoutines().isNotEmpty;
  }
}
