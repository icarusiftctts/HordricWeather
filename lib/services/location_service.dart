import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/constants.dart';

class LocationService {
  static Future<bool> checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  static Future<Position?> getCurrentPosition() async {
    bool hasPermission = await checkLocationPermission();
    if (!hasPermission) return null;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      return position;
    } catch (e) {
      print('Erreur lors de l\'obtention de la position: $e');
      return null;
    }
  }

  static Future<String?> getCityNameFromCoordinates(
      double latitude, double longitude) async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://api.openweathermap.org/geo/1.0/reverse?lat=$latitude&lon=$longitude&limit=1&appid=${Constants.apiKey}',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final cityData = data[0];
          return cityData['name'] ?? 'Position actuelle';
        }
      }
    } catch (e) {
      print('Erreur lors de l\'obtention du nom de la ville: $e');
    }
    return 'Position actuelle';
  }

  static Future<Map<String, dynamic>?> getCurrentLocationWeather() async {
    Position? position = await getCurrentPosition();
    if (position == null) return null;

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=${Constants.apiKey}&units=metric&lang=fr',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final cityName = await getCityNameFromCoordinates(
            position.latitude, position.longitude);

        return {
          'weather_data': data,
          'city_name': cityName,
          'latitude': position.latitude,
          'longitude': position.longitude,
        };
      }
    } catch (e) {
      print('Erreur lors de l\'obtention des données météo: $e');
    }
    return null;
  }
}
