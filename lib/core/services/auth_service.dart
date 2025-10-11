import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { farmer, driver, labour }

class AuthService {
  static const String _roleKey = 'user_role';
  static const String _tokenKey = 'auth_token';

  static final AuthService _instance = AuthService._internal();
  late SharedPreferences _prefs;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  factory AuthService() => _instance;
  AuthService._internal();

  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  Future<bool> isFirstTime() async {
    _prefs = _prefs;
    return _prefs.getBool('first_time') ?? true;
  }

  Future<void> setNotFirstTime() async {
    _prefs = _prefs;
    await _prefs.setBool('first_time', false);
  }

  String _mapUsernameToEmail(String username) => '$username@myapp.com';

  Future<bool> isAuthenticated() async {
    return _auth.currentUser != null;
  }

  Future<void> signIn(String username, String password) async {
    final email = _mapUsernameToEmail(username);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _prefs.setString(_tokenKey, _auth.currentUser!.uid);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> signUp(String username, String password) async {
    final email = _mapUsernameToEmail(username);
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _prefs.setString(_tokenKey, _auth.currentUser!.uid);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
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
