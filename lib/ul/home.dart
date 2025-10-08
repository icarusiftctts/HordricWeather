import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shimmer/shimmer.dart';
import '../models/city.dart';
import '../models/constants.dart';
import '../services/notification_service.dart';
import '../services/weather_widget_service.dart';
import 'widgets/weather_item.dart';
import 'detail_page.dart';
import 'settings_page.dart';
import 'advice_page.dart';
import 'welcome.dart';

class Home extends StatefulWidget {
  final City? selectedCity;
  final Map<String, dynamic>? currentLocationData;

  const Home({Key? key, this.selectedCity, this.currentLocationData})
      : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  Constants myConstants = Constants();

  // API Keys
  final String weatherApiKey = 'bad77936d76e7ba47074846a8bd704c2';

  // Animation Controllers
  late AnimationController _refreshController;
  late AnimationController _cardController;

  // Weather Data
  int temperature = 0;
  int maxTemp = 0;
  int minTemp = 0;
  String weatherStateName = 'Chargement...';
  int humidity = 0;
  double windSpeed = 0.0;
  int pressure = 0;
  double feelsLike = 0.0;
  int uvIndex = 0;

  String currentDate = DateFormat(
    'EEEE, dd MMMM',
    'fr_FR',
  ).format(DateTime.now());
  String imageUrl = '';
  String location = 'Votre position';

  List<City> selectedCities = [];
  List<Map<String, dynamic>> consolidatedWeatherList = [];
  Map<String, dynamic>? currentWeatherData;

