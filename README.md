# HordricWeather

Application mobile météorologique élégante et intuitive développée avec Flutter.

## Description

HordricWeather est une application météo moderne qui vous accompagne au quotidien avec des prévisions précises, des alertes intelligentes, la qualité de l'air et un widget élégant. Entièrement gratuite, sans publicité et respectueuse de votre vie privée.

## Fonctionnalités

### Météo Complète
- Prévisions précises basées sur votre position GPS
- Température actuelle et ressentie
- Humidité, pression atmosphérique
- Vitesse et direction du vent
- Prévisions horaires et sur 5 jours
- Mise à jour automatique toutes les 30 minutes

### Alertes Intelligentes
- Notifications météo extrêmes (canicule, grand froid, orages, vents violents)
- Alertes changements brusques de température (>5°C)
- Prévisions horaires de pluie/neige/orages imminents
- Météo quotidienne à 8h00
- Système anti-spam avec cooldown (2h pour changements, 6h pour alertes)

### Qualité de l'Air
- Indice AQI en temps réel (échelle 1-5)
- Détails des polluants (PM2.5, PM10, NO2, O3, SO2, CO)
- Conseils santé personnalisés selon la qualité
- Mise à jour automatique

### Conseils Personnalisés
- Recommandations vestimentaires selon la météo
- Suggestions d'activités adaptées
- Conseils santé selon qualité de l'air

### Widget Android
- Widget météo sur écran d'accueil
- Design moderne et épuré
- Mise à jour automatique toutes les 30 minutes
- Affichage : température, humidité, vent, conditions

### Interface Moderne
- Design élégant avec gradients bleu/cyan
- Animations fluides (flutter_animate)
- Icônes météo animées
- Mode sombre intégré
- Navigation intuitive

### Gestion des Villes
- Ajoutez plusieurs villes en favoris
- Basculez rapidement entre vos localisations
- Prévisions pour toutes vos villes sauvegardées

### Paramètres Personnalisables
- Activez/désactivez les notifications
- Configurez les alertes selon vos besoins
- Gérez le widget et les mises à jour
- Réinitialisez vos données
- Accédez à la politique de confidentialité

### Vie Privée Respectée
- Aucune donnée envoyée à nos serveurs
- Stockage 100% local (SharedPreferences)
- Aucune publicité, aucun tracker
- Communications sécurisées (HTTPS)
- Conforme RGPD et CCPA
- Suppression des données à tout moment

## Structure du Projet

```
lib/
├── main.dart                           : Point d'entrée de l'application
├── ul/
│   ├── get_started.dart                : Écran de démarrage avec logo animé
│   ├── home.dart                       : Écran principal météo
│   ├── detail_page.dart                : Page de détails (prévisions horaires)
│   ├── welcome.dart                    : Écran de sélection des villes
│   ├── settings_page.dart              : Paramètres et notifications
│   ├── user_onboarding_page.dart       : Onboarding première utilisation
│   ├── privacy_policy_page.dart        : Page politique de confidentialité
│   └── widgets/
│       ├── weather_item.dart           : Widget élément météo
│       └── app_logo.dart               : Widget logo réutilisable
├── models/
│   └── constants.dart                  : Constantes de l'application
├── services/
│   ├── notification_service.dart       : Gestion des notifications
│   ├── background_service.dart         : Service arrière-plan (mises à jour)
│   ├── weather_widget_service.dart     : Service widget Android
│   ├── user_service.dart               : Service utilisateur
│   ├── air_quality_service.dart        : Service qualité de l'air
│   └── clothing_advice_service.dart    : Service conseils vestimentaires
└── pages/
    └── advice_page.dart                : Page conseils (météo + qualité air)

assets/
├── img.png                             : Logo principal de l'application
└── [autres icônes météo]               : Icônes pour conditions météo

android/
└── app/src/main/res/mipmap-*/         : Icônes launcher générées
```

## Prérequis

