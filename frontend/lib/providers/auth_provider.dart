import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../config/routes.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SharedPreferences _prefs;

  User? _user;
  String? _token;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  AuthProvider(this._prefs) {
    checkAuthStatus();
  }

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> checkAuthStatus() async {
    _token = await _authService.getToken();
    if (_token != null) {
      final userJson = _prefs.getString('user');
      if (userJson != null) {
        _user = User.fromJson(Map<String, dynamic>.from(userJson as Map));
        _isAuthenticated = true;
      }
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _authService.login(email: email, password: password);
      _token = data['token'];
      _user = User.fromJson(data['user']);
      await _authService.saveToken(_token!);
      await _prefs.setString('user', _user!.toJson().toString());
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
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
    notifyListeners();
    try {
      final data = await _authService.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String idToken = googleAuth.idToken!;
      final data = await _authService.googleLogin(idToken);
      _token = data['token'];
      _user = User.fromJson(data['user']);
      await _authService.saveToken(_token!);
      await _prefs.setString('user', _user!.toJson().toString());
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.deleteToken();
    await _prefs.remove('user');
    _user = null;
    _token = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // Only two roles: buyer and agent
  String getHomeRoute() {
    if (_user == null) return Routes.login;
    switch (_user!.role) {
      case 'buyer':
        return Routes.buyerHome;
      case 'agent':
        return Routes.agentHome;
      default:
        return Routes.login;
    }
  }
}