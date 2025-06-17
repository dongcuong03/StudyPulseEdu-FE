import 'package:shared_preferences/shared_preferences.dart';

// this sharedPreference only store string values
class SharedPre {
  static SharedPreferences? _prefsInstance;
  static Future<SharedPreferences> get instance async => _prefsInstance ??= await SharedPreferences.getInstance();
}
