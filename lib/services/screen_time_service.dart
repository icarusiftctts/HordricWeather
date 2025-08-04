import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'notification_service.dart';
import 'user_service.dart';

class ScreenTimeService {
  static Timer? _timer;
  static Timer? _hourlyTimer;
  static Map<String, int> _appUsageToday = {};
  static DateTime? _sessionStartTime;
  static String? _currentApp;
  static bool _isTracking = false;

  // Seuils configurables
  static const int DISTRACTION_THRESHOLD_MINUTES = 30;
  static const int DAILY_LIMIT_HOURS = 8;

  static Future<void> initialize() async {
    try {
      await _loadTodayUsage();
      _startHourlyNotifications();
      print('Service de suivi du temps d\'écran initialisé');
    } catch (e) {
      print('Erreur lors de l\'initialisation du suivi: $e');
    }
  }

  static Future<void> startAppSession(String appName) async {
    if (_isTracking && _currentApp == appName) return;

    // Terminer la session précédente
    if (_isTracking) {
      await stopCurrentSession();
    }

    _currentApp = appName;
    _sessionStartTime = DateTime.now();
    _isTracking = true;

    // Démarrer le timer de distraction
    _startDistractionTimer();

    print('Session démarrée pour: $appName');
  }

  static Future<void> stopCurrentSession() async {
    if (!_isTracking || _sessionStartTime == null || _currentApp == null)
      return;

    final sessionDuration =
        DateTime.now().difference(_sessionStartTime!).inMinutes;

    // Enregistrer la durée
    _appUsageToday[_currentApp!] =
        (_appUsageToday[_currentApp!] ?? 0) + sessionDuration;

    // Sauvegarder
    await _saveTodayUsage();

    print('Session terminée pour $_currentApp: ${sessionDuration}min');

    _isTracking = false;
    _currentApp = null;
    _sessionStartTime = null;
    _timer?.cancel();
  }

  static void _startDistractionTimer() {
    _timer?.cancel();
    _timer = Timer(Duration(minutes: DISTRACTION_THRESHOLD_MINUTES), () {
      _sendDistractionAlert();
    });
  }

  static void _startHourlyNotifications() {
    _hourlyTimer?.cancel();
    _hourlyTimer = Timer.periodic(Duration(hours: 1), (timer) {
      _sendHourlyReport();
    });
  }

  static Future<void> _sendDistractionAlert() async {
    if (_currentApp == null) return;

    final currentUsage = _appUsageToday[_currentApp] ?? 0;
    final sessionTime = _sessionStartTime != null
        ? DateTime.now().difference(_sessionStartTime!).inMinutes
        : 0;

    final userName = UserService.getUserName();

    // Titre personnalisé
    String personalizedTitle = userName != null && userName.isNotEmpty
        ? 'Pause Recommandée - $userName'
        : 'Pause Recommandée';

    // Message personnalisé
    String personalizedBody = userName != null && userName.isNotEmpty
        ? '$userName, vous utilisez $_currentApp depuis ${sessionTime}min. Temps total aujourd\'hui: ${currentUsage + sessionTime}min.\n\nIl est temps de prendre une pause ! 😊'
        : 'Vous utilisez $_currentApp depuis ${sessionTime}min. Temps total aujourd\'hui: ${currentUsage + sessionTime}min.\n\nIl est temps de prendre une pause !';

    await NotificationService.showScreenTimeAlert(
      title: '⏰ $personalizedTitle',
      body: personalizedBody,
      appName: _currentApp!,
    );
  }

  static Future<void> _sendHourlyReport() async {
    final totalMinutes = getTotalScreenTimeToday();
    final topApps = getTopAppsToday(3);
    final advice = _getPersonalizedAdvice(totalMinutes, topApps);
    final userName = UserService.getUserName();

    // Créer un titre personnalisé
    String personalizedTitle = userName != null && userName.isNotEmpty
        ? 'Rapport Bien-être - $userName'
        : 'Rapport Bien-être';

    // Créer un message personnalisé
    String personalizedGreeting = userName != null && userName.isNotEmpty
        ? '$userName, voici votre bilan'
        : 'Voici votre bilan';

    String report =
        '$personalizedGreeting :\n\nTemps d\'écran: ${(totalMinutes / 60).toStringAsFixed(1)}h aujourd\'hui\n\n$advice';

    if (topApps.isNotEmpty) {
      report += '\n\nApplications les plus utilisées:\n';
      for (var app in topApps) {
        final hours = (app['minutes'] as int) / 60;
        if (hours >= 1) {
          report += '• ${app['name']}: ${hours.toStringAsFixed(1)}h\n';
        } else {
          report += '• ${app['name']}: ${app['minutes']}min\n';
        }
      }
    }

    // Ajouter un message d'encouragement personnalisé
    if (userName != null && userName.isNotEmpty) {
      if (totalMinutes < 120) {
        report += '\n\nContinuez comme ça $userName ! 💪';
      } else if (totalMinutes < 240) {
        report += '\n\nVous pouvez y arriver $userName ! 🌟';
      } else {
        report += '\n\nPrenez soin de vous $userName ! 🤗';
      }
    }

    await NotificationService.showScreenTimeReport(
      title: '📊 $personalizedTitle',
      body: report,
      totalMinutes: totalMinutes,
    );
  }

