import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text(
          'Politique de Confidentialité',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1B263B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSection(
                'Introduction',
                'HordricWeather est une application mobile de prévisions météorologiques. Cette politique explique comment nous collectons, utilisons et protégeons vos informations personnelles.',
                Icons.info_outline,
              ),
              _buildSection(
                'Données Collectées',
                'Nous collectons uniquement les données nécessaires au fonctionnement de l\'application :\n\n'
                '• Localisation GPS (latitude, longitude)\n'
                '• Nom d\'utilisateur (optionnel)\n'
                '• Villes favorites\n'
                '• Préférences de notification\n\n'
                'Toutes ces données sont stockées UNIQUEMENT sur votre appareil.',
                Icons.location_on_outlined,
              ),
              _buildSection(
                'Utilisation des Données',
                'Vos données sont utilisées exclusivement pour :\n\n'
                '• Afficher les prévisions météorologiques\n'
                '• Envoyer des notifications météo pertinentes\n'
                '• Afficher la qualité de l\'air\n'
                '• Proposer des conseils vestimentaires\n\n'
                'Aucune donnée n\'est utilisée à des fins publicitaires ou commerciales.',
                Icons.lightbulb_outline,
              ),
              _buildSection(
                'Partage des Données',
                'L\'application communique uniquement avec OpenWeather API pour récupérer les données météorologiques.\n\n'
                'Nous ne disposons PAS de serveurs backend. Toutes vos données personnelles restent sur votre appareil.\n\n'
                'Nous ne vendons JAMAIS vos données à des tiers.',
                Icons.shield_outlined,
              ),
              _buildSection(
                'Sécurité',
                'Nous mettons en œuvre les mesures suivantes :\n\n'
                '• Communications chiffrées via HTTPS\n'
                '• Stockage sécurisé dans le bac à sable Android\n'
                '• Aucune transmission de données sensibles\n'
                '• Mise à jour régulière des dépendances',
                Icons.lock_outline,
              ),
              _buildSection(
                'Permissions Requises',
                'L\'application demande les permissions suivantes :\n\n'
                '• Localisation : Pour afficher la météo de votre position\n'
                '• Internet : Pour récupérer les données météo\n'
                '• Notifications : Pour les alertes météo (optionnel)\n'
                '• Localisation en arrière-plan : Pour les mises à jour automatiques (optionnel)\n\n'
                'Vous pouvez modifier ces permissions dans les paramètres Android.',
                Icons.security_outlined,
              ),
              _buildSection(
                'Vos Droits',
                'Vous disposez des droits suivants :\n\n'
                '• Accéder à vos données (via Paramètres)\n'
                '• Modifier vos informations\n'
                '• Supprimer toutes vos données\n'
                '• Retirer votre consentement\n\n'
                'Pour supprimer vos données : Menu → Paramètres → Réinitialiser les données',
                Icons.person_outline,
              ),
              _buildSection(
                'Notifications',
                'Vous pouvez recevoir les notifications suivantes :\n\n'
                '• Alertes météo extrêmes\n'
                '• Changements météorologiques significatifs\n'
                '• Prévisions horaires\n'
                '• Météo quotidienne (8h00)\n\n'
                'Désactivez-les dans : Paramètres → Notifications',
                Icons.notifications_outlined,
              ),
              _buildSection(
                'Protection des Mineurs',
                'L\'application ne collecte pas sciemment d\'informations d\'enfants de moins de 13 ans. Si vous êtes parent et que votre enfant a fourni des informations, veuillez nous contacter.',
                Icons.family_restroom_outlined,
              ),
              _buildSection(
                'Cookies et Tracking',
                'L\'application n\'utilise PAS :\n\n'
                '• Cookies de suivi\n'
                '• Trackers publicitaires\n'
                '• Technologies de suivi comportemental\n\n'
                'Seules les données de cache météo (30 min) et les horodatages de notifications sont stockés localement.',
                Icons.cookie_outlined,
              ),
              _buildSection(
                'Législation Applicable',
                'Cette politique est conforme aux réglementations suivantes :\n\n'
                '• RGPD (Union Européenne)\n'
                '• CCPA (Californie, USA)\n'
                '• Lois locales applicables\n\n'
                'Vous pouvez déposer une plainte auprès de l\'autorité de protection des données de votre pays (CNIL en France).',
                Icons.gavel_outlined,
              ),
              const SizedBox(height: 10),
              _buildContactSection(context),
              const SizedBox(height: 10),
              _buildFooter(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E3192), Color(0xFF1BCEDF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.privacy_tip_outlined, color: Colors.white, size: 30),
              SizedBox(width: 10),
              Text(
                'Vos Données, Votre Contrôle',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Dernière mise à jour : 8 octobre 2025',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1BCEDF), size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF415A77), Color(0xFF778DA9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.contact_mail_outlined, color: Colors.white, size: 24),
              SizedBox(width: 10),
              Text(
                'Contact',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Pour toute question concernant cette politique ou vos données personnelles :',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
          _buildContactItem(Icons.person, 'Développeur : HordRicJr'),
          const SizedBox(height: 5),
          InkWell(
            onTap: () => _launchEmail(context),
            child: _buildContactItem(
              Icons.email,
              'Email : assounrodrigue5@gmail.com',
              isLink: true,
            ),
          ),
          const SizedBox(height: 5),
          InkWell(
            onTap: () => _launchGitHub(context),
            child: _buildContactItem(
              Icons.code,
              'GitHub : HordRicJr/HordricWeather',
              isLink: true,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Délai de réponse : 30 jours maximum',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white60,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text, {bool isLink = false}) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              decoration: isLink ? TextDecoration.underline : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF2E3192),
          width: 2,
        ),
      ),
      child: const Column(
        children: [
          Icon(Icons.check_circle_outline, color: Color(0xFF1BCEDF), size: 40),
          SizedBox(height: 10),
          Text(
            'Résumé des Points Clés',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            '• Localisation utilisée uniquement pour la météo\n'
            '• Aucune donnée envoyée à nos serveurs\n'
            '• Tout stocké localement sur votre appareil\n'
            '• Suppression de données à tout moment\n'
            '• Aucune publicité, aucun tracker\n'
            '• Communications sécurisées via HTTPS',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.6,
            ),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 15),
          Text(
            'Version 1.0.0 | 8 octobre 2025',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white60,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'assounrodrigue5@gmail.com',
      query: 'subject=HordricWeather - Politique de Confidentialité',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir l\'application email'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchGitHub(BuildContext context) async {
    final Uri githubUri = Uri.parse('https://github.com/HordRicJr/HordricWeather');

    if (await canLaunchUrl(githubUri)) {
      await launchUrl(githubUri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir le lien GitHub'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
