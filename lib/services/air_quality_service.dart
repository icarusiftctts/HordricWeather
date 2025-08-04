import 'dart:convert';
import 'package:http/http.dart' as http;

class AirQualityService {
  static const String _apiKey = '46ad115e8b5bb2d45b72d8d29b90b3b4';

  static Future<Map<String, dynamic>?> getAirQuality(
    double lat,
    double lon,
  ) async {
    try {
      final url =
          'http://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$_apiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseAirQualityData(data);
      }
    } catch (e) {
      print('Erreur lors de la récupération de la qualité de l\'air: $e');
    }
    return null;
  }

  static Map<String, dynamic> _parseAirQualityData(Map<String, dynamic> data) {
    final components = data['list'][0]['components'];
    final aqi = data['list'][0]['main']['aqi'];

    // Calcul de l'indice de qualité de l'air personnalisé
    String qualityLevel = _getQualityLevel(aqi);
    String recommendation = _getRecommendation(aqi);
    String healthAdvice = _getHealthAdvice(aqi);

    return {
      'aqi': aqi,
      'qualityLevel': qualityLevel,
      'recommendation': recommendation,
      'healthAdvice': healthAdvice,
      'components': {
        'co': components['co'], // Monoxyde de carbone
        'no2': components['no2'], // Dioxyde d'azote
        'o3': components['o3'], // Ozone
        'pm2_5': components['pm2_5'], // Particules fines
        'pm10': components['pm10'], // Particules
        'so2': components['so2'], // Dioxyde de soufre
      },
      'emoji': _getQualityEmoji(aqi),
      'color': _getQualityColor(aqi),
    };
  }

  static String _getQualityLevel(int aqi) {
    switch (aqi) {
      case 1:
        return 'Très bon';
      case 2:
        return 'Bon';
      case 3:
        return 'Moyen';
      case 4:
        return 'Mauvais';
      case 5:
        return 'Très mauvais';
      default:
        return 'Inconnu';
    }
  }

  static String _getQualityEmoji(int aqi) {
    switch (aqi) {
      case 1:
        return '🟢';
      case 2:
        return '🟡';
      case 3:
        return '🟠';
      case 4:
        return '🔴';
      case 5:
        return '🟣';
      default:
        return '⚪';
    }
  }

  static String _getQualityColor(int aqi) {
    switch (aqi) {
      case 1:
        return '#00E400';
      case 2:
        return '#FFFF00';
      case 3:
        return '#FF7E00';
      case 4:
        return '#FF0000';
      case 5:
        return '#8F3F97';
      default:
        return '#CCCCCC';
    }
  }

  static String _getRecommendation(int aqi) {
    switch (aqi) {
      case 1:
        return 'Idéal pour toutes les activités extérieures !';
      case 2:
        return 'Parfait pour le sport et les promenades.';
      case 3:
        return 'Activités modérées recommandées.';
      case 4:
        return 'Limitez les activités extérieures intenses.';
      case 5:
        return 'Évitez les activités extérieures.';
      default:
        return 'Données non disponibles.';
    }
  }

  static String _getHealthAdvice(int aqi) {
    switch (aqi) {
      case 1:
        return 'Aucune précaution particulière nécessaire.';
      case 2:
        return 'Personnes sensibles: restez attentives.';
      case 3:
        return 'Personnes sensibles: réduisez les efforts prolongés.';
      case 4:
        return 'Personnes sensibles: évitez les efforts extérieurs.';
      case 5:
        return 'Tous: évitez les activités extérieures.';
      default:
        return 'Consultez les autorités locales.';
    }
  }

  static List<Map<String, String>> getDetailedComponents(
    Map<String, dynamic> components,
  ) {
    return [
      {
        'name': 'PM2.5',
        'value': '${components['pm2_5']} μg/m³',
        'description': 'Particules fines',
        'impact': 'Pénètrent profondément dans les poumons',
      },
      {
        'name': 'PM10',
        'value': '${components['pm10']} μg/m³',
        'description': 'Particules en suspension',
        'impact': 'Irritation des voies respiratoires',
      },
      {
        'name': 'O₃',
        'value': '${components['o3']} μg/m³',
        'description': 'Ozone',
        'impact': 'Irritation des yeux et des voies respiratoires',
      },
      {
        'name': 'NO₂',
        'value': '${components['no2']} μg/m³',
        'description': 'Dioxyde d\'azote',
        'impact': 'Inflammation des voies respiratoires',
      },
      {
        'name': 'SO₂',
        'value': '${components['so2']} μg/m³',
        'description': 'Dioxyde de soufre',
        'impact': 'Irritation des muqueuses',
      },
      {
        'name': 'CO',
        'value': '${components['co']} μg/m³',
        'description': 'Monoxyde de carbone',
        'impact': 'Réduction du transport d\'oxygène',
      },
    ];
  }
}
