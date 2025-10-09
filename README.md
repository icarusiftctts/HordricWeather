# HordricWeather ☀️

![Hacktoberfest 2025](https://img.shields.io/badge/Hacktoberfest-2025-orange?style=for-the-badge&logo=digitalocean)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-3-orange.svg?style=for-the-badge)](#contributeurs-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.32.8-02569B?logo=flutter)
![Platform](https://img.shields.io/badge/platform-Android-brightgreen.svg)

[![Flutter Analyze](https://github.com/HordRicJr/HordricWeather/actions/workflows/flutter_analyze.yml/badge.svg)](https://github.com/HordRicJr/HordricWeather/actions/workflows/flutter_analyze.yml)
[![Flutter Test](https://github.com/HordRicJr/HordricWeather/actions/workflows/flutter_test.yml/badge.svg)](https://github.com/HordRicJr/HordricWeather/actions/workflows/flutter_test.yml)
[![Build APK](https://github.com/HordRicJr/HordricWeather/actions/workflows/build_apk.yml/badge.svg)](https://github.com/HordRicJr/HordricWeather/actions/workflows/build_apk.yml)
[![Code Quality](https://github.com/HordRicJr/HordricWeather/actions/workflows/code_quality.yml/badge.svg)](https://github.com/HordRicJr/HordricWeather/actions/workflows/code_quality.yml)
[![Dependabot](https://img.shields.io/badge/Dependabot-enabled-blue?logo=dependabot)](https://github.com/HordRicJr/HordricWeather/network/updates)

**Votre compagnon météo intelligent, gratuit et sans publicité !**

HordricWeather est une application météo moderne et élégante développée avec Flutter, qui vous accompagne au quotidien avec des prévisions précises, des alertes intelligentes, la qualité de l'air et un widget personnalisable. Entièrement gratuite, sans publicité et respectueuse de votre vie privée.

---

## 📱 Téléchargement

[![Get it on Google Play](https://img.shields.io/badge/Google%20Play-Bientôt%20disponible-brightgreen?logo=google-play)](https://play.google.com/store/apps)

---

## ✨ Aperçu

*(Captures d'écran à venir)*

---

## 🚀 Fonctionnalités

### 🌡️ Météo Complète et Précise
- Prévisions basées sur votre position GPS en temps réel
- Température actuelle et ressentie
- Humidité, pression atmosphérique
- Vitesse et direction du vent
- Prévisions horaires détaillées
- Prévisions sur 5 jours
- Mise à jour automatique toutes les 30 minutes

### 🔔 Alertes Intelligentes et Personnalisables
- Notifications météo extrêmes (canicule, grand froid, orages, vents violents)
- Alertes changements brusques de température (>5°C)
- Prévisions horaires de pluie/neige/orages imminents
- Météo quotidienne à 8h00
- Système anti-spam avec cooldown (2h pour changements, 6h pour alertes)

### 🌍 Qualité de l'Air en Temps Réel
- Indice AQI en temps réel (échelle 1-5)
- Détails des polluants (PM2.5, PM10, NO2, O3, SO2, CO)
- Conseils santé personnalisés selon la qualité
- Mise à jour automatique

### 💡 Conseils Personnalisés au Quotidien
- Recommandations vestimentaires selon la météo
- Suggestions d'activités adaptées
- Conseils santé selon qualité de l'air

### 📱 Widget Android Élégant
- Widget météo sur écran d'accueil
- Design moderne et épuré
- Mise à jour automatique toutes les 30 minutes
- Affichage : température, humidité, vent, conditions

### 🎨 Interface Moderne et Fluide
- Design élégant avec gradients bleu/cyan
- Animations fluides (flutter_animate)
- Icônes météo animées
- Mode sombre intégré
- Navigation intuitive

### 🏙️ Gestion Multi-Villes
- Ajoutez plusieurs villes en favoris
- Basculez rapidement entre vos localisations
- Prévisions pour toutes vos villes sauvegardées

### ⚙️ Paramètres Personnalisables
- Activez/désactivez les notifications
- Configurez les alertes selon vos besoins
- Gérez le widget et les mises à jour
- Réinitialisez vos données
- Accédez à la politique de confidentialité

### 🔒 Respect Total de Votre Vie Privée
- Aucune donnée envoyée à nos serveurs
- Stockage 100% local (SharedPreferences)
- Aucune publicité, aucun tracker
- Communications sécurisées (HTTPS)
- Conforme RGPD et CCPA
- Suppression des données à tout moment

---

## 📂 Structure du Projet

```
lib/
├── main.dart                              : Point d'entrée de l'application
│
├── core/                                  : Code de base réutilisable
│   ├── constants/
│   │   └── constants.dart                 : Constantes globales (couleurs, API key)
│   └── config/
│       └── app_initializer.dart           : Initialisation et routing de l'app
│
├── features/                              : Fonctionnalités par domaine
│   ├── home/                              : Page d'accueil météo
│   │   ├── pages/
│   │   │   └── home_page.dart             : Écran principal avec météo actuelle
│   │   └── widgets/
│   │       └── weather_item.dart          : Widget élément météo réutilisable
│   │
│   ├── weather/                           : Détails météo
│   │   └── pages/
│   │       └── detail_page.dart           : Page prévisions horaires détaillées
│   │
│   ├── settings/                          : Paramètres et configuration
│   │   └── pages/
│   │       ├── settings_page.dart         : Page paramètres et notifications
│   │       └── privacy_policy_page.dart   : Politique de confidentialité
│   │
│   ├── advice/                            : Conseils personnalisés
│   │   └── pages/
│   │       └── advice_page.dart           : Conseils météo + qualité de l'air
│   │
│   └── onboarding/                        : Première utilisation
│       └── pages/
│           ├── get_started_page.dart      : Écran de démarrage avec logo animé
│           ├── welcome_page.dart          : Sélection des villes favorites
│           └── user_onboarding_page.dart  : Onboarding utilisateur
│
└── shared/                                : Ressources partagées
    ├── models/
    │   └── city.dart                      : Modèle de données Ville (2600+ villes)
    │
    ├── services/                          : Services métier
    │   ├── notification_service.dart      : Gestion des notifications push
    │   ├── background_service.dart        : Service arrière-plan (mises à jour)
    │   ├── weather_widget_service.dart    : Service widget Android natif
    │   ├── user_service.dart              : Gestion utilisateur et préférences
    │   ├── location_service.dart          : Géolocalisation GPS
    │   ├── air_quality_service.dart       : API qualité de l'air
    │   ├── clothing_advice_service.dart   : Conseils vestimentaires intelligents
    │   └── daily_advice_service.dart      : Service conseils quotidiens
    │
    └── widgets/                           : Widgets partagés
        └── app_logo.dart                  : Logo animé réutilisable

assets/
├── Logo.png                               : Logo principal HordricWeather
├── clear.png, clouds.png, rain.png...     : Icônes conditions météo
└── [autres assets]                        : Icônes UI (humidité, vent, etc.)

android/
├── app/
│   ├── build.gradle                       : Configuration build Android
│   ├── upload-keystore.jks                : Clé de signature Play Store
│   └── src/main/res/
│       ├── layout/                        : Layouts widget Android
│       ├── xml/                           : Configuration widget
│       └── mipmap-*/                      : Icônes launcher (hdpi à xxxhdpi)
└── key.properties                         : Propriétés keystore (non versionné)
```

### 🏗️ Architecture

HordricWeather suit l'architecture **Feature-First** recommandée par Flutter :

- **`core/`** : Configuration et constantes globales
- **`features/`** : Fonctionnalités organisées par domaine métier (home, weather, settings, etc.)
- **`shared/`** : Code réutilisable (models, services, widgets communs)

Cette structure facilite :
- 📦 La scalabilité du projet
- 🧪 Les tests unitaires et d'intégration
- 👥 Le travail en équipe
- 🔄 La maintenance et les évolutions

---

## 🛠️ Installation et Compilation

### Prérequis

- Flutter 3.32.8 ou supérieur
- Dart 3.8.1 ou supérieur
- Android SDK 34 ou supérieur
- Compte OpenWeather API (gratuit) : [https://openweathermap.org/api](https://openweathermap.org/api)

### 📥 Installation

#### 1. Cloner le Repository
```bash
git clone https://github.com/HordRicJr/HordricWeather.git
cd HordricWeather
```

#### 2. Installer les Dépendances
```bash
flutter pub get
```

#### 3. Configurer l'API OpenWeather
Le projet utilise déjà une clé API OpenWeather configurée. Si vous souhaitez utiliser votre propre clé :

1. Créez un compte sur [OpenWeather](https://openweathermap.org/api)
2. Obtenez votre clé API gratuite
3. Remplacez la clé dans `lib/services/background_service.dart` :
```dart
static const String _weatherApiKey = 'VOTRE_CLE_API';
```

#### 4. Générer les Icônes Launcher
```bash
dart run flutter_launcher_icons
```

#### 5. Lancer l'Application

**Mode Debug**
```bash
flutter run
```

**Mode Release (APK)**
```bash
flutter build apk --release
```

**Mode Release (AAB pour Play Store)**
```bash
flutter build appbundle --release
```

---

## 📦 Dépendances Principales

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

---

## 🌐 API Utilisée

**OpenWeather API** : [https://openweathermap.org/](https://openweathermap.org/)

Endpoints utilisés :
- `/data/2.5/weather` : Météo actuelle
- `/data/2.5/forecast` : Prévisions horaires (5 jours)
- `/data/2.5/air_pollution` : Qualité de l'air

---

## 🔐 Permissions Android

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

---

## 🏗️ Architecture

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

---

## 📚 Documentation

- **[Politique de Confidentialité](https://hordricjr.github.io/HordricWeather/)** : Version web hébergée sur GitHub Pages
- **CONTRIBUTING.md** : Guide de contribution
- **LICENSE** : Licence MIT

---

## 🧪 Tests

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
```

---

## 👨‍💻 Auteur

**HordRicJr**
- GitHub : [https://github.com/HordRicJr](https://github.com/HordRicJr)
- Email : assounrodrigue5@gmail.com

---

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

## 🤝 Contributions

Les contributions sont les bienvenues ! N'hésitez pas à :

1. **Forker le projet** et ajouter une étoile ⭐
2. **Créer une branche** pour votre fonctionnalité
   ```bash
   git checkout -b feature/AmazingFeature
   ```
3. **Commiter vos changements**
   ```bash
   git commit -m 'Add some AmazingFeature'
   ```
4. **Pusher vers la branche**
   ```bash
   git push origin feature/AmazingFeature
   ```
5. **Ouvrir une Pull Request**

Consultez [CONTRIBUTING.md](CONTRIBUTING.md) pour plus de détails.

---

## 💬 Support

Pour toute question ou problème :
- Ouvrez une [issue](https://github.com/HordRicJr/HordricWeather/issues)
- Consultez la [documentation](https://hordricjr.github.io/HordricWeather/)
- Email : assounrodrigue5@gmail.com

---

## � Contributeurs ✨

Merci à ces personnes formidables qui ont contribué à ce projet ([emoji key](https://allcontributors.org/docs/en/emoji-key)) :

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%">
        <a href="https://github.com/HordRicJr">
          <img src="https://avatars.githubusercontent.com/HordRicJr?s=100" width="100px;" alt="HordRicJr"/>
          <br />
          <sub><b>ASSOUN Rodrigue</b></sub>
        </a>
        <br />
        <a href="https://github.com/HordRicJr/HordricWeather/commits?author=HordRicJr" title="Code"></a>
        <a href="#design-HordRicJr" title="Design"></a>
        <a href="https://github.com/HordRicJr/HordricWeather/commits?author=HordRicJr" title="Documentation"></a>
        <a href="#maintenance-HordRicJr" title="Maintenance"></a>
      </td>
      <td align="center" valign="top" width="14.28%">
        <a href="https://github.com/apps/dependabot">
          <img src="https://avatars.githubusercontent.com/in/29110?s=100&v=4" width="100px;" alt="Dependabot"/>
          <br />
          <sub><b>Dependabot</b></sub>
        </a>
        <br />
        <a href="#maintenance-dependabot" title="Maintenance"></a>
        <a href="#security-dependabot" title="Security"></a>
      </td>
      <td align="center" valign="top" width="14.28%">
        <a href="https://github.com/features/copilot">
          <img src="https://avatars.githubusercontent.com/in/44036?s=100&v=4" width="100px;" alt="GitHub Copilot"/>
          <br />
          <sub><b>GitHub Copilot</b></sub>
        </a>
        <br />
        <a href="https://github.com/HordRicJr/HordricWeather/commits?author=copilot" title="Code">💻</a>
        <a href="#ideas-copilot" title="Ideas"></a>
        <a href="#tool-copilot" title="Tools"></a>
      </td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

Ce projet suit la spécification [all-contributors](https://github.com/all-contributors/all-contributors). Les contributions de toute nature sont les bienvenues !

---

## 📝 Changelog

### Version 1.0.0 (8 octobre 2025)
- ✨ Première version publique
- 🌤️ Météo complète avec prévisions horaires et 5 jours
- 🔔 Système de notifications intelligent avec cooldowns
- 🌍 Qualité de l'air et conseils santé
- 📱 Widget Android personnalisable
- 🔒 Politique de confidentialité complète (RGPD/CCPA)
- 🎨 Interface moderne avec animations
- 💡 Conseils vestimentaires et activités
- 🏙️ Gestion multi-villes
- 🚫 Aucune publicité, respect de la vie privée
- 🤖 CI/CD avec GitHub Actions
- 🛡️ Dependabot activé pour les mises à jour automatiques

---

<div align="center">

**HordricWeather** - Votre compagnon météo intelligent 🌤️

Made with ❤️ by [HordRicJr](https://github.com/HordRicJr) et la communauté

[![GitHub stars](https://img.shields.io/github/stars/HordRicJr/HordricWeather?style=social)](https://github.com/HordRicJr/HordricWeather/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/HordRicJr/HordricWeather?style=social)](https://github.com/HordRicJr/HordricWeather/network/members)
[![GitHub watchers](https://img.shields.io/github/watchers/HordRicJr/HordricWeather?style=social)](https://github.com/HordRicJr/HordricWeather/watchers)

[![Star this repo](https://img.shields.io/github/stars/HordRicJr/HordricWeather?style=social)](https://github.com/HordRicJr/HordricWeather)

</div>
