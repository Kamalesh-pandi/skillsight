import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../constants/app_theme.dart';
import 'register_screen.dart';
import 'splash_screen.dart';
import '../widgets/gradient_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleLogin() async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    bool success =
        await authVM.login(_emailController.text, _passwordController.text);
    if (success && mounted) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SplashScreen()));
    } else if (authVM.errorMessage != null && mounted) {
      print('DEBUG: HandleLogin Error: ${authVM.errorMessage}');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(authVM.errorMessage!)));
    }
  }

  void _handleGoogleSignIn() async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    bool success = await authVM.signInWithGoogle();
    if (success && mounted) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SplashScreen()));
    } else if (authVM.errorMessage != null && mounted) {
      print('DEBUG: HandleGoogleSignIn Error: ${authVM.errorMessage}');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(authVM.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      body: Stack(
        children: [
          // Decorative Background Element
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.3),
                    AppColors.secondary.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // App Branding
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: AppColors.primary, size: 32),
                  ),
                  const SizedBox(height: 24),
                  Text('Welcome Back',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text('Sign in to continue your learning journey',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 48),
                  // Form Container
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        if (Theme.of(context).brightness == Brightness.light)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                        ),
                        const SizedBox(height: 32),
                        GradientButton(
                          text: 'Sign In',
                          onPressed: authVM.isLoading ? null : _handleLogin,
                          isLoading: authVM.isLoading,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Social Sign In
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR',
                            style: TextStyle(
                                color:
                                    AppColors.textSecondary.withOpacity(0.5))),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      side: BorderSide(
                          color:
                              Theme.of(context).dividerColor.withOpacity(0.2)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: authVM.isLoading ? null : _handleGoogleSignIn,
                    icon: Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                      height: 24,
                    ),
                    label: Text('Continue with Google',
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen())),
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            const TextSpan(text: "Don't have an account? "),
                            TextSpan(
                              text: "Register",
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
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
