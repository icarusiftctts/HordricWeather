import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'user_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Initialiser les fuseaux horaires
    tz.initializeTimeZones();

    // Demander les permissions de notification
    await Permission.notification.request();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showWeatherAlert({
    required String title,
    required String body,
    required String weatherType,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'weather_alerts',
      'Alertes Météo',
      channelDescription: 'Notifications pour les alertes météorologiques',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  static Future<void> scheduleWeatherReminder({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'weather_reminders',
      'Rappels Météo',
      channelDescription: 'Rappels quotidiens de la météo',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    final tz.TZDateTime tzScheduledDate =
        tz.TZDateTime.from(scheduledDate, tz.local);

    await _notificationsPlugin.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      tzScheduledDate,
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> scheduleWeatherNotification(
    String cityName,
    String weatherDescription,
    int temperature,
  ) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'weather_updates',
      'Mises à jour Météo',
      channelDescription:
          'Notifications des conditions météorologiques actuelles',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Météo à $cityName',
      '$weatherDescription - $temperature°C',
      platformChannelSpecifics,
    );
  }

  // Vérifier les conditions météo et envoyer des alertes
  static void checkWeatherConditions(Map<String, dynamic> weatherData) {
    final String condition = weatherData['weather'][0]['main'].toLowerCase();
    final String description = weatherData['weather'][0]['description'];
    final double temp = weatherData['main']['temp'].toDouble();
    final String cityName = weatherData['name'];

    // Alertes pour conditions extrêmes
    if (condition.contains('thunderstorm')) {
      showWeatherAlert(
        title: '⚡ Alerte Orage - $cityName',
        body: 'Orages prévus: $description. Restez à l\'abri!',
        weatherType: 'thunderstorm',
      );
    } else if (condition.contains('rain') && description.contains('heavy')) {
      showWeatherAlert(
        title: '🌧️ Alerte Pluie Forte - $cityName',
        body: 'Fortes pluies prévues: $description. Prudence sur les routes!',
        weatherType: 'heavy_rain',
      );
    } else if (temp > 35) {
      showWeatherAlert(
        title: '🌡️ Alerte Chaleur - $cityName',
        body: 'Température élevée: ${temp.round()}°C. Hydratez-vous!',
        weatherType: 'heat_wave',
      );
    } else if (temp < 5) {
      showWeatherAlert(
        title: '❄️ Alerte Froid - $cityName',
        body: 'Température basse: ${temp.round()}°C. Couvrez-vous bien!',
        weatherType: 'cold_wave',
      );
    }
  }

  static Future<void> showDailyWeatherNotification(
      Map<String, dynamic> weatherData) async {
    try {
      final temp = weatherData['main']['temp'].round();
      final description = weatherData['weather'][0]['description'];
      final cityName = weatherData['name'] ?? 'Votre ville';
      final humidity = weatherData['main']['humidity'];
      final windSpeed = (weatherData['wind']['speed'] * 3.6).round();

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'daily_weather',
        'Météo Quotidienne',
        channelDescription: 'Notification quotidienne de la météo',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
        ongoing: false,
        autoCancel: true,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _notificationsPlugin.show(
        2,
        '🌤️ Météo du jour - $cityName',
        '$temp°C, $description • Humidité: $humidity% • Vent: $windSpeed km/h',
        platformChannelSpecifics,
      );
    } catch (e) {
      print('Erreur lors de l\'affichage de la notification quotidienne: $e');
    }
  }

  static Future<void> showLockScreenWeatherNotification(
      Map<String, dynamic> weatherData) async {
    try {
      final temp = weatherData['main']['temp'].round();
      final description = weatherData['weather'][0]['description'];
      final cityName = weatherData['name'] ?? 'Votre ville';
      final humidity = weatherData['main']['humidity'];
      final windSpeed = (weatherData['wind']['speed'] * 3.6).round();
      final feelsLike = weatherData['main']['feels_like'].round();

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'lockscreen_weather',
        'Météo Écran de Verrouillage',
        channelDescription: 'Affichage météo sur l\'écran de verrouillage',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        ongoing: true,
        autoCancel: false,
        showWhen: true,
        visibility: NotificationVisibility.public,
        fullScreenIntent: false,
        category: AndroidNotificationCategory.status,
        ticker: 'Météo mise à jour',
        enableLights: true,
        enableVibration: false,
        playSound: false,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: false,
        interruptionLevel: InterruptionLevel.passive,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      String detailedBody = '$description\n'
          'Ressenti: ${feelsLike}°C • Humidité: $humidity%\n'
          'Vent: ${windSpeed} km/h';

      await _notificationsPlugin.show(
        3,
        '🌤️ $temp°C - $cityName',
        detailedBody,
        platformChannelSpecifics,
      );
    } catch (e) {
      print('Erreur lors de l\'affichage sur l\'écran de verrouillage: $e');
    }
  }

  static Future<void> showScreenTimeAlert({
    required String title,
    required String body,
    required String appName,
  }) async {
    try {
      // Personnaliser le message avec le nom de l'utilisateur
      final personalizedTitle =
          UserService.getPersonalizedMessage(title.replaceFirst('⏰ ', ''));
      final personalizedBody = UserService.getPersonalizedMessage(body);

      final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'screen_time_alerts',
        'Alertes Temps d\'Écran',
        channelDescription: 'Alertes pour le suivi du temps d\'écran',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(''),
        enableLights: true,
        ledColor: const Color.fromARGB(255, 255, 0, 0),
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 250, 500]),
      );

      final platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _notificationsPlugin.show(
        4,
        '⏰ $personalizedTitle',
        personalizedBody,
        platformChannelSpecifics,
      );
    } catch (e) {
      print('Erreur lors de l\'affichage de l\'alerte temps d\'écran: $e');
    }
  }

  static Future<void> showScreenTimeReport({
    required String title,
    required String body,
    required int totalMinutes,
  }) async {
    try {
      // Personnaliser le message avec le nom de l'utilisateur
      final personalizedTitle =
          UserService.getPersonalizedMessage(title.replaceFirst('📊 ', ''));
      final personalizedBody = UserService.getPersonalizedMessage(body);

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'screen_time_reports',
        'Rapports Temps d\'Écran',
        channelDescription: 'Rapports horaires du temps d\'écran',
        importance: Importance.low,
        priority: Priority.low,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(''),
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _notificationsPlugin.show(
        5,
        '📊 $personalizedTitle',
        personalizedBody,
        platformChannelSpecifics,
      );
    } catch (e) {
      print('Erreur lors de l\'affichage du rapport temps d\'écran: $e');
    }
  }

  // Nouvelle méthode pour les conseils du matin basés sur la météo
  static Future<void> showMorningWeatherAdvice({
    required String weatherDescription,
    required double temperature,
    required int humidity,
    required double windSpeed,
  }) async {
    try {
      final userName = UserService.getUserName();
      final greeting = UserService.getGreeting();

      String advice = _generateWeatherAdvice(
          weatherDescription, temperature, humidity, windSpeed);
      String personalizedTitle = (userName != null && userName.isNotEmpty)
          ? '$greeting $userName ! 🌅'
          : 'Bonjour ! 🌅';

      String personalizedBody = (userName != null && userName.isNotEmpty)
          ? '$userName, voici vos conseils pour aujourd\'hui :\n\n$advice'
          : 'Voici vos conseils pour aujourd\'hui :\n\n$advice';

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'morning_advice',
        'Conseils du Matin',
        channelDescription: 'Conseils quotidiens basés sur la météo',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(''),
        enableLights: true,
        ledColor: Color.fromARGB(255, 255, 165, 0),
        enableVibration: true,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _notificationsPlugin.show(
        6,
        personalizedTitle,
        personalizedBody,
        platformChannelSpecifics,
      );
    } catch (e) {
      print('Erreur lors de l\'affichage du conseil du matin: $e');
    }
  }

  // Génère des conseils basés sur les conditions météorologiques
  static String _generateWeatherAdvice(String weatherDescription,
      double temperature, int humidity, double windSpeed) {
    List<String> advice = [];

    // Conseils basés sur la température
    if (temperature < 10) {
      advice.add(
          '🧥 Il fait froid aujourd\'hui (${temperature.round()}°C). Pensez à vous habiller chaudement !');
    } else if (temperature > 25) {
      advice.add(
          '☀️ Il fait chaud aujourd\'hui (${temperature.round()}°C). Restez hydraté et portez des vêtements légers !');
    } else {
      advice.add(
          '🌡️ Température agréable aujourd\'hui (${temperature.round()}°C). Parfait pour sortir !');
    }

    // Conseils basés sur les conditions météo
    if (weatherDescription.toLowerCase().contains('rain') ||
        weatherDescription.toLowerCase().contains('pluie')) {
      advice.add('🌧️ Il pleut aujourd\'hui. N\'oubliez pas votre parapluie !');
    } else if (weatherDescription.toLowerCase().contains('cloud') ||
        weatherDescription.toLowerCase().contains('nuage')) {
      advice.add('☁️ Temps nuageux. Une veste légère pourrait être utile.');
    } else if (weatherDescription.toLowerCase().contains('clear') ||
        weatherDescription.toLowerCase().contains('sun')) {
      advice.add('☀️ Beau temps ensoleillé ! Profitez-en pour sortir.');
    }

    // Conseils basés sur l\'humidité
    if (humidity > 80) {
      advice
          .add('💧 Humidité élevée (${humidity}%). L\'air peut sembler lourd.');
    }

    // Conseils basés sur le vent
    if (windSpeed > 10) {
      advice.add(
          '💨 Vent fort (${windSpeed.round()} km/h). Attention aux objets légers !');
    }

    // Conseil général pour la journée
    advice.add('💪 Passez une excellente journée et prenez soin de vous !');

    return advice.join('\n\n');
  }

  // Programme les notifications du matin à 8h chaque jour
  static Future<void> scheduleDailyMorningAdvice() async {
    try {
      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, 8, 0);

      // Si 8h est déjà passé aujourd'hui, programmer pour demain
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'morning_advice',
        'Conseils du Matin',
        channelDescription: 'Conseils quotidiens basés sur la météo',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(''),
        enableLights: true,
        ledColor: Color.fromARGB(255, 255, 165, 0),
        enableVibration: true,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _notificationsPlugin.zonedSchedule(
        7, // ID unique pour les notifications du matin
        '🌅 Conseil du Matin - HordricWeather',
        'Votre conseil météo personnalisé pour la journée vous attend !',
        tz.TZDateTime.from(scheduledDate, tz.local),
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        matchDateTimeComponents:
            DateTimeComponents.time, // Répéter chaque jour à la même heure
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      print(
          'Notifications du matin programmées pour ${scheduledDate.hour}:${scheduledDate.minute.toString().padLeft(2, '0')}');
    } catch (e) {
      print('Erreur lors de la programmation des notifications du matin: $e');
    }
  }

  // Annule les notifications du matin programmées
  static Future<void> cancelDailyMorningAdvice() async {
    try {
      await _notificationsPlugin.cancel(7);
      print('Notifications du matin annulées');
    } catch (e) {
      print('Erreur lors de l\'annulation des notifications du matin: $e');
    }
  }
}
