import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WeatherItem extends StatelessWidget {
  const WeatherItem({
    super.key,
    required this.value,
    required this.text,
    required this.unit,
    required this.imageUrl,
    this.animationDelay = 0,
    this.isGlassmorphism = false,
  });

  final dynamic value;
  final String text;
  final String unit;
  final String imageUrl;
  final int animationDelay;
  final bool isGlassmorphism;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isGlassmorphism
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.1),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.blue.shade50.withOpacity(0.5),
                ],
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(isGlassmorphism ? 0.3 : 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Texte descriptif
          Flexible(
            flex: 2,
            child: Text(
              text,
              style: TextStyle(
                color: isGlassmorphism
                    ? Colors.white.withOpacity(0.9)
                    : Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Icône avec animation
          Flexible(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xff90B2F9).withOpacity(0.3),
                    const Color(0xff90B2F8).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                imageUrl,
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              )
                  .animate(delay: Duration(milliseconds: animationDelay + 200))
                  .scale(duration: 800.ms, curve: Curves.elasticOut)
                  .rotate(duration: 600.ms),
            ),
          ),

          // Valeur et unité
          Flexible(
            flex: 2,
            child: FittedBox(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color:
                            isGlassmorphism ? Colors.white : Colors.grey[800],
                      ),
                    ),
                    TextSpan(
                      text: unit,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: isGlassmorphism
                            ? Colors.white.withOpacity(0.8)
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: animationDelay))
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3)
        .scaleXY(begin: 0.8, curve: Curves.elasticOut);
  }
}
