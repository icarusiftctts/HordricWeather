import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ClothingAdviceService {
  static const String _clothingKey = 'clothing_advice';

  static Map<String, String> getClothingAdvice(
    double temperature,
    String weatherCondition,
    double windSpeed,
  ) {
    String outfit = '';
    String emoji = '';
    String tip = '';

    // Conseils basés sur la température
    if (temperature >= 30) {
      outfit = 'Vêtements légers, shorts, t-shirt, sandales';
      emoji = 'summer';
      tip = 'N\'oubliez pas la crème solaire et un chapeau !';
    } else if (temperature >= 25) {
      outfit = 'Vêtements d\'été, robe légère ou t-shirt et pantalon';
      emoji = 'tshirt';
      tip = 'Parfait pour une promenade ou une terrasse !';
    } else if (temperature >= 20) {
      outfit = 'Vêtements mi-saison, chemise ou pull léger';
      emoji = 'shirt';
      tip = 'Idéal pour le travail ou une sortie en ville.';
    } else if (temperature >= 15) {
      outfit = 'Pull ou veste légère, pantalon long';
      emoji = 'jacket';
      tip = 'Une veste au cas où la température baisse.';
    } else if (temperature >= 10) {
      outfit = 'Veste chaude, écharpe recommandée';
      emoji = 'scarf';
      tip = 'Pensez aux couches pour vous adapter facilement.';
    } else if (temperature >= 5) {
      outfit = 'Manteau, gants, bonnet';
      emoji = 'gloves';
      tip = 'Couvrez les extrémités pour éviter le froid.';
    } else {
      outfit = 'Manteau d\'hiver, gants épais, bonnet chaud';
      emoji = 'winter';
      tip = 'Habillez-vous chaudement, évitez les sorties prolongées.';
    }

    // Ajustements selon les conditions météo
    if (weatherCondition.contains('rain') ||
        weatherCondition.contains('drizzle')) {
      outfit += ' + Imperméable ou parapluie';
      tip += ' Il va pleuvoir, restez au sec !';
    } else if (weatherCondition.contains('snow')) {
      outfit += ' + Bottes imperméables, gants épais';
      tip += ' Attention aux surfaces glissantes !';
    } else if (weatherCondition.contains('wind') || windSpeed > 25) {
      outfit += ' + Veste coupe-vent';
      tip += ' Vent fort prévu, fixez bien vos affaires !';
    } else if (weatherCondition.contains('clear') && temperature > 25) {
      outfit += ' + Lunettes de soleil';
      tip += ' Beau temps, profitez-en !';
    }

    return {
      'outfit': outfit,
      'emoji': emoji,
      'tip': tip,
      'category': _getOutfitCategory(temperature),
    };
  }

  static String _getOutfitCategory(double temperature) {
    if (temperature >= 25) return 'été';
    if (temperature >= 15) return 'mi-saison';
    if (temperature >= 5) return 'automne';
    return 'hiver';
  }

  static Future<void> saveClothingPreference(
    String category,
    String preference,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final clothingData = prefs.getString(_clothingKey);
    Map<String, dynamic> preferences = {};

    if (clothingData != null) {
      preferences = json.decode(clothingData);
    }

    preferences[category] = preference;
    await prefs.setString(_clothingKey, json.encode(preferences));
  }

  static Future<String?> getClothingPreference(String category) async {
    final prefs = await SharedPreferences.getInstance();
    final clothingData = prefs.getString(_clothingKey);

    if (clothingData != null) {
      final preferences = json.decode(clothingData);
      return preferences[category];
    }

    return null;
  }

  static List<Map<String, String>> getActivitySuggestions(
    double temperature,
    String weatherCondition,
  ) {
    List<Map<String, String>> activities = [];

    if (weatherCondition.contains('clear') && temperature > 20) {
      activities.addAll([
        {
          'activity': 'Pique-nique',
          'emoji': 'picnic',
          'location': 'Parc ou jardin',
        },
        {'activity': 'Promenade', 'emoji': 'walk', 'location': 'Centre-ville'},
        {
          'activity': 'Sport extérieur',
          'emoji': 'sport',
          'location': 'Stade ou parc',
        },
      ]);
    } else if (weatherCondition.contains('rain')) {
      activities.addAll([
        {'activity': 'Cinéma', 'emoji': 'cinema', 'location': 'Centre commercial'},
        {'activity': 'Musée', 'emoji': 'museum', 'location': 'Centre culturel'},
        {
          'activity': 'Lecture',
          'emoji': 'book',
          'location': 'Café ou bibliothèque',
        },
      ]);
    } else if (temperature < 10) {
      activities.addAll([
        {
          'activity': 'Shopping',
          'emoji': 'shop',
          'location': 'Centre commercial',
        },
        {
          'activity': 'Spa/détente',
          'emoji': 'relax',
          'location': 'Centre de bien-être',
        },
        {'activity': 'Cuisine', 'emoji': 'cooking', 'location': 'À la maison'},
      ]);
    } else {
      activities.addAll([
        {
          'activity': 'Visite culturelle',
          'emoji': 'culture',
          'location': 'Monuments locaux',
        },
        {
          'activity': 'Café entre amis',
          'emoji': 'coffee',
          'location': 'Café du quartier',
        },
        {
          'activity': 'Marché local',
          'emoji': 'market',
          'location': 'Marché de la ville',
        },
      ]);
    }

    return activities;
  }
}
