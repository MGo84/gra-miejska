class AuthService {
  static Future<bool> loginWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // symulacja API
    return email == "demo@demo.pl" && password == "demo";
  }

  static Future<void> loginAnonymously() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }
}
