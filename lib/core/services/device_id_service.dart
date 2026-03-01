import 'package:nanoid/nanoid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdService {
  static const _key = 'device_id';

  static Future<String> getOrCreate() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_key);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final id = nanoid();
    await prefs.setString(_key, id);
    return id;
  }
}
