# 🛠️ HordricWeather - Documentation Technique

## 📁 Architecture du Projet

### Structure des Services
```
lib/services/
├── weather_widget_service.dart    # Gestion du widget home screen
├── background_service.dart        # Services en arrière-plan
└── notification_service.dart      # Système de notifications
```

### Widgets UI Principaux
```
lib/ul/
├── welcome.dart                   # Page d'accueil moderne
├── detail_page.dart              # Page détaillée avec glassmorphism
├── settings_page.dart             # Configuration utilisateur
├── home.dart                      # Navigation principale
└── get_started.dart              # Introduction
```

### Modèles de Données
```
lib/models/
├── city.dart                     # 200+ villes mondiales avec drapeaux
└── constants.dart                # Constantes API et configuration
```

## 🔧 Configuration Android

### Permissions Requises (AndroidManifest.xml)
```xml
<!-- Localisation précise -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Localisation en arrière-plan -->
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

<!-- Réseau et connectivité -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- Notifications et alerts -->
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE" />

<!-- Widget et services -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

### Récepteurs et Services Configurés
```xml
<!-- Widget Provider -->
<receiver android:name=".HomeWidgetProvider" android:exported="false">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
    </intent-filter>
    <meta-data android:name="android.appwidget.provider"
               android:resource="@xml/home_widget_info" />
</receiver>

<!-- Récepteur de démarrage -->
<receiver android:name=".BootReceiver" android:exported="false">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED" />
    </intent-filter>
</receiver>

<!-- Service de travail en arrière-plan -->
<service android:name=".WorkManagerService" 
         android:permission="android.permission.BIND_JOB_SERVICE" 
         android:exported="false" />
```

## 📱 Widget Configuration

### Layout Principal (home_widget.xml)
- **LinearLayout vertical** avec fond glassmorphism
- **TextView température** : 24sp, bold, centré
- **TextView localisation** : 16sp, avec icône 📍
- **TextView description** : 14sp, italique
- **LinearLayout horizontal** : humidité + vent
- **Padding** : 16dp pour design équilibré

### Ressources Graphiques
```
android/app/src/main/res/
├── drawable/
│   ├── widget_background.xml      # Fond glassmorphism
│   └── widget_preview.xml         # Aperçu du widget
├── layout/
│   └── home_widget.xml            # Layout principal
└── xml/
    └── home_widget_info.xml       # Configuration widget
```

## 🔔 Système de Notifications

### Types Implémentés
1. **Daily Weather (ID: 1000)**
   - Heure : 8h00 quotidien
   - Contenu : Résumé météo complet
   - Canal : "daily_weather"

2. **Weather Alerts (ID: 2000-2999)**
   - Canicule : > 35°C (ID: 2001)
   - Froid extrême : < 5°C (ID: 2002)
   - Orages détectés (ID: 2003)
   - Tempêtes : pluie + vent (ID: 2004)
   - Vents violents : > 70 km/h (ID: 2005)

3. **Lock Screen (ID: 3000)**
   - Persistante avec température
   - Mise à jour continue
   - Actions rapides

### Configuration des Canaux
```dart
// Canal principal pour notifications quotidiennes
AndroidNotificationChannel(
  'daily_weather',
  'Météo Quotidienne',
  description: 'Notifications météo journalières',
  importance: Importance.defaultImportance,
)

// Canal pour alertes urgentes
AndroidNotificationChannel(
  'weather_alerts',
  'Alertes Météo',
  description: 'Alertes météorologiques importantes',
  importance: Importance.high,
)
```

## ⚙️ Services en Arrière-Plan

### WorkManager Configuration
```dart
// Tâche périodique toutes les 30 minutes
Workmanager().registerPeriodicTask(
  "weather_update",
  "weatherUpdateTask",
  frequency: Duration(minutes: 30),
  constraints: Constraints(
    networkType: NetworkType.connected,
    requiresBatteryNotLow: true,
  ),
);

