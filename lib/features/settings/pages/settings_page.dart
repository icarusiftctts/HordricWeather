import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hordricweather/features/home/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/weather_widget_service.dart';
import '../../../shared/services/background_service.dart';
import 'privacy_policy_page.dart';
import 'package:hordricweather/widgets/custom_snackbar.dart'; // ✅ Added import

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _lockScreenEnabled = false;
  bool _dailyNotificationEnabled = true;
  bool _weatherAlertsEnabled = true;
  bool _widgetEnabled = true;
  bool _backgroundUpdateEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _lockScreenEnabled = prefs.getBool('lockscreen_enabled') ?? false;
      _dailyNotificationEnabled =
          prefs.getBool('daily_notification_enabled') ?? true;
      _weatherAlertsEnabled = prefs.getBool('weather_alerts_enabled') ?? true;
      _widgetEnabled = prefs.getBool('widget_enabled') ?? true;
      _backgroundUpdateEnabled =
          prefs.getBool('background_update_enabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('lockscreen_enabled', _lockScreenEnabled);
    await prefs.setBool(
        'daily_notification_enabled', _dailyNotificationEnabled);
    await prefs.setBool('weather_alerts_enabled', _weatherAlertsEnabled);
    await prefs.setBool('widget_enabled', _widgetEnabled);
    await prefs.setBool('background_update_enabled', _backgroundUpdateEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.screenGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.spacingXL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('🔔 Notifications'),
                      _buildSettingCard(
                        icon: Icons.notifications,
                        title: 'Notifications générales',
                        subtitle: 'Activer toutes les notifications',
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                          _saveSettings();
                        },
                      ),
                      _buildSettingCard(
                        icon: Icons.lock_outline,
                        title: 'Écran de verrouillage',
                        subtitle: 'Afficher la météo sur l\'écran verrouillé',
                        value: _lockScreenEnabled,
                        onChanged: _notificationsEnabled
                            ? (value) {
                                setState(() {
                                  _lockScreenEnabled = value;
                                });
                                _saveSettings();
                              }
                            : null,
                      ),
                      _buildSettingCard(
                        icon: Icons.today,
                        title: 'Météo quotidienne',
                        subtitle: 'Notification quotidienne à 8h',
                        value: _dailyNotificationEnabled,
                        onChanged: _notificationsEnabled
                            ? (value) {
                                setState(() {
                                  _dailyNotificationEnabled = value;
                                });
                                _saveSettings();
                              }
                            : null,
                      ),
                      _buildSettingCard(
                        icon: Icons.warning,
                        title: 'Alertes météo',
                        subtitle: 'Alertes pour conditions extrêmes',
                        value: _weatherAlertsEnabled,
                        onChanged: _notificationsEnabled
                            ? (value) {
                                setState(() {
                                  _weatherAlertsEnabled = value;
                                });
                                _saveSettings();
                              }
                            : null,
                      ),
                      const SizedBox(height: AppTheme.spacing3XL),
                      _buildSectionTitle('📱 Widget & Arrière-plan'),
                      _buildSettingCard(
                        icon: Icons.widgets,
                        title: 'Widget écran d\'accueil',
                        subtitle: 'Météo sur l\'écran d\'accueil',
                        value: _widgetEnabled,
                        onChanged: (value) {
                          setState(() {
                            _widgetEnabled = value;
                          });
                          _saveSettings();
                          if (value) {
                            WeatherWidgetService.updateWidget();
                          }
                        },
                      ),
                      _buildSettingCard(
                        icon: Icons.sync,
                        title: 'Mise à jour automatique',
                        subtitle: 'Actualisation en arrière-plan',
                        value: _backgroundUpdateEnabled,
                        onChanged: (value) {
                          setState(() {
                            _backgroundUpdateEnabled = value;
                          });
                          _saveSettings();
                          if (value) {
                            BackgroundWeatherService.initialize();
                          } else {
                            BackgroundWeatherService.cancelAllTasks();
                          }
                        },
                      ),
                      const SizedBox(height: AppTheme.spacing3XL),
                      _buildSectionTitle('ℹ️ Informations'),
                      _buildActionButton(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Politique de Confidentialité',
                        subtitle: 'Vos données et votre vie privée',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PrivacyPolicyPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppTheme.radiusL),
                      _buildActionButton(
                        icon: Icons.delete_outline,
                        title: 'Réinitialiser les données',
                        subtitle: 'Supprimer toutes vos données',
                        onTap: () {
                          _showResetDialog().then((_) {
                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Home(),
                                ),
                              );
                            });
                          });
                        },
                      ),
                      const SizedBox(height: AppTheme.spacing3XL),
                      _buildSectionTitle('📱 Actions'),
                      _buildActionButton(
                        icon: Icons.refresh,
                        title: 'Mettre à jour le widget',
                        subtitle: 'Actualiser manuellement',
                        onTap: () async {
                          await WeatherWidgetService.updateWidget();
                          // ✅ Replaced old SnackBar with custom floating SnackBar
                          showCustomSnackBar(
                            context,
                            'Widget mis à jour!',
                            backgroundColor: AppTheme.success,
                          );
                        },
                      ),
                      const SizedBox(height: AppTheme.radiusL),
                      _buildActionButton(
                        icon: Icons.info_outline,
                        title: 'À propos du widget',
                        subtitle: 'Instructions d\'installation',
                        onTap: () => _showWidgetInstructions(),
                      ),
                      const SizedBox(height: AppTheme.spacingXL),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.overlay20,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios,
                color: AppTheme.textOnPrimary,
                size: AppTheme.iconSizeM,
              ),
            ),
          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3),
          const SizedBox(width: AppTheme.spacingXL),
          const Text(
            'Paramètres',
            style: TextStyle(
              color: AppTheme.textOnPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
        ],
      ),
    );
  }

  // ✅ Updated reset dialog to use floating SnackBar
  Future<void> _showResetDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.gradientDeep,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: AppTheme.warning, size: 28),
            SizedBox(width: 10),
            Text(
              'Réinitialiser les données',
              style: TextStyle(color: AppTheme.textOnPrimary, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Cette action supprimera :\n\n'
          '• Votre nom d\'utilisateur\n'
          '• Vos villes favorites\n'
          '• Vos préférences de notification\n'
          '• L\'historique des notifications\n\n'
          'Cette action est irréversible.',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                Navigator.pop(context);
                // ✅ New floating custom SnackBar
                showCustomSnackBar(
                  context,
                  'Données réinitialisées avec succès',
                  backgroundColor: AppTheme.success,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: AppTheme.textOnPrimary,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showWidgetInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📱 Installation du Widget'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Pour ajouter le widget HordricWeather à votre écran d\'accueil:'),
            SizedBox(height: 16),
            Text('1. Appuyez longuement sur l\'écran d\'accueil'),
            Text('2. Sélectionnez "Widgets"'),
            Text('3. Trouvez "HordricWeather"'),
            Text('4. Glissez-déposez sur l\'écran'),
            SizedBox(height: 16),
            Text(
                'Le widget se met à jour automatiquement toutes les 30 minutes.',
                style: TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  // (rest of the file unchanged)
}
