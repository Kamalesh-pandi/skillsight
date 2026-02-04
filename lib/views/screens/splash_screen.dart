import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/main_viewmodel.dart';
import '../../viewmodels/roadmap_viewmodel.dart';
import '../../constants/app_theme.dart';
import './login_screen.dart';
import './home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final mainVM = Provider.of<MainViewModel>(context, listen: false);

    authVM.userStream.listen((user) async {
      if (!mounted) return;

      if (user != null) {
        mainVM.onUserChanged(user.uid);

        final roadmapVM = Provider.of<RoadmapViewModel>(context, listen: false);
        roadmapVM.fetchRoadmap(user.uid);

        int retries = 0;
        while (mainVM.isLoading && retries < 25) {
          await Future.delayed(const Duration(milliseconds: 200));
          retries++;
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        mainVM.onUserChanged(null);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: MediaQuery.of(context).size.height * 0.30,
              child: Image.asset(
                'assets/images/app_icon.png',
                width: 270,
                height: 270,
              ),
            ),

            Positioned(
              top: MediaQuery.of(context).size.height * 0.30 + 220,
              child: const Text(
                'AI Skill Analysis & Roadmaps',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
            ),

            // Loader
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.3,
              child: const CircularProgressIndicator(
                strokeWidth: 2.8,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