// Tâche d'alerte horaire
Workmanager().registerPeriodicTask(
  "weather_alerts",
  "weatherAlertsTask",
  frequency: Duration(hours: 1),
);
```

### Monitoring des Conditions
- **Température extrême** : Surveillance continue
- **Conditions météo** : Analyse des codes OpenWeatherMap
- **Vitesse du vent** : Seuils configurables
- **Humidité** : Monitoring pour confort
- **Visibilité** : Alertes brouillard/pollution

## 🌍 Base de Données Villes

### Structure des Données
```dart
class City {
  final String name;           // Nom de la ville
  final String country;        // Code pays (FR, US, etc.)
  final String flag;          // Emoji drapeau
  final double latitude;       // Coordonnées GPS
  final double longitude;
  final bool isCurrentLocation; // Localisation actuelle
}
```

### Villes Intégrées (200+)
- **🌍 Europe** : Paris, London, Berlin, Rome, Madrid...
- **🌎 Amériques** : New York, Los Angeles, São Paulo, Buenos Aires...
- **🌏 Asie** : Tokyo, Beijing, Mumbai, Dubai, Singapore...
- **🌍 Afrique** : **Lomé**, Lagos, Cairo, Johannesburg, Casablanca...
- **🇦🇺 Océanie** : Sydney, Melbourne, Auckland...

### Recherche et Filtrage
```dart
// Recherche intelligente par nom ou pays
List<City> searchCities(String query) {
  return cities.where((city) => 
    city.name.toLowerCase().contains(query.toLowerCase()) ||
    city.country.toLowerCase().contains(query.toLowerCase())
  ).toList();
}
```

## 🎨 Design System

### Palette de Couleurs
```dart
// Glassmorphism
Color.fromRGBO(255, 255, 255, 0.15)  // Fond semi-transparent
Color.fromRGBO(255, 255, 255, 0.3)   // Bordures
Color.fromRGBO(0, 0, 0, 0.1)         // Ombres

// Accents météo
Colors.blue.shade300     // Ciel clair
Colors.grey.shade400     // Nuageux
Colors.orange.shade400   // Coucher de soleil
Colors.cyan.shade200     // Pluie
```

### Animations
```dart
// Utilisation de flutter_animate
.animate()
.fadeIn(duration: 600.ms)
.slideY(begin: 0.3, end: 0, curve: Curves.easeOutBack)
.shimmer(delay: 300.ms, duration: 1200.ms)
```

## 📊 Gestion des Données

### Persistance Locale
```dart
// SharedPreferences pour configuration
await prefs.setBool('notifications_enabled', value);
await prefs.setBool('daily_notifications', value);
await prefs.setBool('weather_alerts', value);
await prefs.setString('last_weather_data', jsonData);
```

### Cache Intelligent
- **Données météo** : Cache 30 minutes
- **Position utilisateur** : Cache 1 heure
- **Configuration** : Persistance permanente
- **Widget data** : Mise à jour automatique

## 🔍 API OpenWeatherMap

### Endpoints Utilisés
```dart
// Météo actuelle
'https://api.openweathermap.org/data/2.5/weather'

// Prévisions (si nécessaire)
'https://api.openweathermap.org/data/2.5/forecast'

// Paramètres standards
{
  'appid': API_KEY,
  'units': 'metric',
  'lang': 'fr'
}
```

### Gestion d'Erreurs
```dart
try {
  final response = await http.get(uri);
  if (response.statusCode == 200) {
    return WeatherData.fromJson(json.decode(response.body));
  }
} catch (e) {
  // Fallback vers dernières données mises en cache
  return getLastCachedWeatherData();
}
```

## 🚀 Déploiement et Tests

### Tests Recommandés
1. **Widget functionality** : Ajout/suppression/mise à jour
2. **Background services** : Persistance après redémarrage
3. **Notifications** : Tous types et canaux
4. **Géolocalisation** : Permissions et précision
5. **Cache/offline** : Fonctionnement sans réseau

### Build Release
```bash
# Nettoyage
flutter clean
flutter pub get

# Build APK
flutter build apk --release

# Build App Bundle (Google Play)
flutter build appbundle --release
```

### Optimisations
- **ProGuard** : Obfuscation du code
- **Bundle size** : Compression assets
- **Performance** : Lazy loading des villes
- **Battery** : Optimisation services arrière-plan

---

*Documentation technique HordricWeather v2.0 - Mise à jour : Janvier 2024* 🛠️
