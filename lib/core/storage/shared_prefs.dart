import 'package:hasicx/core/index.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static late SharedPreferences _sharedPreferences;

  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<bool> setLastPlayedSong(Song song) async {
    if (song.uri == null) return false;
    bool isSaved = await _sharedPreferences.setString(
      'HASICX_LAST_SONG',
      song.uri.toString(),
    );
    return isSaved;
  }

  static String? getLastPlayedSong() {
    String? songUri = _sharedPreferences.getString('HASICX_LAST_SONG');
    return songUri;
  }

  static Future<bool> setLoopMode(LoopMode mode) async {
    bool isSaved = await _sharedPreferences.setInt(
      'HASICX_LOOP_MODE',
      mode.index,
    );
    return isSaved;
  }

  static LoopMode? getLoopMode() {
    int? loopModeIndex = _sharedPreferences.getInt('HASICX_LOOP_MODE');
    return loopModeIndex == null ? null : LoopMode.values[loopModeIndex];
  }

  static Future<bool> setRecentCount(int count) async {
    bool isSaved = await _sharedPreferences.setInt('HASICX_COUNT', count);
    return isSaved;
  }

  static int getRecentCount() {
    int count = _sharedPreferences.getInt('HASICX_COUNT') ?? 10;
    return count;
  }

  ///SHAREDPREFS HELPERS
  static Future<bool> setValue({
    required String key,
    required String value,
  }) async {
    bool isSaved = await _sharedPreferences.setString(key, value);
    return isSaved;
  }

  static String? getValue({required String key}) {
    String? value = _sharedPreferences.getString(key);
    return value;
  }

  static Future<bool> setBool({
    required String key,
    required bool value,
  }) async {
    bool isSaved = await _sharedPreferences.setBool(key, value);
    return isSaved;
  }

  static bool getBool({required String key}) {
    bool value = _sharedPreferences.getBool(key) ?? false;
    return value;
  }
}
