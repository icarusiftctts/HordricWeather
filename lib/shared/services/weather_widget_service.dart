import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WeatherWidgetService {
  static const String _weatherApiKey = '46ad115e8b5bb2d45b72d8d29b90b3b4';

  static Future<void> initializeWidget() async {
    try {
      await HomeWidget.setAppGroupId('HordricWeather');
      await updateWidget();
    } catch (e) {
      print('Erreur lors de l\'initialisation du widget: $e');
    }
  }

  static Future<void> updateWidget() async {
    try {
      print('Debut mise a jour widget...');
      final prefs = await SharedPreferences.getInstance();

      // Recuperer la derniere position connue ou utiliser Lome par defaut
      final double lat = prefs.getDouble('last_latitude') ?? 6.1375;
      final double lon = prefs.getDouble('last_longitude') ?? 1.2123;
      final String location = prefs.getString('last_location') ?? 'Lome, Togo';

      print('Position widget: $lat, $lon - $location');

      // Recuperer les donnees meteo actuelles
      final weatherData = await _fetchCurrentWeather(lat, lon);

      if (weatherData != null) {
        print('Donnees meteo recuperees pour le widget');
        
        // Mettre a jour les donnees du widget avec gestion d'erreur
        try {
          await HomeWidget.saveWidgetData<String>('widget_location', location);
          await HomeWidget.saveWidgetData<String>(
              'widget_temperature', '${weatherData['main']['temp'].round()}C');
          await HomeWidget.saveWidgetData<String>(
              'widget_description', weatherData['weather'][0]['description']);
          await HomeWidget.saveWidgetData<String>(
              'widget_humidity', '${weatherData['main']['humidity']}%');
          await HomeWidget.saveWidgetData<String>('widget_wind',
              '${(weatherData['wind']['speed'] * 3.6).round()} km/h');
          await HomeWidget.saveWidgetData<String>(
              'widget_icon', weatherData['weather'][0]['icon']);

          print('Donnees sauvegardees, mise a jour du widget...');
          
          // Mettre a jour le widget avec timeout
          await HomeWidget.updateWidget(
            name: 'HomeWidgetProvider',
            androidName: 'HomeWidgetProvider',
          ).timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print('Timeout lors de la mise a jour du widget');
              return Future.value(false);
            },
          );

          print('Widget mis a jour avec succes');
        } catch (widgetError) {
          print('Erreur lors de la sauvegarde des donnees du widget: $widgetError');
        }
      } else {
        print('Impossible de recuperer les donnees meteo pour le widget');
      }
    } catch (e) {
      print('Erreur lors de la mise a jour du widget: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  static Future<Map<String, dynamic>?> _fetchCurrentWeather(
      double lat, double lon) async {
    try {
      final url =
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_weatherApiKey&units=metric&lang=fr';
      
      print('Appel API meteo pour widget: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout lors de l\'appel API meteo pour le widget');
        },
      );

      print('Reponse API widget: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Donnees meteo decodees avec succes');
        return data;
      } else {
        print('Erreur API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de la recuperation des donnees meteo pour le widget: $e');
    }
    return null;
  }

  static Future<void> saveLastWeatherData(Map<String, dynamic> weatherData,
      String location, double lat, double lon) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_location', location);
      await prefs.setDouble('last_latitude', lat);
      await prefs.setDouble('last_longitude', lon);
      await prefs.setString('last_weather_data', json.encode(weatherData));
      await prefs.setInt('last_update', DateTime.now().millisecondsSinceEpoch);

      // Mettre à jour le widget avec les nouvelles données
      await updateWidget();
    } catch (e) {
      print('Erreur lors de la sauvegarde des données météo: $e');
    }
  }

  static Future<void> onWidgetClicked() async {
    try {
      // Action à effectuer quand on clique sur le widget
      await updateWidget();
    } catch (e) {
      print('Erreur lors du clic sur le widget: $e');
    }
  }
}