  static String _getPersonalizedAdvice(
      int totalMinutes, List<Map<String, dynamic>> topApps) {
    final hours = totalMinutes / 60;
    final userName = UserService.getUserName();
    final personalPrefix =
        userName != null && userName.isNotEmpty ? '$userName, ' : '';

    // Conseils basés sur le temps total
    if (totalMinutes == 0) {
      return "${personalPrefix}excellente journée sans écran ! Continuez comme ça ! 🌟";
    } else if (totalMinutes < 60) {
      return "${personalPrefix}votre utilisation est très modérée aujourd'hui ! Vous prenez soin de votre bien-être numérique. ✨";
    } else if (totalMinutes < 120) {
      return "${personalPrefix}bonne gestion du temps d'écran ! Essayez de maintenir ce rythme. 👍";
    } else if (totalMinutes < 240) {
      return "${personalPrefix}votre temps d'écran est modéré. Pensez à faire des pauses régulières. ⚠️";
    } else if (totalMinutes < 360) {
      return "${personalPrefix}votre temps d'écran est élevé (${hours.toStringAsFixed(1)}h). Essayez de réduire progressivement. 🔶";
    } else if (totalMinutes < 480) {
      return "${personalPrefix}votre temps d'écran est très élevé ! Prenez des pauses et limitez les distractions. 🔴";
    } else {
      return "${personalPrefix}il est temps de déconnecter et de prendre soin de vous ! 🚨";
    }
  }

  static Future<void> _loadTodayUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final savedData = prefs.getString('screen_time_$today');

