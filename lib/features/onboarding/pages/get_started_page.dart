import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../shared/models/constants.dart';
import '../../shared/services/notification_service.dart';
import 'widgets/app_logo.dart';
import 'welcome.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({super.key});

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> with TickerProviderStateMixin {
  late AnimationController _cloudController;
  late AnimationController _sunController;

  @override
  void initState() {
    super.initState();
    _cloudController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _sunController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    // Initialiser les notifications
    NotificationService.initialize();
  }

  @override
  void dispose() {
    _cloudController.dispose();
    _sunController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Constants myConstants = Constants();
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              myConstants.primaryColor,
              myConstants.primaryColor.withOpacity(0.8),
              myConstants.secondaryColor.withOpacity(0.6),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Nuages animés en arrière-plan
            Positioned(
              top: 100,
              left: -50,
              child: AnimatedBuilder(
                animation: _cloudController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_cloudController.value * 100, 0),
                    child: Container(
                      width: 120,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 180,
              right: -30,
              child: AnimatedBuilder(
                animation: _cloudController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(-_cloudController.value * 80, 0),
                    child: Container(
                      width: 100,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Soleil animé
            Positioned(
              top: 120,
              right: 50,
              child: AnimatedBuilder(
                animation: _sunController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _sunController.value * 2 * 3.14159,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.yellow.withOpacity(0.7),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.yellow.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Contenu principal
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo et titre avec animations
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        AppLogo(
                          size: 80,
                          withShadow: true,
                          withAnimation: true,
                        ),
                        const SizedBox(height: 20),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Hordric',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                              TextSpan(
                                text: 'Weather',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white.withOpacity(0.9),
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 1000.ms)
                            .slideY(begin: 0.3),
                        const SizedBox(height: 10),
                        Text(
                          'Votre compagnon météo intelligent',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 500.ms, duration: 800.ms),
                      ],
                    ),
                  ).animate().fadeIn(duration: 1200.ms).slideY(begin: 0.2),

                  const SizedBox(height: 80),

                  // Image météo principale
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Image.asset(
                      'assets/get-started.png',
                      fit: BoxFit.contain,
                    ),
                  ).animate().scale(
                        delay: 600.ms,
                        duration: 1000.ms,
                        curve: Curves.elasticOut,
                      ),

                  const SizedBox(height: 60),

                  // Bouton d'action moderne
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const Welcome(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: animation.drive(
                                Tween(
                                    begin: const Offset(1.0, 0.0),
                                    end: Offset.zero),
                              ),
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 600),
                        ),
                      );
                    },
                    child: Container(
                      height: 60,
                      width: size.width * 0.8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.white.withOpacity(0.9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.explore_outlined,
                            color: myConstants.primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Découvrir la météo',
                            style: TextStyle(
                              color: myConstants.primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 1000.ms, duration: 600.ms)
                      .slideY(begin: 0.3),

                  const SizedBox(height: 30),

                  // Indicateurs de fonctionnalités
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFeatureIndicator(
                          Icons.location_on, 'Géolocalisation'),
                      _buildFeatureIndicator(Icons.notifications, 'Alertes'),
                      _buildFeatureIndicator(Icons.trending_up, 'Prévisions'),
                    ],
                  ).animate().fadeIn(delay: 1200.ms, duration: 800.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureIndicator(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
