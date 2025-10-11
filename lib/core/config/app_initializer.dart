import 'package:flutter/material.dart';
import '../../shared/services/user_service.dart';
import '../../features/onboarding/pages/user_onboarding_page.dart';
import '../../features/onboarding/pages/get_started_page.dart';
import '../../features/home/pages/home_page.dart';

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    try {
      // Petite attente pour éviter les problèmes de timing
      await Future.delayed(const Duration(milliseconds: 100));

      final isFirstLaunch = await UserService.isFirstLaunch();
      print('Is first launch: $isFirstLaunch');

      if (mounted) {
        if (isFirstLaunch) {
          print('First launch - showing onboarding');
          // Première utilisation - afficher l'onboarding
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => UserOnboardingPage(
                onComplete: () {
                  print('Onboarding complete - navigating to GetStarted');
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const GetStarted(),
                    ),
                  );
                },
              ),
            ),
          );
        } else {
          print('Existing user - going to home');
          // Utilisateur existant - aller directement vers l'ecran principal
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const Home(),
            ),
          );
        }
      }
    } catch (e) {
      print('Error in _checkFirstLaunch: $e');
      // En cas d'erreur, afficher l'onboarding par défaut
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => UserOnboardingPage(
              onComplete: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const GetStarted(),
                  ),
                );
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff90B2F9),
              Color(0xff6A9EF7),
              Color(0xff4A8BF5),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 24),
              Text(
                'HordricWeather',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Initialisation...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
