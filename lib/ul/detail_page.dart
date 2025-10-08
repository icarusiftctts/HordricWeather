import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:hordricweather/ul/widgets/weather_item.dart';
import 'package:hordricweather/ul/welcome.dart';

class DetailPage extends StatefulWidget {
  final List<Map<String, dynamic>> consolidatedWeatherList;
  final String? location;

  const DetailPage({
    Key? key,
    required this.consolidatedWeatherList,
    this.location,
  }) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<Map<String, dynamic>> hourlyWeatherData = [];
  String imageUrl = '';
  String weatherStateName = 'Chargement...';

  @override
  void initState() {
    super.initState();
    hourlyWeatherData = widget.consolidatedWeatherList;
    if (hourlyWeatherData.isNotEmpty) {
      print('Hourly Weather Data: $hourlyWeatherData');

      DateTime now = DateTime.now();
      int selectedIndex = 0;

      // Trouver l'index de l'heure actuelle ou la plus proche
      for (int i = 0; i < hourlyWeatherData.length; i++) {
        DateTime weatherTime;
        if (hourlyWeatherData[i]['dt'] != null) {
          weatherTime = DateTime.fromMillisecondsSinceEpoch(
              hourlyWeatherData[i]['dt'] * 1000);
        } else if (hourlyWeatherData[i]['dt_txt'] != null) {
          try {
            weatherTime = DateTime.parse(hourlyWeatherData[i]['dt_txt']);
          } catch (e) {
            continue;
          }
        } else {
          continue;
        }

        if (weatherTime.isAfter(now) || i == hourlyWeatherData.length - 1) {
          selectedIndex = i;
          break;
        }
      }

      weatherStateName =
          hourlyWeatherData[selectedIndex]['weather'][0]['main'] ?? '';
      imageUrl = weatherStateName.replaceAll(' ', '').toLowerCase();
    } else {
      print("Aucune donnée météo disponible.");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.consolidatedWeatherList.isEmpty || hourlyWeatherData.isEmpty) {
      return _buildEmptyState();
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2E3192),
              const Color(0xFF1BCEDF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildModernAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLocationHeader(),
                      const SizedBox(height: 30),
                      _buildCurrentWeatherCard(),
                      const SizedBox(height: 30),
                      _buildHourlyForecastSection(),
                      const SizedBox(height: 30),
                      _buildWeatherDetailsGrid(),
                      const SizedBox(height: 20),
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

  Widget _buildEmptyState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails météo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'Aucune donnée disponible',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Vérifiez votre connexion internet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
            ),
          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3),
          const Spacer(),
          Text(
            'Détails météo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Welcome()),
                );
              },
              icon: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 20,
              ),
            ),
          ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.3),
        ],
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.location ?? 'Localisation inconnue',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.3),
        const SizedBox(height: 8),
        Text(
          DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(DateTime.now()),
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w400,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 800.ms).slideY(begin: -0.3),
      ],
    );
  }

  Widget _buildCurrentWeatherCard() {
    if (hourlyWeatherData.isEmpty) return Container();

    final currentWeather = hourlyWeatherData[0];
    final temp = currentWeather['main']['temp'].round();
    final description = currentWeather['weather'][0]['description'] ?? '';
    final icon = currentWeather['weather'][0]['icon'] ?? '01d';

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${temp}°',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    height: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Image.network(
              'http://openweathermap.org/img/wn/$icon@4x.png',
              width: 80,
              height: 80,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/$imageUrl.png',
                  width: 80,
                  height: 80,
                );
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 1000.ms).slideY(begin: 0.3);
  }

  Widget _buildHourlyForecastSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.schedule,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Prévisions horaires',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.3),
        const SizedBox(height: 20),
        Container(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount:
                hourlyWeatherData.length > 8 ? 8 : hourlyWeatherData.length,
            itemBuilder: (context, index) {
              final weather = hourlyWeatherData[index];
              DateTime time;

              if (weather['dt'] != null) {
                time =
                    DateTime.fromMillisecondsSinceEpoch(weather['dt'] * 1000);
              } else if (weather['dt_txt'] != null) {
                try {
                  time = DateTime.parse(weather['dt_txt']);
                } catch (e) {
                  time = DateTime.now().add(Duration(hours: index));
                }
              } else {
                time = DateTime.now().add(Duration(hours: index));
              }

              final temp = weather['main']['temp'].round();
              final icon = weather['weather'][0]['icon'];

              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(time),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.network(
                        'http://openweathermap.org/img/wn/$icon@2x.png',
                        width: 32,
                        height: 32,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.wb_sunny,
                            color: Colors.white,
                            size: 32,
                          );
                        },
                      ),
                    ),
                    Text(
                      '${temp}°',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
                  .animate(delay: Duration(milliseconds: index * 100))
                  .fadeIn(duration: 600.ms)
                  .slideX(begin: 0.3);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherDetailsGrid() {
    if (hourlyWeatherData.isEmpty) return Container();

    final currentWeather = hourlyWeatherData[0];
    final feelsLike = currentWeather['main']['feels_like'].round();
    final visibility = currentWeather['visibility'] != null
        ? (currentWeather['visibility'] / 1000).round()
        : 10;
    final clouds = currentWeather['clouds']['all'];
    final pressure = currentWeather['main']['pressure'];
    final humidity = currentWeather['main']['humidity'];
    final windSpeed = (currentWeather['wind']['speed'] * 3.6).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Informations détaillées',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.3),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.2,
            children: [
              WeatherItem(
                value: feelsLike,
                text: 'Ressenti',
                unit: '°C',
                imageUrl: 'assets/max-temp.png',
                animationDelay: 0,
                isGlassmorphism: true,
              ),
              WeatherItem(
                value: humidity,
                text: 'Humidité',
                unit: '%',
                imageUrl: 'assets/humidity.png',
                animationDelay: 100,
                isGlassmorphism: true,
              ),
              WeatherItem(
                value: windSpeed,
                text: 'Vent',
                unit: ' km/h',
                imageUrl: 'assets/windspeed.png',
                animationDelay: 200,
                isGlassmorphism: true,
              ),
              WeatherItem(
                value: pressure,
                text: 'Pression',
                unit: ' hPa',
                imageUrl: 'assets/max-temp.png',
                animationDelay: 300,
                isGlassmorphism: true,
              ),
              WeatherItem(
                value: visibility,
                text: 'Visibilité',
                unit: ' km',
                imageUrl: 'assets/clear.png',
                animationDelay: 400,
                isGlassmorphism: true,
              ),
              WeatherItem(
                value: clouds,
                text: 'Nuages',
                unit: '%',
                imageUrl: 'assets/clouds.png',
                animationDelay: 500,
                isGlassmorphism: true,
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 1000.ms).slideY(begin: 0.4),
      ],
    );
  }
}
