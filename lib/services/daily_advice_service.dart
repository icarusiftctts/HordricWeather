import 'dart:async';
import '../services/notification_service.dart';
import '../services/background_service.dart';

class DailyAdviceService {
  static Timer? _dailyTimer;

  static Future<void> initialize() async {
    try {
      print('Initialisation du service de conseils quotidiens...');

      // Programmer l'exécution quotidienne à 8h
      _scheduleDailyAdvice();

      print('Service de conseils quotidiens initialisé');
    } catch (e) {
      print(
          'Erreur lors de l\'initialisation du service de conseils quotidiens: $e');
    }
  }

  static void _scheduleDailyAdvice() {
    // Calculer le temps jusqu'à 8h du matin
    final now = DateTime.now();
    var nextRun = DateTime(now.year, now.month, now.day, 8, 0);

    // Si 8h est déjà passé aujourd'hui, programmer pour demain
    if (nextRun.isBefore(now)) {
      nextRun = nextRun.add(const Duration(days: 1));
    }

    final timeUntilNextRun = nextRun.difference(now);

    print('Prochain conseil du matin programmé pour: ${nextRun.toString()}');
    print(
        'Dans: ${timeUntilNextRun.inHours}h ${timeUntilNextRun.inMinutes % 60}min');

    // Programmer le premier conseil
    Timer(timeUntilNextRun, () {
      sendMorningAdvice();

      // Puis programmer pour tous les jours suivants
      _dailyTimer = Timer.periodic(const Duration(days: 1), (timer) {
        sendMorningAdvice();
      });
    });
  }

  static Future<void> sendMorningAdvice() async {
    try {
      print('Envoi du conseil du matin...');

      // Récupérer les données météo actuelles
      final weatherData =
          await BackgroundWeatherService.getCurrentWeatherData();

      if (weatherData != null) {
        final main = weatherData['main'];
        final weather = weatherData['weather'][0];
        final wind = weatherData['wind'];

        final temperature = (main['temp'] as num).toDouble();
        final humidity = (main['humidity'] as num).toInt();
        final windSpeed =
            (wind['speed'] as num).toDouble() * 3.6; // Convertir m/s en km/h
        final weatherDescription = weather['description'] as String;

        // Envoyer la notification avec les vraies données météo
        await NotificationService.showMorningWeatherAdvice(
          weatherDescription: weatherDescription,
          temperature: temperature,
          humidity: humidity,
          windSpeed: windSpeed,
        );

        print('Conseil du matin envoyé avec succès');
      } else {
        // En cas d'échec, envoyer un conseil général
        await NotificationService.showMorningWeatherAdvice(
          weatherDescription: 'temps variable',
          temperature: 20.0,
          humidity: 60,
          windSpeed: 10.0,
        );

        print('Conseil du matin envoyé avec données par défaut');
      }
    } catch (e) {
      print('Erreur lors de l\'envoi du conseil du matin: $e');
    }
  }

  static void dispose() {
    _dailyTimer?.cancel();
    _dailyTimer = null;
  }
}
