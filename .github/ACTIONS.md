# 🚀 GitHub Actions CI/CD Documentation

Ce projet utilise GitHub Actions pour automatiser l'analyse, les tests et le build de l'application HordricWeather.

## 📋 Workflows Disponibles

### 1. 🔍 Flutter Analyze
**Fichier:** `.github/workflows/flutter_analyze.yml`

**Déclenchement:**
- Push sur `main` ou `develop`
- Pull Request vers `main` ou `develop`
- Manuellement via `workflow_dispatch`

**Actions:**
- ✅ Vérification du formatage du code
- 🔍 Analyse statique avec `flutter analyze`
- 📊 Détection des dépendances obsolètes
- ⚠️ Traite les warnings comme des erreurs

**Badge:** [![Flutter Analyze](https://github.com/HordRicJr/HordricWeather/actions/workflows/flutter_analyze.yml/badge.svg)](https://github.com/HordRicJr/HordricWeather/actions/workflows/flutter_analyze.yml)

---

### 2. 🧪 Flutter Test
**Fichier:** `.github/workflows/flutter_test.yml`

**Déclenchement:**
- Push sur `main` ou `develop`
- Pull Request vers `main` ou `develop`
- Manuellement via `workflow_dispatch`

**Actions:**
- 🧪 Exécution de tous les tests unitaires
- 📊 Génération du rapport de couverture
- ☁️ Upload du coverage vers Codecov (optionnel)

**Badge:** [![Flutter Test](https://github.com/HordRicJr/HordricWeather/actions/workflows/flutter_test.yml/badge.svg)](https://github.com/HordRicJr/HordricWeather/actions/workflows/flutter_test.yml)

---

### 3. 🏗️ Build APK
**Fichier:** `.github/workflows/build_apk.yml`

**Déclenchement:**
- Push sur `main`
- Tags `v*` (releases)
- Pull Request vers `main`
- Manuellement via `workflow_dispatch`

**Actions:**
- 🏗️ Build APK Debug (pour les PRs)
- 🏗️ Build APK Release avec split-per-abi (pour main)
- 📦 Upload des artifacts (3 APKs : arm64-v8a, armeabi-v7a, x86_64)
- 📊 Analyse de la taille des APKs

**Retention:** 30 jours

**Badge:** [![Build APK](https://github.com/HordRicJr/HordricWeather/actions/workflows/build_apk.yml/badge.svg)](https://github.com/HordRicJr/HordricWeather/actions/workflows/build_apk.yml)

---

### 4. 📈 Code Quality
**Fichier:** `.github/workflows/code_quality.yml`

**Déclenchement:**
- Push sur `main` ou `develop`
- Pull Request vers `main` ou `develop`
- Programmé (tous les lundis à 9h UTC)
- Manuellement via `workflow_dispatch`

**Actions:**
- 📏 Comptage des lignes de code
- 🧮 Analyse de la complexité du code
- 🔒 Audit de sécurité des dépendances
- 📦 Analyse de l'arbre des dépendances
- 🎯 Détection de code inutilisé

**Badge:** [![Code Quality](https://github.com/HordRicJr/HordricWeather/actions/workflows/code_quality.yml/badge.svg)](https://github.com/HordRicJr/HordricWeather/actions/workflows/code_quality.yml)

---

### 5. ✅ PR Checker
**Fichier:** `.github/workflows/pr_checker.yml`

**Déclenchement:**
- Ouverture d'une Pull Request
- Synchronisation (nouveau commit)
- Réouverture d'une PR

**Actions:**
- 🏷️ Vérification des labels de la PR
- 📝 Vérification de la description (min 50 caractères)
- 📊 Analyse des fichiers modifiés
- 🧪 Tests rapides sur les fichiers modifiés
- 📏 Estimation de l'impact sur la taille de l'APK

---

## 🔧 Configuration

### Prérequis
- Repository GitHub avec GitHub Actions activé
- Permissions d'écriture pour les workflows
- (Optionnel) Compte Codecov pour la couverture de tests

### Variables d'environnement
Aucune variable d'environnement requise pour le moment. La clé API OpenWeather est hardcodée dans `constants.dart` (pour développement uniquement).

### Secrets GitHub
Pour une utilisation en production, ajoutez ces secrets dans `Settings > Secrets and variables > Actions` :

- `OPENWEATHER_API_KEY` : Clé API OpenWeather
- `ANDROID_KEYSTORE_PASSWORD` : Mot de passe du keystore (pour les releases signées)
- `CODECOV_TOKEN` : Token Codecov (optionnel)

---

## 📊 Monitoring et Statut

### Consulter les runs
1. Allez sur l'onglet **Actions** du repository
2. Sélectionnez le workflow à consulter
3. Cliquez sur un run spécifique pour voir les détails

### Badges de statut
Les badges sont affichés dans le README.md et se mettent à jour automatiquement après chaque run.

### Notifications
- ✅ **Success** : Workflow terminé avec succès
- ⚠️ **Warning** : Workflow terminé avec warnings
- ❌ **Failure** : Workflow échoué (nécessite une correction)

GitHub envoie des notifications par email en cas d'échec.

---

## 🛠️ Maintenance

### Mettre à jour Flutter
Modifiez la version dans chaque workflow :
```yaml
flutter-version: '3.32.8'  # Changez cette valeur
```

### Ajouter un nouveau workflow
1. Créez un fichier `.github/workflows/nouveau_workflow.yml`
2. Définissez les déclencheurs (`on:`)
3. Ajoutez les jobs et steps
4. Committez et pushez

### Déboguer un workflow
- Ajoutez `workflow_dispatch:` pour exécution manuelle
- Utilisez `continue-on-error: true` pour les steps non-bloquants
- Ajoutez des `echo` pour le debugging

---

## 🎯 Bonnes Pratiques

### Pour les contributeurs
- ✅ Assurez-vous que `flutter analyze` passe localement avant de push
- 🧪 Exécutez les tests avec `flutter test` localement
- 📝 Ajoutez une description détaillée à vos PRs
- 🏷️ Utilisez les labels appropriés (bug, enhancement, etc.)

### Pour les mainteneurs
- 🔍 Revoyez les résultats des workflows avant de merger
- 📊 Surveillez la couverture des tests (objectif : 80%+)
- 🔒 Vérifiez régulièrement les dépendances obsolètes
- 📦 Optimisez la taille des APKs si nécessaire

---

## 🚨 Résolution de Problèmes

### Workflow échoue sur analyze
- Exécutez `flutter analyze` localement
- Corrigez les warnings et erreurs
- Committez les corrections

### Tests échouent
- Exécutez `flutter test` localement
- Vérifiez les logs d'erreur
- Corrigez les tests défaillants

### Build APK échoue
- Vérifiez les dépendances dans `pubspec.yaml`
- Assurez-vous que `flutter build apk` fonctionne localement
- Vérifiez les erreurs de compilation Android

---

## 📚 Ressources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD Best Practices](https://docs.flutter.dev/deployment/cd)
- [Codecov Documentation](https://docs.codecov.com/)

---

**Dernière mise à jour:** Octobre 2025
**Maintenu par:** @HordRicJr
