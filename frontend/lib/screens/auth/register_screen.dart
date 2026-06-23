import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_routes.dart';
import '../../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=1200&h=800&fit=crop&q=80',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.4)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create Your Account',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                            controller: _fullNameController,
                            style: const TextStyle(color: AppColors.black),
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: const Icon(Icons.person_outline),
                              filled: true,
                              fillColor: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: AppColors.black),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(Icons.email_outlined),
                              filled: true,
                              fillColor: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(color: AppColors.black),
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              prefixIcon: const Icon(Icons.phone_outlined),
                              filled: true,
                              fillColor: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: AppColors.black),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: 'Create Account',
                            onPressed: () async {
                              if (_fullNameController.text.isEmpty ||
                                  _emailController.text.isEmpty ||
                                  _phoneController.text.isEmpty ||
                                  _passwordController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Please fill in all fields')),
                                );
                                return;
                              }
                              setState(() => _isLoading = true);
                              final success = await authProvider.register(
                                fullName: _fullNameController.text.trim(),
                                email: _emailController.text.trim(),
                                phone: _phoneController.text.trim(),
                                password: _passwordController.text.trim(),
                                role: 'buyer',
                              );
                              setState(() => _isLoading = false);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Registration successful! You are now registered as a buyer. Please verify your OTP.',
                                    ),
                                  ),
                                );
                                Navigator.pushReplacementNamed(
                                    context, AppRoutes.login);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Registration failed. Try again.')),
                                );
                              }
                            },
                            isLoading: _isLoading,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: Divider(color: AppColors.gray300)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text('or',
                                    style: GoogleFonts.inter(
                                        color: AppColors.gray500)),
                              ),
                              Expanded(child: Divider(color: AppColors.gray300)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: 'Sign up with Google',
                            onPressed: () async {
                              setState(() => _isLoading = true);
                              final success = await authProvider
                                  .signInWithGoogle();
                              setState(() => _isLoading = false);
                              if (success) {
                                Navigator.pushReplacementNamed(
                                    context, authProvider.getHomeRoute());
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Google sign-up failed. Try again.')),
                                );
                              }
                            },
                            backgroundColor: AppColors.white,
                            textColor: const Color(0xFF4285F4), // Google Blue
                            borderColor: AppColors.gray300,
                            isLoading: _isLoading,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account?",
                                style: GoogleFonts.inter(
                                    color: AppColors.gray600),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, AppRoutes.login);
                                },
                                child: Text(
                                  'Sign In',
                                  style: GoogleFonts.inter(
                                    color: AppColors.primaryOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}