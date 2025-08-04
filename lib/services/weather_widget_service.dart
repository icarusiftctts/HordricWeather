import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/constants.dart';

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
      final prefs = await SharedPreferences.getInstance();

      // Récupérer la dernière position connue ou utiliser Lomé par défaut
      final double lat = prefs.getDouble('last_latitude') ?? 6.1375;
      final double lon = prefs.getDouble('last_longitude') ?? 1.2123;
      final String location = prefs.getString('last_location') ?? 'Lomé, Togo';

      // Récupérer les données météo actuelles
      final weatherData = await _fetchCurrentWeather(lat, lon);

      if (weatherData != null) {
        // Mettre à jour les données du widget
        await HomeWidget.saveWidgetData<String>('widget_location', location);
        await HomeWidget.saveWidgetData<String>(
            'widget_temperature', '${weatherData['main']['temp'].round()}°C');
        await HomeWidget.saveWidgetData<String>(
            'widget_description', weatherData['weather'][0]['description']);
        await HomeWidget.saveWidgetData<String>(
            'widget_humidity', '${weatherData['main']['humidity']}%');
        await HomeWidget.saveWidgetData<String>('widget_wind',
            '${(weatherData['wind']['speed'] * 3.6).round()} km/h');
        await HomeWidget.saveWidgetData<String>(
            'widget_icon', weatherData['weather'][0]['icon']);

        // Mettre à jour le widget
        await HomeWidget.updateWidget(
          name: 'HomeWidgetProvider',
          androidName: 'HomeWidgetProvider',
        );

        print('Widget mis à jour avec succès');
      }
    } catch (e) {
      print('Erreur lors de la mise à jour du widget: $e');
    }
  }

  static Future<Map<String, dynamic>?> _fetchCurrentWeather(
      double lat, double lon) async {
    try {
      final url =
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_weatherApiKey&units=metric&lang=fr';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Erreur lors de la récupération des données météo: $e');
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
