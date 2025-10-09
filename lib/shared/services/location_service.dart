import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/constants.dart';

class LocationService {
  /// Ouvre les paramètres de localisation de l'appareil
  static Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {
      print('Impossible d\'ouvrir les paramètres de localisation: $e');
    }
  }

  /// Ouvre les paramètres de l'application
  static Future<void> openAppSettings() async {
    try {
      await Geolocator.openAppSettings();
    } catch (e) {
      print('Impossible d\'ouvrir les paramètres de l\'application: $e');
    }
  }
  static Future<bool> checkLocationPermission() async {
    // Vérifier si le service de localisation est activé
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Service de localisation désactivé sur l\'appareil');
      return false;
    }

    // Vérifier les permissions
    LocationPermission permission = await Geolocator.checkPermission();
    print('Permission actuelle: $permission');
    
    if (permission == LocationPermission.denied) {
      print('Permission refusée, demande de permission...');
      permission = await Geolocator.requestPermission();
      print('Nouvelle permission après demande: $permission');
      
      if (permission == LocationPermission.denied) {
        print('Permission refusée définitivement par l\'utilisateur');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Permission refusée définitivement - rediriger vers les paramètres');
      return false;
    }

    if (permission == LocationPermission.whileInUse || 
        permission == LocationPermission.always) {
      print('Permission accordée: $permission');
      return true;
    }

    print('Permission non accordée: $permission');
    return false;
  }

  static Future<Position?> getCurrentPosition() async {
    bool hasPermission = await checkLocationPermission();
    if (!hasPermission) {
      print('Permissions de localisation refusées');
      return null;
    }

    try {
      // Vérifier si le service de localisation est activé
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Service de localisation désactivé');
        return null;
      }

      // Essayer d'abord avec une précision élevée et timeout plus long
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 30),
        );
        print('Position obtenue avec précision élevée: ${position.latitude}, ${position.longitude}');
        return position;
      } catch (timeoutError) {
        print('Timeout avec précision élevée, essai avec précision moyenne');
        
        // Si timeout, essayer avec précision moyenne
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 20),
        );
        print('Position obtenue avec précision moyenne: ${position.latitude}, ${position.longitude}');
        return position;
      }
    } catch (e) {
      print('Erreur lors de l\'obtention de la position: $e');
      
      // Essayer d'obtenir la dernière position connue en cas d'échec
      try {
        Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
        if (lastKnownPosition != null) {
          print('Utilisation de la dernière position connue: ${lastKnownPosition.latitude}, ${lastKnownPosition.longitude}');
          return lastKnownPosition;
        }
      } catch (lastPositionError) {
        print('Impossible d\'obtenir la dernière position connue: $lastPositionError');
      }
      
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
    print('Début de la récupération des données météo de localisation...');
    
    Position? position = await getCurrentPosition();
    if (position == null) {
      print('Impossible d\'obtenir la position');
      return null;
    }

    print('Position obtenue: ${position.latitude}, ${position.longitude}');

    try {
      final url = 'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=${Constants.apiKey}&units=metric&lang=fr';
      print('Appel API météo: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timeout lors de l\'appel à l\'API météo');
        },
      );

      print('Statut de réponse API météo: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Données météo récupérées avec succès');
        
        final cityName = await getCityNameFromCoordinates(
            position.latitude, position.longitude);

        final result = {
          'weather_data': data,
          'city_name': cityName ?? 'Position actuelle',
          'latitude': position.latitude,
          'longitude': position.longitude,
        };
        
        print('Données complètes préparées pour la ville: ${cityName ?? "Position actuelle"}');
        return result;
      } else {
        print('Erreur API météo: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de l\'obtention des données météo: $e');
    }
    return null;
  }
}
