import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../config/app_routes.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final SharedPreferences _prefs;

  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._prefs) {
    _loadUserFromStorage();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  void _loadUserFromStorage() {
    final userId = _prefs.getString('userId');
    final userName = _prefs.getString('userName');
    final userEmail = _prefs.getString('userEmail');
    final userRole = _prefs.getString('userRole');

    if (userId != null && userName != null && userEmail != null && userRole != null) {
      _user = User(
        id: userId,
        fullName: userName,
        email: userEmail,
        role: userRole,
      );
      notifyListeners();
    }
  }

  String getHomeRoute() {
    if (_user == null) return AppRoutes.login;
    switch (_user!.role) {
      case 'buyer':
        return AppRoutes.buyerHome;
      case 'agent':
        return AppRoutes.agentHome;
      default:
        return AppRoutes.login;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );

      if (response['success'] == true) {
        await _saveUser(response['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      if (response['success'] == true) {
        await _saveUser(response['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        _error = 'Failed to get Google ID token';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final response = await _authService.googleLogin(idToken);

      if (response['success'] == true) {
        await _saveUser(response['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Google login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  Future<void> _saveUser(Map<String, dynamic> userData) async {
    final user = User.fromJson(userData);
    _user = user;

    await _prefs.setString('userId', user.id);
    await _prefs.setString('userName', user.fullName);
    await _prefs.setString('userEmail', user.email);
    await _prefs.setString('userRole', user.role);
  }

  Future<void> logout() async {
    _user = null;
    await _prefs.remove('userId');
    await _prefs.remove('userName');
    await _prefs.remove('userEmail');
    await _prefs.remove('userRole');
    await _authService.deleteToken();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}