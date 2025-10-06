import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { farmer, driver, labour }

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'user_role';
  static final AuthService _instance = AuthService._internal();
  late SharedPreferences _prefs;

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> isFirstTime() async {
    return !(_prefs.getBool('not_first_time') ?? false);
  }

  Future<void> setNotFirstTime() async {
    await _prefs.setBool('not_first_time', true);
  }

  Future<bool> isAuthenticated() async {
    final token = _prefs.getString(_tokenKey);
    return token != null;
  }

  Future<void> signIn(String username, String password) async {
    // TODO: Implement actual authentication logic
    await _prefs.setString(_tokenKey, 'dummy_token');
  }

  Future<void> signUp(String username, String password) async {
    // TODO: Implement actual sign up logic
    await _prefs.setString(_tokenKey, 'dummy_token');
  }

  Future<void> signOut() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_roleKey);
  }

  Future<void> setUserRole(UserRole role) async {
    await _prefs.setString(_roleKey, role.toString());
  }

  Future<UserRole?> getUserRole() async {
    final roleStr = _prefs.getString(_roleKey);
    if (roleStr == null) return null;
    return UserRole.values.firstWhere(
      (e) => e.toString() == roleStr,
      orElse: () => throw Exception('Invalid role stored'),
    );
  }

  Future<bool> isRoleRegistered(UserRole role) async {
    return _prefs.getBool('registered_${role.toString()}') ?? false;
  }

  Future<void> registerRole(UserRole role) async {
    await _prefs.setBool('registered_${role.toString()}', true);
  }
}
