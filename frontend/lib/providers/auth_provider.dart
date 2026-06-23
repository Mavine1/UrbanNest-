import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../config/app_routes.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

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

  Future<void> _saveUserAndToken(Map<String, dynamic> data) async {
    final token = data['token'] as String;
    final userData = data['user'] as Map<String, dynamic>;
    final user = User.fromJson(userData);

    await _secureStorage.write(key: 'token', value: token);
    await _prefs.setString('userId', user.id);
    await _prefs.setString('userName', user.fullName);
    await _prefs.setString('userEmail', user.email);
    await _prefs.setString('userRole', user.role);

    _user = user;
    notifyListeners();
  }

  Future<void> _clearUserAndToken() async {
    await _secureStorage.delete(key: 'token');
    await _prefs.remove('userId');
    await _prefs.remove('userName');
    await _prefs.remove('userEmail');
    await _prefs.remove('userRole');
    _user = null;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final token = await _secureStorage.read(key: 'token');
    if (token != null && _user == null) {
      _loadUserFromStorage();
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

  // Store pending registration data for OTP verification
  Map<String, String>? _pendingRegistration;

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

      // Store pending registration data for OTP verification
      _pendingRegistration = {
        'userId': response['userId'] ?? '',
        'email': email,
      };

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Map<String, String>? get pendingRegistration => _pendingRegistration;

  Future<bool> verifyOTP(String userId, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dio = Dio();
      dio.options.baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:5000/api';

      final response = await dio.post(
        '/auth/verify-otp',
        data: {'userId': userId, 'otp': otp},
      );

      if (response.statusCode == 200) {
        await _saveUserAndToken(response.data);
        _pendingRegistration = null;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = response.data['message'] ?? 'Verification failed';
      _isLoading = false;
      notifyListeners();
      return false;
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
      final response = await _authService.login(email: email, password: password);
      await _saveUserAndToken(response);
      _isLoading = false;
      notifyListeners();
      return true;
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
      await _saveUserAndToken(response);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _clearUserAndToken();
    await _googleSignIn.signOut();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}