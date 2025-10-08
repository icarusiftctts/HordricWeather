import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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

      // Récupérer les données météo actuelles
      final weatherData = await _fetchWeatherData(lat, lon);
      if (weatherData != null) {
        // Vérifier si le temps a changé
        await _checkWeatherChanges(prefs, weatherData);
        
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
      
      // Récupérer et vérifier les prévisions horaires
      await _checkHourlyForecast(lat, lon);
    } catch (e) {
      print('Erreur lors de la mise à jour en arrière-plan: $e');
    }
  }

  static Future<void> _checkWeatherChanges(
    SharedPreferences prefs,
    Map<String, dynamic> newWeatherData,
  ) async {
    try {
      final oldWeatherString = prefs.getString('background_weather_data');
      if (oldWeatherString != null) {
        final oldWeatherData = json.decode(oldWeatherString);
        
        final oldCondition = oldWeatherData['weather'][0]['main'];
        final newCondition = newWeatherData['weather'][0]['main'];
        
        final oldTemp = oldWeatherData['main']['temp'].round();
        final newTemp = newWeatherData['main']['temp'].round();
        
        // Vérifier si on a déjà notifié ce changement récemment (cooldown de 2 heures)
        final lastChangeNotif = prefs.getInt('last_change_notification') ?? 0;
        final now = DateTime.now().millisecondsSinceEpoch;
        final cooldownPeriod = 2 * 60 * 60 * 1000; // 2 heures en millisecondes
        
        if (now - lastChangeNotif < cooldownPeriod) {
          print('Cooldown actif - pas de notification de changement');
          return;
        }
        
        // Détecter changement de condition météo
        if (oldCondition != newCondition) {
          final description = newWeatherData['weather'][0]['description'];
          await NotificationService.showWeatherAlert(
            title: 'Changement météo détecté',
            body: 'Le temps change: $description (${newTemp}°C)',
            weatherType: newCondition.toLowerCase(),
          );
          await prefs.setInt('last_change_notification', now);
          print('Notification envoyée: changement de condition météo');
        }
        
        // Détecter changement significatif de température (>5°C)
        else if ((newTemp - oldTemp).abs() >= 5) {
          final change = newTemp > oldTemp ? 'augmente' : 'baisse';
          await NotificationService.showWeatherAlert(
            title: 'Température en changement',
            body: 'La température $change: ${oldTemp}°C → ${newTemp}°C',
            weatherType: newCondition.toLowerCase(),
          );
          await prefs.setInt('last_change_notification', now);
          print('Notification envoyée: changement de température');
        }
      }
    } catch (e) {
      print('Erreur lors de la vérification des changements: $e');
    }
  }

  static Future<void> _checkHourlyForecast(double lat, double lon) async {
    try {
      final url =
          'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$_weatherApiKey&units=metric&lang=fr&cnt=8';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final forecastData = json.decode(response.body);
        final hourlyList = forecastData['list'];
        
        // Vérifier les 3 prochaines heures
        for (int i = 0; i < 3 && i < hourlyList.length; i++) {
          final hourData = hourlyList[i];
          final dateTime = DateTime.fromMillisecondsSinceEpoch(
            hourData['dt'] * 1000,
          );
          final hour = DateFormat('HH:mm').format(dateTime);
          final condition = hourData['weather'][0]['main'];
          final temp = hourData['main']['temp'].round();
          final description = hourData['weather'][0]['description'];
          
          // Envoyer notification pour conditions importantes
          if (condition == 'Rain' || condition == 'Thunderstorm' || condition == 'Snow') {
            final prefs = await SharedPreferences.getInstance();
            final notifiedKey = 'hourly_notified_${dateTime.hour}_${dateTime.day}';
            
            final alreadyNotified = prefs.getBool(notifiedKey) ?? false;
            
            if (!alreadyNotified) {
              await NotificationService.showWeatherAlert(
                title: 'Prévision $hour',
                body: '$description prévue (${temp}°C)',
                weatherType: condition.toLowerCase(),
              );
              await prefs.setBool(notifiedKey, true);
              print('Notification prévision envoyée pour $hour');
              
              // Nettoyer les anciennes notifications (garder seulement les 24 dernières heures)
              final now = DateTime.now();
              for (int j = 24; j < 72; j++) {
                final oldDateTime = now.subtract(Duration(hours: j));
                final oldKey = 'hourly_notified_${oldDateTime.hour}_${oldDateTime.day}';
                await prefs.remove(oldKey);
              }
            }
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la vérification des prévisions horaires: $e');
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
        String? alertType;

        // Alertes de température
        if (temp >= 35) {
          alertTitle = 'Alerte Canicule';
          alertBody =
              'Température élevée: ${temp.round()}°C. Hydratez-vous et évitez l\'exposition au soleil.';
          alertType = 'heat_wave';
        } else if (temp <= 5) {
          alertTitle = 'Alerte Froid';
          alertBody =
              'Température très basse: ${temp.round()}°C. Couvrez-vous bien!';
          alertType = 'cold_wave';
        }

        // Alertes météorologiques (priorité plus haute)
        if (weatherMain.contains('thunder')) {
          alertTitle = 'Alerte Orage';
          alertBody =
              'Orages détectés dans votre région. Restez en sécurité à l\'intérieur.';
          alertType = 'thunderstorm';
        } else if (weatherMain.contains('rain') && windSpeed > 50) {
          alertTitle = 'Alerte Tempete';
          alertBody =
              'Fortes pluies et vents violents: ${windSpeed.round()} km/h. Évitez les déplacements.';
          alertType = 'storm';
        } else if (windSpeed > 70) {
          alertTitle = 'Alerte Vent Fort';
          alertBody =
              'Vents très violents: ${windSpeed.round()} km/h. Attention aux chutes d\'objets.';
          alertType = 'wind';
        }

        // Envoyer la notification d'alerte avec système anti-doublon
        if (alertTitle != null && alertBody != null && alertType != null) {
          final lastAlertKey = 'last_alert_$alertType';
          final lastAlertTime = prefs.getInt(lastAlertKey) ?? 0;
          final now = DateTime.now().millisecondsSinceEpoch;
          
          // Ne notifier que si la dernière alerte de ce type date de plus de 6 heures
          if (now - lastAlertTime > 6 * 60 * 60 * 1000) {
            await NotificationService.showWeatherAlert(
              title: alertTitle,
              body: alertBody,
              weatherType: weatherMain,
            );
            await prefs.setInt(lastAlertKey, now);
            print('Alerte envoyée: $alertType');
          } else {
            print('Alerte $alertType déjà envoyée récemment, ignorée');
          }
        }

        // Notification météo quotidienne (8h du matin uniquement)
        final now = DateTime.now();
        final lastDailyNotif = prefs.getString('last_daily_notification');
        final today = DateFormat('yyyy-MM-dd').format(now);
        
        if (now.hour == 8 && now.minute < 30 && lastDailyNotif != today) {
          await NotificationService.showDailyWeatherNotification(weatherData);
          await prefs.setString('last_daily_notification', today);
          print('Notification quotidienne envoyée');
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