  bool isLoading = true;
  bool isLocationEnabled = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
  }

  void _initializeAnimations() {
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _cardController.forward();
  }

  void _initializeData() async {
    // Si des données de géolocalisation sont fournies, les utiliser directement
    if (widget.currentLocationData != null) {
      await _processLocationWeatherData(widget.currentLocationData!);
      return;
    }

    // Si une ville spécifique est sélectionnée
    if (widget.selectedCity != null) {
      await _fetchWeatherForCity(widget.selectedCity!);
      return;
    }

    // Sinon, utiliser la logique par défaut
    selectedCities = City.getSelectedCities();
    if (selectedCities.isEmpty) {
      // Ajouter Lomé par défaut
      City lome = City.citiesList.firstWhere((city) => city.city == 'Lomé');
      lome.isSelected = true;
      selectedCities.add(lome);
    }

    await _checkLocationPermission();
    await _getCurrentLocationWeather();
  }

  Future<void> _processLocationWeatherData(
    Map<String, dynamic> locationData,
  ) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final weatherData = locationData['weather_data'];
      final cityName = locationData['city_name'];

      setState(() {
        currentWeatherData = weatherData; // Sauvegarder les données météo
        location = cityName ?? 'Position actuelle';
        temperature = weatherData['main']['temp'].round();
        maxTemp = weatherData['main']['temp_max'].round();
        minTemp = weatherData['main']['temp_min'].round();
        humidity = weatherData['main']['humidity'];
        pressure = weatherData['main']['pressure'];
        windSpeed = weatherData['wind']['speed'].toDouble();
        feelsLike = weatherData['main']['feels_like'].toDouble();
        weatherStateName = weatherData['weather'][0]['description'];

        String iconCode = weatherData['weather'][0]['icon'];
        imageUrl = 'http://openweathermap.org/img/wn/$iconCode@2x.png';

        isLoading = false;
      });

      _refreshController.forward();

      // Programmer une notification météo
      await NotificationService.scheduleWeatherNotification(
        cityName ?? 'Position actuelle',
        weatherStateName,
        temperature,
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur lors du traitement des données météo: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchWeatherForCity(City city) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=${city.city}&appid=$weatherApiKey&units=metric&lang=fr',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          location = city.city;
          temperature = data['main']['temp'].round();
          maxTemp = data['main']['temp_max'].round();
          minTemp = data['main']['temp_min'].round();
          humidity = data['main']['humidity'];
          pressure = data['main']['pressure'];
          windSpeed = data['wind']['speed'].toDouble();
          feelsLike = data['main']['feels_like'].toDouble();
          weatherStateName = data['weather'][0]['description'];

          String iconCode = data['weather'][0]['icon'];
          imageUrl = 'http://openweathermap.org/img/wn/$iconCode@2x.png';

          isLoading = false;
        });

        _refreshController.forward();

        // Programmer une notification météo
        await NotificationService.scheduleWeatherNotification(
          city.city,
          weatherStateName,
          temperature,
        );
      } else {
        setState(() {
          errorMessage =
              'Impossible de charger les données météo pour ${city.city}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur réseau: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _checkLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        setState(() {
          isLocationEnabled = true;
        });
      }
    } catch (e) {
      print('Erreur de géolocalisation: $e');
    }
  }

  Future<void> _getCurrentLocationWeather() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      if (isLocationEnabled) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        await _fetchWeatherData(position.latitude, position.longitude);
      } else {
        // Utiliser Lomé par défaut
        await _fetchWeatherData(6.1375, 1.2123);
        setState(() {
          location = 'Lomé, Togo';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur lors du chargement: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchWeatherData(double latitude, double longitude) async {
    try {
      final weatherUrl =
          'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&appid=$weatherApiKey&units=metric&lang=fr';

      final currentWeatherUrl =
          'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$weatherApiKey&units=metric&lang=fr';

      final responses = await Future.wait([
        http.get(Uri.parse(currentWeatherUrl)),
        http.get(Uri.parse(weatherUrl)),
      ]);

      final currentResult = json.decode(responses[0].body);
      final forecastResult = json.decode(responses[1].body);

      if (currentResult['main'] != null) {
        setState(() {
          currentWeatherData =
              currentResult; // Sauvegarder les données météo complètes
          temperature = currentResult['main']['temp'].round();
          maxTemp = currentResult['main']['temp_max'].round();
          minTemp = currentResult['main']['temp_min'].round();
          humidity = currentResult['main']['humidity'];
          pressure = currentResult['main']['pressure'];
          feelsLike = currentResult['main']['feels_like'];
          windSpeed = currentResult['wind']['speed'].toDouble();
          weatherStateName = currentResult['weather'][0]['description'];
          location = currentResult['name'];

          // Déterminer l'icône météo
          String weatherMain =
              currentResult['weather'][0]['main'].toLowerCase();
          imageUrl = _getWeatherImage(weatherMain);

          isLoading = false;
        });

        // Traiter les prévisions
        if (forecastResult['list'] != null) {
          _processForecastData(forecastResult['list']);
        }

        // Vérifier les conditions météo pour les notifications
        NotificationService.checkWeatherConditions(currentResult);

        // Mettre à jour le widget avec les nouvelles données
        WeatherWidgetService.saveLastWeatherData(
          currentResult,
          location,
          latitude,
          longitude,
        );

        // Afficher la notification sur l'écran de verrouillage si activé
        NotificationService.showLockScreenWeatherNotification(currentResult);
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur de connexion réseau';
        isLoading = false;
      });
    }
  }

  void _processForecastData(List forecastList) {
    setState(() {
      consolidatedWeatherList = forecastList
          .take(8)
          .map((item) {
            DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
              item['dt'] * 1000,
            );
            item['applicable_date'] = DateFormat('HH:mm').format(dateTime);
            return item;
          })
          .toList()
          .cast<Map<String, dynamic>>();
    });
  }

  String _getWeatherImage(String weatherMain) {
    switch (weatherMain) {
      case 'clear':
        return 'clear';
      case 'clouds':
        return 'lightcloud';
      case 'rain':
        return 'rain';
      case 'drizzle':
        return 'showers';
      case 'thunderstorm':
        return 'thunderstorm';
      case 'snow':
        return 'snow';
      case 'mist':
      case 'fog':
        return 'lightcloud';
      default:
        return 'clear';
    }
  }

  Future<void> _refreshWeather() async {
    _refreshController.repeat();
    await _getCurrentLocationWeather();
    _refreshController.stop();
    _refreshController.reset();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: isLoading ? _buildLoadingScreen() : _buildMainContent(size),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [myConstants.primaryColor, myConstants.secondaryColor],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.white.withOpacity(0.3),
              highlightColor: Colors.white.withOpacity(0.7),
              child: Icon(Icons.wb_sunny, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              'Chargement des données météo...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(Size size) {
    return Container(
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
          stops: [0.0, 0.4, 0.7, 1.0],
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshWeather,
          color: myConstants.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildMainWeatherCard(size),
                  const SizedBox(height: 30),
                  _buildWeatherDetails(),
                  const SizedBox(height: 30),
                  _buildHourlyForecast(),
                  const SizedBox(height: 30),
                  _buildSelectedCities(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HordricWeather',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.3),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () async {
                    // Permettre de retourner à la localisation actuelle
                    if (location != 'Position actuelle' &&
                        location != 'Lomé, Togo') {
                      await _getCurrentLocationWeather();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('📍 Localisation actuelle mise à jour'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Text(
                    location,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                      decoration: location != 'Position actuelle' &&
                              location != 'Lomé, Togo'
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: _refreshWeather,
              icon: AnimatedBuilder(
                animation: _refreshController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _refreshController.value * 2 * 3.14159,
                    child: Icon(Icons.refresh, color: Colors.white, size: 24),
                  );
                },
              ),
              constraints: BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.all(4),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'detail':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(
                          consolidatedWeatherList: consolidatedWeatherList,
                          location: location,
                        ),
                      ),
                    );
                    break;
                  case 'advice':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdvicePage(
                          weatherData: currentWeatherData,
                          location: location,
                        ),
                      ),
                    );
                    break;
                  case 'settings':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()),
                    );
                    break;
                  case 'cities':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Welcome(),
                      ),
                    );
                    break;
                }
              },
              icon: Icon(Icons.more_vert, color: Colors.white, size: 24),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'detail',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 20),
                      SizedBox(width: 12),
                      Text('Détails'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'advice',
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline, size: 20),
                      SizedBox(width: 12),
                      Text('Conseils'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'cities',
                  child: Row(
                    children: [
                      Icon(Icons.location_city, size: 20),
                      SizedBox(width: 12),
                      Text('Changer de ville'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings_outlined, size: 20),
                      SizedBox(width: 12),
                      Text('Paramètres'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainWeatherCard(Size size) {
    return Container(
      width: size.width,
      padding: const EdgeInsets.all(30),
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
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: -5,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Date avec icône
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Colors.white.withOpacity(0.9),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  currentDate,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.3),

          const SizedBox(height: 25),

          // Icône météo avec effet de pulsation
          if (imageUrl.isNotEmpty)
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
              child: Image.asset(
                'assets/$imageUrl.png',
                width: 100,
                height: 100,
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .scale(
                  duration: 2000.ms,
                  curve: Curves.easeInOut,
                  begin: Offset(1.0, 1.0),
                  end: Offset(1.1, 1.1),
                )
                .then()
                .scale(
                  duration: 2000.ms,
                  curve: Curves.easeInOut,
                  begin: Offset(1.1, 1.1),
                  end: Offset(1.0, 1.0),
                ),

          const SizedBox(height: 25),

          // Température principale avec effet de compteur
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: temperature),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Text(
                    '$value',
                    style: TextStyle(
                      fontSize: 85,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                      height: 0.8,
                    ),
                  );
                },
              ),
              Text(
                '°C',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w300,
                  color: Colors.white.withOpacity(0.8),
                ),
              ).animate().fadeIn(delay: 1000.ms, duration: 600.ms),
            ],
          ),

          const SizedBox(height: 10),

          // Description météo avec animation de machine à écrire
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              weatherStateName.toUpperCase(),
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.95),
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          )
              .animate()
              .fadeIn(delay: 800.ms, duration: 800.ms)
              .slideY(begin: 0.5),

          const SizedBox(height: 20),

          // Min/Max avec amélioration visuelle
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTempInfo(
                  '↗',
                  'Max',
                  maxTemp,
                  Colors.orange.shade300,
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildTempInfo(
                  '↘',
                  'Min',
                  minTemp,
                  Colors.blue.shade300,
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 1200.ms, duration: 600.ms)
              .slideX(begin: 0.3),

          const SizedBox(height: 15),

          // Ressenti
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.thermostat,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Ressenti ${feelsLike.round()}°C',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 1400.ms, duration: 500.ms),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 1000.ms)
        .slideY(begin: 0.3)
        .scaleXY(begin: 0.9);
  }

  Widget _buildTempInfo(String icon, String label, int temp, Color color) {
    return Column(
      children: [
        Text(icon, style: TextStyle(fontSize: 20, color: color)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${temp}°',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.analytics_outlined, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                'Détails météo',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.3),
        const SizedBox(height: 25),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
            children: [
              WeatherItem(
                value: humidity,
                text: 'Humidité',
                unit: '%',
                imageUrl: 'assets/humidity.png',
                animationDelay: 0,
              ),
              WeatherItem(
                value: windSpeed.round(),
                text: 'Vent',
                unit: ' km/h',
                imageUrl: 'assets/windspeed.png',
                animationDelay: 100,
              ),
              WeatherItem(
                value: pressure,
                text: 'Pression',
                unit: ' hPa',
                imageUrl: 'assets/max-temp.png',
                animationDelay: 200,
              ),
              WeatherItem(
                value: feelsLike.round(),
                text: 'Ressenti',
                unit: '°C',
                imageUrl: 'assets/max-temp.png',
                animationDelay: 300,
              ),
              WeatherItem(
                value: uvIndex,
                text: 'UV Index',
                unit: '',
                imageUrl: 'assets/clear.png',
                animationDelay: 400,
              ),
              WeatherItem(
                value: (windSpeed * 3.6).round(),
                text: 'Visibilité',
                unit: ' km',
                imageUrl: 'assets/clear.png',
                animationDelay: 500,
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 1000.ms).slideY(begin: 0.4),
      ],
    );
  }

  Widget _buildHourlyForecast() {
    if (consolidatedWeatherList.isEmpty) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prévisions horaires',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ).animate().fadeIn(duration: 800.ms),
        const SizedBox(height: 20),
        Container(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: consolidatedWeatherList.length,
            itemBuilder: (context, index) {
              var forecast = consolidatedWeatherList[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 15),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      forecast['applicable_date'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Image.asset(
                      'assets/${_getWeatherImage(forecast['weather'][0]['main'].toLowerCase())}.png',
                      width: 32,
                      height: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${forecast['main']['temp'].round()}°',
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

  Widget _buildSelectedCities() {
    if (selectedCities.isEmpty) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vos villes',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ).animate().fadeIn(duration: 800.ms),
        const SizedBox(height: 20),
        ...selectedCities
            .take(3)
            .map((city) => _buildCityWeatherCard(city))
            .toList(),
      ],
    );
  }

  Widget _buildCityWeatherCard(City city) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                city.city,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                city.country,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Image.asset('assets/clear.png', width: 32, height: 32),
              const SizedBox(width: 10),
              Text(
                '22°',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.3);
  }
}
