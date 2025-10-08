import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/notification_service.dart';
import 'services/background_service.dart';
import 'services/weather_widget_service.dart';
import 'services/daily_advice_service.dart';
import 'services/user_service.dart';
import 'ul/app_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser les locales pour les dates
  await initializeDateFormatting('fr_FR', null);

  // Initialiser les notifications
  await NotificationService.initialize();

  // Initialiser le service utilisateur
  await UserService.initialize();

  // Initialiser les services en arrière-plan
  await BackgroundWeatherService.initialize();

  // Initialiser le widget
  await WeatherWidgetService.initializeWidget();

  // Initialiser le service de conseils quotidiens
  await DailyAdviceService.initialize();

  // Démarrer l'affichage météo sur l'écran de verrouillage
  BackgroundWeatherService.startLockScreenNotifications();

  // Configuration de la barre de statut
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HordricWeather',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff90B2F9)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const AppInitializer(),
      debugShowCheckedModeBanner: false,
    );
  }
}
