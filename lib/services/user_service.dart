import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static String? _userName;
  static const String _userNameKey = 'user_name';
  static const String _firstLaunchKey = 'first_launch';

  /// Initialiser le service utilisateur
  static Future<void> initialize() async {
    await _loadUserName();
  }

  /// Charger le nom d'utilisateur depuis le stockage
  static Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString(_userNameKey);
  }

  /// Sauvegarder le nom d'utilisateur
  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name.trim());
    _userName = name.trim();
  }

  /// Obtenir le nom d'utilisateur
  static String? getUserName() {
    return _userName;
  }

  /// Vérifier si l'utilisateur a un nom enregistré
  static bool hasUserName() {
    return _userName != null && _userName!.isNotEmpty;
  }

  /// Vérifier si c'est le premier lancement
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstLaunchKey) ?? true;
  }

  /// Marquer que l'application a été lancée
  static Future<void> markFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, false);
  }

  /// Obtenir un message personnalisé de salutation
  static String getGreeting() {
    final hour = DateTime.now().hour;
    final name = getUserName();
    final greeting = name != null ? name : "ami";

    if (hour < 12) {
      return "Bonjour $greeting ! ☀️";
    } else if (hour < 17) {
      return "Bon après-midi $greeting ! 🌤️";
    } else if (hour < 21) {
      return "Bonsoir $greeting ! 🌅";
    } else {
      return "Bonne soirée $greeting ! 🌙";
    }
  }

  /// Obtenir un message personnalisé pour les notifications
  static String getPersonalizedMessage(String baseMessage) {
    final name = getUserName();
    if (name != null) {
      return "$name, $baseMessage";
    }
    return baseMessage;
  }

  /// Obtenir des messages d'encouragement personnalisés
  static List<String> getEncouragementMessages() {
    final name = getUserName() ?? "ami";
    return [
      "$name, vous gérez parfaitement votre temps d'écran ! 🌟",
      "Bravo $name ! Votre discipline est exemplaire ! ✨",
      "$name, continuez sur cette belle lancée ! 👏",
      "Félicitations $name ! Vous prenez soin de votre bien-être ! 💪",
      "$name, votre équilibre numérique est inspirant ! 🎯",
    ];
  }

  /// Obtenir des messages d'alerte personnalisés
  static List<String> getAlertMessages() {
    final name = getUserName() ?? "ami";
    return [
      "$name, il est temps de faire une pause ! ⏰",
      "$name, vos yeux ont besoin de repos ! 👀",
      "$name, que diriez-vous d'un peu d'air frais ? 🌿",
      "$name, une petite pause vous ferait du bien ! 🧘",
      "$name, prenez soin de vous ! 💚",
    ];
  }

  /// Supprimer les données utilisateur (pour réinitialisation)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userNameKey);
    await prefs.setBool(_firstLaunchKey, true);
    _userName = null;
  }
}