- Flutter 3.32.8 ou supérieur
- Dart 3.8.1 ou supérieur
- Android SDK 34 ou supérieur
- Compte OpenWeather API (gratuit) : [https://openweathermap.org/api](https://openweathermap.org/api)

## Installation

### 1. Cloner le Repository
```bash
git clone https://github.com/HordRicJr/HordricWeather.git
cd HordricWeather
```

### 2. Installer les Dépendances
```bash
flutter pub get
```

### 3. Configurer l'API OpenWeather
Le projet utilise déjà une clé API OpenWeather configurée. Si vous souhaitez utiliser votre propre clé :

1. Créez un compte sur [OpenWeather](https://openweathermap.org/api)
2. Obtenez votre clé API gratuite
3. Remplacez la clé dans `lib/services/background_service.dart` :
```dart
static const String _weatherApiKey = 'VOTRE_CLE_API';
```

### 4. Générer les Icônes Launcher
```bash
dart run flutter_launcher_icons
```

### 5. Lancer l'Application

#### Mode Debug
```bash
flutter run
```

#### Mode Release (APK)
```bash
flutter build apk --release
```

#### Mode Release (AAB pour Play Store)
```bash
flutter build appbundle --release
```

## Dépendances Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.2                          # Requêtes API
  intl: ^0.20.1                         # Internationalisation et dates
  flutter_local_notifications: ^17.2.3  # Notifications locales
  permission_handler: ^11.3.1           # Gestion des permissions
  geolocator: ^13.0.1                   # Géolocalisation
  flutter_animate: ^4.5.0               # Animations
  home_widget: ^0.6.0                   # Widget Android
  shared_preferences: ^2.3.2            # Stockage local
  url_launcher: ^6.3.1                  # Ouverture de liens
  flutter_launcher_icons: ^0.14.2       # Génération d'icônes
```

## API Utilisée

**OpenWeather API** : [https://openweathermap.org/](https://openweathermap.org/)

Endpoints utilisés :
- `/data/2.5/weather` : Météo actuelle
- `/data/2.5/forecast` : Prévisions horaires (5 jours)
- `/data/2.5/air_pollution` : Qualité de l'air

## Permissions Android

```xml
<!-- Permissions dans AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

## Architecture

### Services
- **NotificationService** : Gestion des notifications (alertes, quotidienne, lockscreen)
- **BackgroundService** : Mises à jour automatiques en arrière-plan (30 min)
- **WeatherWidgetService** : Mise à jour du widget Android
- **UserService** : Gestion des données utilisateur
- **AirQualityService** : Calcul et conseils qualité de l'air
- **ClothingAdviceService** : Recommandations vestimentaires

### Système de Notifications Intelligent
- **Cooldown 2h** : Changements météo et température >5°C
- **Cooldown 6h** : Alertes météo extrêmes (canicule, froid, orages, vents)
- **Anti-duplicate** : Prévisions horaires (stockage par heure)
- **Nettoyage automatique** : Suppression des anciens flags de notification

### Stockage Local (SharedPreferences)
- `background_weather_data` : Cache météo actuelle
- `last_weather_change_notification` : Timestamp dernière notification changement
- `last_alert_notification_{type}` : Timestamps alertes par type
- `hourly_notified_{HH:mm}` : Flags prévisions horaires notifiées
- `notifications_enabled` : État global des notifications
- `widget_enabled` : État du widget
- Villes favorites, nom utilisateur, préférences

## Documentation

- **POLITIQUE_CONFIDENTIALITE.md** : Politique complète (RGPD/CCPA)
- **privacy-policy.html** : Version web hébergeable sur GitHub Pages
- **GUIDE_POLITIQUE_CONFIDENTIALITE.md** : Guide d'implémentation
- **GUIDE_DEPLOIEMENT.md** : Instructions de compilation et installation
- **GUIDE_PLAYSTORE.md** : Guide de publication sur Google Play Store
- **RECAPITULATIF_POLITIQUE.md** : Résumé de la politique
- **RESUME_MODIFICATIONS.md** : Historique des modifications
- **CONFIGURATION_LOGO.md** : Configuration du logo

## Tests

### Lancer les Tests Unitaires
```bash
flutter test
```

### Analyse du Code
```bash
flutter analyze
```

### Nettoyage
```bash
flutter clean
``

## Captures d'Écran

*(À ajouter après compilation)*

## Auteur

**HordRicJr**
- GitHub : [https://github.com/HordRicJr](https://github.com/HordRicJr)
- Email : assounrodrigue5@gmail.com

## Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## Contributions

Les contributions sont les bienvenues ! N'hésitez pas à :
1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## Support

Pour toute question ou problème :
- Ouvrez une [issue](https://github.com/HordRicJr/HordricWeather/issues)
- Consultez la documentation dans le dossier du projet
- Email : assounrodrigue5@gmail.com

## Remerciements

- **OpenWeather** : Pour l'API météo gratuite
- **Flutter Team** : Pour le framework incroyable
- **Communauté Flutter** : Pour les packages open-source

## Changelog

### Version 1.0.0 (8 octobre 2025)
- Première version publique
- Météo complète avec prévisions horaires et 5 jours
- Système de notifications intelligent avec cooldowns
- Qualité de l'air et conseils santé
- Widget Android personnalisable
- Politique de confidentialité complète (RGPD/CCPA)
- Interface moderne avec animations
- Conseils vestimentaires et activités
- Gestion multi-villes
- Aucune publicité, respect de la vie privée

---

**HordricWeather** - Votre compagnon météo intelligent 🌤️

