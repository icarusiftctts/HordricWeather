import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'weather_widget_service.dart';
import 'notification_service.dart';

class BackgroundWeatherService {
  static const String _weatherApiKey = '46ad115e8b5bb2d45b72d8d29b90b3b4';
  static Timer? _updateTimer;
  static Timer? _alertTimer;

  static Future<void> initialize() async {
    try {
      print('Initialisation des services en arrière-plan...');

      // Démarrer les timers pour les mises à jour périodiques
      _startPeriodicUpdates();

      print('Services en arrière-plan initialisés');
    } catch (e) {
      print('Erreur lors de l\'initialisation des services: $e');
    }
  }

  static void _startPeriodicUpdates() {
    // Mise à jour météo toutes les 30 minutes
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      updateWeatherData();
    });

    // Vérification des alertes toutes les heures
    _alertTimer?.cancel();
    _alertTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      checkWeatherAlerts();
    });

    // Première mise à jour immédiate
    updateWeatherData();
  }

  static Future<void> updateWeatherData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Récupérer la position
      Position? position;
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.reduced,
            timeLimit: const Duration(seconds: 10),
          );
        }
      } catch (e) {
        print('Impossible de récupérer la position: $e');
      }

      // Utiliser la position ou la dernière position connue
      final double lat =
          position?.latitude ?? prefs.getDouble('last_latitude') ?? 6.1375;
      final double lon =
          position?.longitude ?? prefs.getDouble('last_longitude') ?? 1.2123;

      // Récupérer les données météo
      final weatherData = await _fetchWeatherData(lat, lon);
      if (weatherData != null) {
        // Sauvegarder les données
        await prefs.setString(
          'background_weather_data',
          json.encode(weatherData),
        );
        await prefs.setInt(
          'background_update_time',
          DateTime.now().millisecondsSinceEpoch,
        );

        // Mettre à jour le widget
        await WeatherWidgetService.updateWidget();

        print('Données météo mises à jour en arrière-plan');
      }
    } catch (e) {
      print('Erreur lors de la mise à jour en arrière-plan: $e');
    }
  }

  static Future<void> checkWeatherAlerts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final weatherDataString = prefs.getString('background_weather_data');

      if (weatherDataString != null) {
        final weatherData = json.decode(weatherDataString);

        // Vérifier les conditions météorologiques extrêmes
        final temp = weatherData['main']['temp'];
        final weatherMain = weatherData['weather'][0]['main'].toLowerCase();
        final windSpeed = weatherData['wind']['speed'] * 3.6; // Convert to km/h

        String? alertTitle;
        String? alertBody;

        // Alertes de température
        if (temp >= 35) {
          alertTitle = '🌡️ Alerte Canicule';
          alertBody =
              'Température élevée: ${temp.round()}°C. Hydratez-vous et évitez l\'exposition au soleil.';
        } else if (temp <= 5) {
          alertTitle = '❄️ Alerte Froid';
          alertBody =
              'Température très basse: ${temp.round()}°C. Couvrez-vous bien!';
        }

        // Alertes météorologiques
        if (weatherMain.contains('thunder')) {
          alertTitle = '⛈️ Alerte Orage';
          alertBody =
              'Orages détectés dans votre région. Restez en sécurité à l\'intérieur.';
        } else if (weatherMain.contains('rain') && windSpeed > 50) {
          alertTitle = '🌧️ Alerte Tempête';
          alertBody =
              'Fortes pluies et vents violents: ${windSpeed.round()} km/h. Évitez les déplacements.';
        } else if (windSpeed > 70) {
          alertTitle = '💨 Alerte Vent Fort';
          alertBody =
              'Vents très violents: ${windSpeed.round()} km/h. Attention aux chutes d\'objets.';
        }

        // Envoyer la notification d'alerte
        if (alertTitle != null && alertBody != null) {
          await NotificationService.showWeatherAlert(
            title: alertTitle,
            body: alertBody,
            weatherType: weatherMain,
          );
        }

        // Notification météo quotidienne (8h du matin)
        final now = DateTime.now();
        if (now.hour == 8 && now.minute < 30) {
          await NotificationService.showDailyWeatherNotification(weatherData);
        }
      }
    } catch (e) {
      print('Erreur lors de la vérification des alertes: $e');
    }
  }

  static Future<Map<String, dynamic>?> _fetchWeatherData(
    double lat,
    double lon,
  ) async {
    try {
      final url =
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_weatherApiKey&units=metric&lang=fr';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Erreur lors de la récupération des données: $e');
    }
    return null;
  }

  // Méthode publique pour récupérer les données météo actuelles
  static Future<Map<String, dynamic>?> getCurrentWeatherData() async {
    try {
      // Récupérer la position
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 10),
        );
      } catch (e) {
        print('Impossible d\'obtenir la position actuelle: $e');

        // Utiliser une position par défaut (Alger) si la géolocalisation échoue
        const double defaultLat = 36.753769;
        const double defaultLon = 3.0587561;
        return await _fetchWeatherData(defaultLat, defaultLon);
      }

      return await _fetchWeatherData(position.latitude, position.longitude);
    } catch (e) {
      print('Erreur lors de la récupération des données météo: $e');
    }
    return null;
  }

  static Future<void> cancelAllTasks() async {
    try {
      _updateTimer?.cancel();
      _alertTimer?.cancel();
      _updateTimer = null;
      _alertTimer = null;
      print('Toutes les tâches en arrière-plan ont été annulées');
    } catch (e) {
      print('Erreur lors de l\'annulation des tâches: $e');
    }
  }

  static void startLockScreenNotifications() {
    // Démarrer un timer pour afficher la météo sur l'écran de verrouillage
    Timer.periodic(const Duration(minutes: 15), (timer) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final weatherDataString = prefs.getString('background_weather_data');

        if (weatherDataString != null) {
          final weatherData = json.decode(weatherDataString);
          await NotificationService.showLockScreenWeatherNotification(
              weatherData);
        }
      } catch (e) {
        print('Erreur lors de l\'affichage sur l\'écran de verrouillage: $e');
      }
    });

    // Affichage immédiat
    _showInitialLockScreenNotification();
  }

  static Future<void> _showInitialLockScreenNotification() async {
    try {
      // Récupérer les données météo actuelles
      final weatherData = await getCurrentWeatherData();
      if (weatherData != null) {
        await NotificationService.showLockScreenWeatherNotification(
            weatherData);
      }
    } catch (e) {
      print(
          'Erreur lors de l\'affichage initial sur l\'écran de verrouillage: $e');
    }
  }

  static void dispose() {
    cancelAllTasks();
  }
}
