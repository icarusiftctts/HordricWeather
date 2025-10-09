import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/constants.dart';
import '../../../shared/services/clothing_advice_service.dart';
import '../../../shared/services/air_quality_service.dart';

class AdvicePage extends StatefulWidget {
  final Map<String, dynamic>? weatherData;
  final String location;

  const AdvicePage({
    Key? key,
    required this.weatherData,
    required this.location,
  }) : super(key: key);

  @override
  State<AdvicePage> createState() => _AdvicePageState();
}

class _AdvicePageState extends State<AdvicePage> with TickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? airQualityData;
  bool isLoadingAirQuality = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAirQuality();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadAirQuality() async {
    if (widget.weatherData != null) {
      final lat = widget.weatherData!['coord']['lat'];
      final lon = widget.weatherData!['coord']['lon'];

      final airData = await AirQualityService.getAirQuality(lat, lon);
      setState(() {
        airQualityData = airData;
        isLoadingAirQuality = false;
      });
    }
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
                    _buildClothingAdvice(),
                    _buildActivitySuggestions(),
                    _buildAirQuality(),
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
            icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conseils & Activités',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      widget.location,
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
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
          Tab(icon: Icon(Icons.checkroom), text: 'Tenue'),
          Tab(icon: Icon(Icons.sports_soccer), text: 'Activités'),
          Tab(icon: Icon(Icons.air), text: 'Air'),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 600.ms);
  }

  Widget _buildClothingAdvice() {
    if (widget.weatherData == null) {
      return Center(child: Text('Aucune donnée météo disponible'));
    }

    final temp = widget.weatherData!['main']['temp'];
    final weatherCondition = widget.weatherData!['weather'][0]['main']
        .toLowerCase();
    final windSpeed = widget.weatherData!['wind']['speed'] * 3.6;

    final advice = ClothingAdviceService.getClothingAdvice(
      temp,
      weatherCondition,
      windSpeed,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildAdviceCard(
            '👔 Tenue Recommandée',
            advice['outfit']!,
            advice['emoji']!,
            Colors.blue.withOpacity(0.1),
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

          const SizedBox(height: 20),

          _buildAdviceCard(
            '💡 Conseil du Jour',
            advice['tip']!,
            '💡',
            Colors.orange.withOpacity(0.1),
          ).animate().fadeIn(delay: 500.ms, duration: 600.ms),

          const SizedBox(height: 20),

          _buildTemperatureScale(
            temp,
          ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildActivitySuggestions() {
    if (widget.weatherData == null) {
      return Center(child: Text('Aucune donnée météo disponible'));
    }

    final temp = widget.weatherData!['main']['temp'];
    final weatherCondition = widget.weatherData!['weather'][0]['main']
        .toLowerCase();

    final activities = ClothingAdviceService.getActivitySuggestions(
      temp,
      weatherCondition,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activités suggérées pour aujourd\'hui',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

          const SizedBox(height: 20),

          ...activities.asMap().entries.map((entry) {
            final index = entry.key;
            final activity = entry.value;
            return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: _buildActivityCard(
                    activity['activity']!,
                    activity['emoji']!,
                    activity['location']!,
                  ),
                )
                .animate()
                .fadeIn(delay: (500 + index * 100).ms, duration: 600.ms)
                .slideX(begin: 0.3);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAirQuality() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Qualité de l\'Air',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

          const SizedBox(height: 20),

          if (isLoadingAirQuality)
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else if (airQualityData != null)
            Column(
              children: [
                _buildAirQualityCard(),
                const SizedBox(height: 20),
                _buildAirComponentsGrid(),
              ],
            )
          else
            _buildAdviceCard(
              'ℹ️ Information',
              'Données de qualité de l\'air non disponibles pour cette région.',
              'ℹ️',
              Colors.grey.withOpacity(0.1),
            ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard(
    String title,
    String content,
    String emoji,
    Color backgroundColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
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
            content,
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

  Widget _buildActivityCard(String activity, String emoji, String location) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(emoji, style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
        ],
      ),
    );
  }

  Widget _buildTemperatureScale(double temp) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '🌡️ Échelle de Température',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue,
                        Colors.cyan,
                        Colors.green,
                        Colors.yellow,
                        Colors.orange,
                        Colors.red,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '-10°C',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                '0°C',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                '20°C',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                '40°C',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Température actuelle: ${temp.round()}°C',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAirQualityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(airQualityData!['emoji'], style: TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      airQualityData!['qualityLevel'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Indice: ${airQualityData!['aqi']}/5',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            airQualityData!['recommendation'],
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            airQualityData!['healthAdvice'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 600.ms);
  }

  Widget _buildAirComponentsGrid() {
    final components = AirQualityService.getDetailedComponents(
      airQualityData!['components'],
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: components.length,
      itemBuilder: (context, index) {
        final component = components[index];
        return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    component['name']!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    component['value']!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      component['description']!,
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(delay: (600 + index * 100).ms, duration: 600.ms)
            .scale(begin: Offset(0.8, 0.8));
      },
    );
  }
}
