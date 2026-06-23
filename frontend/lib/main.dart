import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'config/app_routes.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/home/buyer_home.dart';
import 'screens/home/agent_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  final prefs = await SharedPreferences.getInstance();

  final authProvider = AuthProvider(prefs);
  await authProvider.checkAuthStatus();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ],
      child: const UrbanestApp(),
    ),
  );
}

class UrbanestApp extends StatelessWidget {
  const UrbanestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return MaterialApp(
          title: 'Urbanest',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: authProvider.isAuthenticated
              ? authProvider.user?.role == 'buyer'
                  ? const BuyerHome()
                  : const AgentHome()
              : const SplashScreen(),
          routes: {
            AppRoutes.splash: (_) => const SplashScreen(),
            AppRoutes.onboarding: (_) => const OnboardingScreen(),
            AppRoutes.login: (_) => const LoginScreen(),
            AppRoutes.register: (_) => const RegisterScreen(),
            AppRoutes.buyerHome: (_) => const BuyerHome(),
            AppRoutes.agentHome: (_) => const AgentHome(),
          },
        );
      },
    );
  }
}