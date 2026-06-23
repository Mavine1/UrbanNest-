import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../config/app_routes.dart'; // updated import

// ... inside AuthProvider class

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