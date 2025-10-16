import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  // Zapis użytkownika
  static Future<void> saveUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
    await prefs.setString('user_password', password);
  }

  // Pobranie danych użytkownika
  static Future<Map<String, String?>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString('user_email'),
      'password': prefs.getString('user_password'),
    };
  }

  // Ustawienie statusu zalogowany / wylogowany
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', value);
  }

  // Pobranie statusu logowania
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // Wylogowanie – usuwa tylko status, nie dane
  static Future<void> logout() async {
    await setLoggedIn(false);
  }
}
