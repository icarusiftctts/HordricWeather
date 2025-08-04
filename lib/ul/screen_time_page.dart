import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/constants.dart';
import '../services/screen_time_service.dart';

class ScreenTimePage extends StatefulWidget {
  const ScreenTimePage({Key? key}) : super(key: key);

  @override
  State<ScreenTimePage> createState() => _ScreenTimePageState();
}

class _ScreenTimePageState extends State<ScreenTimePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> weeklyStats = [];
  bool isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadWeeklyStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadWeeklyStats() async {
    final stats = await ScreenTimeService.getWeeklyStatistics();
    setState(() {
      weeklyStats = stats;
      isLoadingStats = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Constants myConstants = Constants();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              myConstants.primaryColor,
              myConstants.primaryColor.withOpacity(0.8),
              myConstants.secondaryColor.withOpacity(0.6),
              Colors.grey[50]!,
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(myConstants),
              _buildTabBar(myConstants),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTodayTab(),
                    _buildWeeklyTab(),
                    _buildTipsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Constants myConstants) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Temps d\'Écran',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Suivi et conseils d\'usage',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3);
  }

  Widget _buildTabBar(Constants myConstants) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: [
          Tab(icon: Icon(Icons.today), text: 'Aujourd\'hui'),
          Tab(icon: Icon(Icons.bar_chart), text: 'Semaine'),
          Tab(icon: Icon(Icons.tips_and_updates), text: 'Conseils'),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 600.ms);
  }

  Widget _buildTodayTab() {
    final advice = ScreenTimeService.getScreenTimeAdvice();
    final topApps = ScreenTimeService.getTopAppsToday(5);
    final totalMinutes = ScreenTimeService.getTotalScreenTimeToday();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Carte principale du temps d'écran
          _buildMainTimeCard(advice, totalMinutes)
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms),

          const SizedBox(height: 20),

          // Applications les plus utilisées
          if (topApps.isNotEmpty) ...[
            _buildSectionTitle('📱 Applications les plus utilisées'),
            const SizedBox(height: 15),
            ...topApps.asMap().entries.map((entry) {
              final index = entry.key;
              final app = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: _buildAppUsageCard(app['name'], app['minutes']),
              )
                  .animate()
                  .fadeIn(delay: (600 + index * 100).ms, duration: 600.ms)
                  .slideX(begin: 0.3);
            }).toList(),
          ] else
            _buildNoDataCard(
                'Aucune donnée d\'usage disponible pour aujourd\'hui'),
        ],
      ),
    );
  }

  Widget _buildWeeklyTab() {
    if (isLoadingStats) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildSectionTitle('📊 Statistiques de la semaine'),
          const SizedBox(height: 20),

          // Graphique en barres
          _buildWeeklyChart().animate().fadeIn(delay: 400.ms, duration: 600.ms),

          const SizedBox(height: 30),

          // Liste détaillée
          ...weeklyStats.asMap().entries.map((entry) {
            final index = entry.key;
            final stat = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: _buildDayStatCard(stat),
            )
                .animate()
                .fadeIn(delay: (500 + index * 50).ms, duration: 600.ms)
                .slideX(begin: 0.2);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTipsTab() {
    final advice = ScreenTimeService.getScreenTimeAdvice();
    final staticTips = ScreenTimeService.getHealthyUsageTips();
    final totalMinutes = ScreenTimeService.getTotalScreenTimeToday();
    final topApps = ScreenTimeService.getTopAppsToday(3);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Conseils personnalisés basés sur l'usage
          _buildPersonalizedAdviceCard(advice, totalMinutes, topApps)
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms),

          const SizedBox(height: 25),

          // Conseils généraux
          _buildSectionTitle('💡 Conseils généraux pour un usage sain'),
          const SizedBox(height: 20),
          ...staticTips.asMap().entries.map((entry) {
            final index = entry.key;
            final tip = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: _buildTipCard(tip),
            )
                .animate()
                .fadeIn(delay: (600 + index * 100).ms, duration: 600.ms)
                .slideY(begin: 0.3);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPersonalizedAdviceCard(Map<String, String> advice,
      int totalMinutes, List<Map<String, dynamic>> topApps) {
    final hours = totalMinutes / 60;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec emoji et statut
          Row(
            children: [
              Text(
                advice['emoji'] ?? '📱',
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      advice['category'] ?? 'Analyse',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${hours.toStringAsFixed(1)}h aujourd\'hui',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Conseil principal
          Text(
            advice['advice'] ?? 'Continuez à surveiller votre temps d\'écran.',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
            ),
          ),

          // Conseils spécifiques si disponibles
          if (advice['tips'] != null && advice['tips']!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✨ Conseils personnalisés',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• ${advice['tips']!}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMainTimeCard(Map<String, String> advice, int totalMinutes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Emoji et catégorie
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(advice['emoji']!, style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Text(
                advice['category']!,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Temps total
          Text(
            '${advice['totalHours']}h',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),

          Text(
            'aujourd\'hui',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 20),

          // Conseil
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              advice['advice']!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppUsageCard(String appName, int minutes) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.smartphone, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(minutes / 60).toStringAsFixed(1)}h utilisée',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${minutes}min',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final maxMinutes = weeklyStats.isNotEmpty
        ? weeklyStats
            .map((s) => s['totalMinutes'] as int)
            .reduce((a, b) => a > b ? a : b)
        : 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            'Temps d\'écran par jour',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: weeklyStats.map((stat) {
              final minutes = stat['totalMinutes'] as int;
              final height = maxMinutes > 0
                  ? (minutes / maxMinutes * 100).clamp(10.0, 100.0)
                  : 10.0;

              return Column(
                children: [
                  Text(
                    '${(minutes / 60).toStringAsFixed(1)}h',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 20,
                    height: height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.blue.shade300,
                          Colors.purple.shade300,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stat['dayName'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDayStatCard(Map<String, dynamic> stat) {
    final date = stat['date'] as DateTime;
    final isToday = DateTime.now().day == date.day;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isToday
            ? Colors.white.withOpacity(0.2)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isToday
              ? Colors.white.withOpacity(0.4)
              : Colors.white.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday ? 'Aujourd\'hui' : stat['dayName'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${date.day}/${date.month}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${stat['totalHours']}h',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(Map<String, String> tip) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(tip['icon']!, style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tip['title']!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tip['description']!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildNoDataCard(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.white70, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
