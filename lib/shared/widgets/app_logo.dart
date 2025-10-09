import 'package:flutter/material.dart';

/// Widget réutilisable pour afficher le logo de l'application HordricWeather
class AppLogo extends StatelessWidget {
  final double size;
  final bool withShadow;
  final bool withAnimation;

  const AppLogo({
    Key? key,
    this.size = 60,
    this.withShadow = true,
    this.withAnimation = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget logo = Container(
      width: size,
      height: size,
      decoration: withShadow
          ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : null,
      child: ClipOval(
        child: Image.asset(
          'assets/img.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback si l'image n'est pas trouvée
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2E3192),
                    Color(0xFF1BCEDF),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.cloud,
                  color: Colors.white,
                  size: size * 0.5,
                ),
              ),
            );
          },
        ),
      ),
    );

    if (withAnimation) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: logo,
      );
    }

    return logo;
  }
}

/// Logo avec texte pour les écrans d'accueil
class AppLogoWithText extends StatelessWidget {
  final double logoSize;
  final double fontSize;
  final bool withAnimation;

  const AppLogoWithText({
    Key? key,
    this.logoSize = 80,
    this.fontSize = 24,
    this.withAnimation = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogo(
          size: logoSize,
          withShadow: true,
          withAnimation: withAnimation,
        ),
        const SizedBox(height: 16),
        Text(
          'HordricWeather',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
