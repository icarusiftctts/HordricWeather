import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../home/widgets/weather_item.dart';
import '../../onboarding/pages/welcome_page.dart';
import 'package:hordricweather/widgets/custom_snackbar.dart'; // ✅ Added import

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
  String weatherStateName = 'Loading...';

  @override
  void initState() {
    super.initState();
    hourlyWeatherData = widget.consolidatedWeatherList;

    if (hourlyWeatherData.isNotEmpty) {
      DateTime now = DateTime.now();
      int selectedIndex = 0;

      // Find the closest or current hour index
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
      // ✅ Show floating custom SnackBar if no data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showCustomSnackBar(
          context,
          'No weather data available. Check your internet connection.',
          isError: true,
        );
      });
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E3192),
              Color(0xFF1BCEDF),
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
        title: const Text('Weather Details'),
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
              'No data available',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Please check your internet connection',
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
          const Text(
            'Weather Details',
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
          widget.location ?? 'Unknown Location',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.3),
        const SizedBox(height: 8),
        Text(
          DateFormat('EEEE d MMMM yyyy').format(DateTime.now()),
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
                  style: const TextStyle(
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

  // (The rest of your existing _buildHourlyForecastSection and _buildWeatherDetailsGrid methods stay the same)
}
