import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { farmer, driver, labour }

class AuthService {
  static const String _roleKey = 'user_role';
  static const String _tokenKey = 'auth_token';
  static const String _firstTimeKey = 'is_first_time'; // <-- added

  static final AuthService _instance = AuthService._internal();
  late SharedPreferences _prefs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory AuthService() => _instance;
  AuthService._internal();

  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  String? getCurrentUserId() => _auth.currentUser?.uid;

  /// -------------------- FIRST TIME CHECK --------------------
  Future<bool> isFirstTime() async {
    if (!_initialized) await init();
    return _prefs.getBool(_firstTimeKey) ?? true; // default true
  }

  Future<void> setNotFirstTime() async {
    if (!_initialized) await init();
    await _prefs.setBool(_firstTimeKey, false);
  }

  /// -------------------- SIGN UP --------------------
  Future<void> signUp(String username, String password) async {
    final email = '$username@myapp.com';

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save token locally
      await _prefs.setString(_tokenKey, userCredential.user!.uid);

      // Create user doc in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'roles': {'farmer': false, 'driver': false, 'labour': false},
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// -------------------- SIGN IN --------------------
  Future<void> signIn(String username, String password) async {
    final email = '$username@myapp.com';
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _prefs.setString(_tokenKey, _auth.currentUser!.uid);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// -------------------- SIGN OUT --------------------
  Future<void> signOut() async {
    await _auth.signOut();
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_roleKey);
  }

  /// -------------------- ROLE MANAGEMENT --------------------
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

  /// -------------------- REGISTER ROLE --------------------
  Future<void> registerRole(UserRole role, Map<String, dynamic> details) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not signed in');

    final roleKey = role.toString().split('.').last;

    // Update Firestore user doc
    await _firestore.collection('users').doc(uid).set({
      'roles.$roleKey': true,
      '${roleKey}Details': details,
    }, SetOptions(merge: true));

    // Mark locally
    await _prefs.setBool('registered_$roleKey', true);
  }

  Future<bool> isRoleRegistered(UserRole role) async {
    final roleKey = role.toString().split('.').last;
    return _prefs.getBool('registered_$roleKey') ?? false;
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final snapshot = await _firestore.collection('users').doc(uid).get();
    return snapshot.data();
  }

  Future<void> registerLabour(Map<String, dynamic> details) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not signed in');

    await registerRole(UserRole.labour, details);
  }

  Future<bool> isAuthenticated() async => _auth.currentUser != null;
}
