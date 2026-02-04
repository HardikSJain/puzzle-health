import '../shared_preference/shared_preference_keys.dart';
import '../shared_preference/shared_preference_manager.dart';

class SharedPrefsService {
  Future<String?> getAccessToken() async {
    return SharedPreferenceManager.getString(SharedPreferenceKeys.accessToken);
  }

  Future<void> clearAllData() async {
    await SharedPreferenceManager.clearAll();
  }

  Future<bool> checkFirstLogin() async {
    String? isFirstLogin =
        SharedPreferenceManager.getString(SharedPreferenceKeys.firstLogin);

    return isFirstLogin == null;
  }

  Future<void> storeAccessToken(String token) async {
    SharedPreferenceManager.setString(SharedPreferenceKeys.accessToken, token);
  }
}