    if (savedData != null) {
      final Map<String, dynamic> data = json.decode(savedData);
      _appUsageToday = Map<String, int>.from(data);
    } else {
      _appUsageToday = {};
    }
  }

  static Future<void> _saveTodayUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString('screen_time_$today', json.encode(_appUsageToday));
  }

  static int getTotalScreenTimeToday() {
    return _appUsageToday.values.fold(0, (sum, minutes) => sum + minutes);
  }

  static List<Map<String, dynamic>> getTopAppsToday(int limit) {
    final sortedApps = _appUsageToday.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedApps
        .take(limit)
        .map((entry) => {
              'name': entry.key,
              'minutes': entry.value,
            })
        .toList();
  }

  static Map<String, String> getScreenTimeAdvice() {
    final totalMinutes = getTotalScreenTimeToday();
    final topApps = getTopAppsToday(3);
    final detailedAdvice = getDetailedAdvice(totalMinutes, topApps);

    // Format compatible avec l'interface existante
    return {
      'advice': detailedAdvice['mainAdvice']!,
      'emoji': detailedAdvice['statusIcon']!,
      'category': detailedAdvice['statusText']!,
      'totalHours': (totalMinutes / 60).toStringAsFixed(1),
      'totalMinutes': totalMinutes.toString(),
      'tips': detailedAdvice['tips']!,
    };
  }

  static List<Map<String, String>> getHealthyUsageTips() {
    return [
      {
        'title': '👀 Règle 20-20-20',
        'description':
            'Toutes les 20 minutes, regardez un objet à 20 pieds (6m) pendant 20 secondes.',
        'icon': '👀'
      },
      {
        'title': '🧘 Pauses régulières',
        'description': 'Prenez une pause de 5-10 minutes toutes les heures.',
        'icon': '⏰'
      },
      {
        'title': '🌙 Couvre-feu numérique',
        'description':
            'Évitez les écrans 1h avant le coucher pour un meilleur sommeil.',
        'icon': '🌙'
      },
      {
        'title': '🏃 Activité physique',
        'description': 'Alternez temps d\'écran et activités physiques.',
        'icon': '🏃'
      },
      {
        'title': '👨‍👩‍👧‍👦 Temps social',
        'description': 'Privilégiez les interactions en personne.',
        'icon': '👨‍👩‍👧‍👦'
      },
      {
        'title': '🎯 Objectifs quotidiens',
        'description': 'Fixez-vous une limite de temps d\'écran quotidienne.',
        'icon': '🎯'
      },
    ];
  }

  static Future<List<Map<String, dynamic>>> getWeeklyStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> weeklyStats = [];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateKey = date.toIso8601String().split('T')[0];
      final savedData = prefs.getString('screen_time_$dateKey');

      int totalMinutes = 0;
      if (savedData != null) {
        final Map<String, dynamic> data = json.decode(savedData);
        totalMinutes = Map<String, int>.from(data)
            .values
            .fold(0, (sum, minutes) => sum + minutes);
      }

      weeklyStats.add({
        'date': date,
        'dayName': _getDayName(date.weekday),
        'totalMinutes': totalMinutes,
        'totalHours': (totalMinutes / 60).toStringAsFixed(1),
      });
    }

    return weeklyStats;
  }

  static String _getDayName(int weekday) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[weekday - 1];
  }

  static Future<void> setDailyLimit(int hours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_limit_hours', hours);
  }

  static Future<int> getDailyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('daily_limit_hours') ?? DAILY_LIMIT_HOURS;
  }

  static Future<void> enableNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('screen_time_notifications', enabled);
  }

  static Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('screen_time_notifications') ?? true;
  }

  static Map<String, String> getDetailedAdvice(
      int totalMinutes, List<Map<String, dynamic>> topApps) {
    final hours = totalMinutes / 60;
    final userName = UserService.getUserName();
    final personalPrefix =
        userName != null && userName.isNotEmpty ? '$userName, ' : '';

    String statusIcon;
    String statusText;
    String mainAdvice;
    List<String> tips = [];

    if (totalMinutes == 0) {
      statusIcon = "🌟";
      statusText = "Journée parfaite !";
      mainAdvice =
          "${personalPrefix}vous avez réussi à passer une journée sans être distrait par les écrans. C'est exceptionnel dans notre monde connecté !";
      tips = [
        "Profitez de cette clarté mentale",
        "Maintenez cette habitude demain",
        "Partagez votre secret avec vos proches"
      ];
    } else if (totalMinutes < 60) {
      statusIcon = "✨";
      statusText = "Utilisation exemplaire";
      mainAdvice =
          "${personalPrefix}votre usage est très raisonnable. Vous montrez un excellent contrôle de soi.";
      tips = [
        "Continuez à privilégier les activités hors écran",
        "Vous êtes un modèle de bien-être numérique",
        "Gardez cette discipline demain aussi"
      ];
    } else if (totalMinutes < 120) {
      statusIcon = "👍";
      statusText = "Bonne gestion";
      mainAdvice =
          "${personalPrefix}votre temps d'écran est dans une fourchette saine. Félicitations pour cette maîtrise !";
      tips = [
        "Maintenez ce rythme équilibré",
        "Pensez à faire des pauses actives",
        "Votre cerveau vous remercie"
      ];
    } else if (totalMinutes < 240) {
      statusIcon = "⚠️";
      statusText = "Attention modérée";
      mainAdvice =
          "${personalPrefix}votre usage commence à être significatif. C'est le moment d'être vigilant.";
      tips = [
        "Programmez des pauses toutes les 30 minutes",
        "Éteignez les notifications non essentielles",
        "Essayez la règle 20-20-20 (regarder à 20m pendant 20s toutes les 20min)"
      ];
    } else if (totalMinutes < 360) {
      statusIcon = "🔶";
      statusText = "Zone orange";
      mainAdvice =
          "${personalPrefix}avec ${hours.toStringAsFixed(1)}h d'écran, vous entrez dans la zone de risque. Il est temps d'agir.";
      tips = [
        "Définissez des créneaux sans écran",
        "Utilisez un minuteur pour limiter les sessions",
        "Remplacez 30min d'écran par une activité physique"
      ];
    } else if (totalMinutes < 480) {
      statusIcon = "🔴";
      statusText = "Zone rouge";
      mainAdvice =
          "${personalPrefix}votre temps d'écran est préoccupant. Votre santé mentale et physique peut en souffrir.";
      tips = [
        "Mettez votre téléphone en mode avion pendant 2h",
        "Sortez prendre l'air sans appareil",
        "Contactez un proche pour une conversation réelle"
      ];
    } else {
      statusIcon = "🚨";
      statusText = "Alerte critique";
      mainAdvice =
          "${personalPrefix}usage excessif détecté ! Il est urgent de reprendre le contrôle pour votre bien-être.";
      tips = [
        "Éteignez immédiatement tous les écrans",
        "Pratiquez 10 minutes de respiration consciente",
        "Planifiez une journée complète de détox numérique"
      ];
    }

    // Analyse des applications les plus utilisées
    String appAnalysis = "";
    if (topApps.isNotEmpty) {
      final topApp = topApps.first;
      final appMinutes = topApp['minutes'] as int;
      final appName = topApp['name'] as String;

      if (appMinutes > 120) {
        appAnalysis =
            "\n\n📱 $appName monopolise ${(appMinutes / 60).toStringAsFixed(1)}h de votre temps. Considérez des alternatives plus productives.";
      } else if (appMinutes > 60) {
        appAnalysis =
            "\n\n📱 $appName prend ${(appMinutes / 60).toStringAsFixed(1)}h de votre journée. Essayez de limiter son usage.";
      }
    }

    return {
      'statusIcon': statusIcon,
      'statusText': statusText,
      'mainAdvice': mainAdvice + appAnalysis,
      'tips': tips.join('\n• '),
    };
  }

  static void dispose() {
    _timer?.cancel();
    _hourlyTimer?.cancel();
  }
}
