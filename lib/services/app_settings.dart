import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static const _markReadOnScrollKey = 'mark_read_on_scroll';

  static Future<bool> getMarkReadOnScroll() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_markReadOnScrollKey) ?? false;
  }

  static Future<void> setMarkReadOnScroll(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_markReadOnScrollKey, value);
  }
}
