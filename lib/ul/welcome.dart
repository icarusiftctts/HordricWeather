import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/city.dart';
import '../models/constants.dart';
import '../services/location_service.dart';
import 'home.dart';
import 'settings_page.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late AnimationController _searchAnimationController;
  List<City> filteredCities = [];
  List<City> selectedCities = [];
  bool isSearching = false;
  bool isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialiser avec toutes les villes
    filteredCities = City.citiesList.where((city) => !city.isDefault).toList();
    selectedCities = City.getSelectedCities();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    String query = _searchController.text;
    setState(() {
      if (query.isEmpty) {
        filteredCities =
            City.citiesList.where((city) => !city.isDefault).toList();
        isSearching = false;
        _searchAnimationController.reverse();
      } else {
        filteredCities =
            City.searchCities(query).where((city) => !city.isDefault).toList();
        isSearching = true;
        _searchAnimationController.forward();
      }
    });
  }

  void _toggleCitySelection(City city) {
    setState(() {
      city.isSelected = !city.isSelected;
      if (city.isSelected) {
        selectedCities.add(city);
      } else {
        selectedCities.removeWhere((c) => c.city == city.city);
      }
    });
  }

  void _useCurrentLocation() async {
    setState(() {
      isLoadingLocation = true;
    });

    try {
      print('Tentative d\'obtention de la localisation actuelle...');
      
      // Vérifier d'abord les permissions avant d'essayer
      bool hasPermission = await LocationService.checkLocationPermission();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Permissions de localisation requises. Veuillez autoriser l\'accès à votre position dans les paramètres.',
            ),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Paramètres',
              textColor: Colors.white,
              onPressed: () async {
                await LocationService.openAppSettings();
              },
            ),
          ),
        );
        return;
      }

      final locationData = await LocationService.getCurrentLocationWeather();

      if (locationData != null) {
        print('Localisation obtenue avec succès, navigation vers Home...');
        // Naviguer vers la page d'accueil avec les données de géolocalisation
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Home(
              selectedCity: null,
              currentLocationData: locationData,
            ),
          ),
        );
      } else {
        // Afficher un message d'erreur plus spécifique
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Impossible d\'obtenir votre position. Vérifiez que le GPS est activé et réessayez.',
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Paramètres',
              textColor: Colors.white,
              onPressed: () async {
                await LocationService.openLocationSettings();
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('Erreur dans _useCurrentLocation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de géolocalisation: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Constants myConstant = Constants();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: myConstant.primaryColor,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                myConstant.primaryColor,
                myConstant.secondaryColor,
              ],
            ),
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.location_city, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choisir vos villes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${selectedCities.length} ville(s) sélectionnée(s)',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Bouton paramètres
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            icon: Icon(Icons.settings, color: Colors.white, size: 24),
            tooltip: 'Paramètres',
          ),
          if (selectedCities.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${selectedCities.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ).animate().scale(duration: 300.ms),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche moderne
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une ville ou un pays...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: AnimatedBuilder(
                  animation: _searchAnimationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _searchAnimationController.value * 0.5,
                      child: Icon(
                        Icons.search,
                        color: isSearching
                            ? myConstant.primaryColor
                            : Colors.grey[400],
                      ),
                    );
                  },
                ),
                suffixIcon: isSearching
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[400]),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),

          // Bouton Position Actuelle
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: isLoadingLocation ? null : _useCurrentLocation,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        myConstant.primaryColor.withOpacity(0.1),
                        myConstant.secondaryColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: myConstant.primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: myConstant.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.my_location,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Utiliser ma position actuelle',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: myConstant.primaryColor,
                              ),
                            ),
                            Text(
                              'Obtenir la météo de votre localisation',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isLoadingLocation)
                        Container(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              myConstant.primaryColor,
                            ),
                          ),
                        )
                      else
                        Icon(
                          Icons.arrow_forward_ios,
                          color: myConstant.primaryColor,
                          size: 16,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms)
              .slideX(begin: -0.3),

          // Section des villes sélectionnées
          if (selectedCities.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Villes sélectionnées',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: myConstant.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedCities.length,
                      itemBuilder: (context, index) {
                        return _buildSelectedCityChip(selectedCities[index]);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

          // Liste des villes avec recherche
          Expanded(
            child: filteredCities.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: filteredCities.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (BuildContext context, int index) {
                      return _buildCityCard(filteredCities[index], index);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: selectedCities.isNotEmpty
          ? FloatingActionButton.extended(
              backgroundColor: myConstant.primaryColor,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const Home(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: animation.drive(
                          Tween(
                              begin: const Offset(1.0, 0.0), end: Offset.zero),
                        ),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 600),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              label: Text(
                'Continuer',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ).animate().scale(duration: 400.ms).slideY(begin: 1)
          : null,
    );
  }

  Widget _buildSelectedCityChip(City city) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Constants().primaryColor,
            Constants().secondaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Constants().primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                city.city,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                city.country,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _toggleCitySelection(city),
            child: Icon(Icons.close, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCityCard(City city, int index) {
    Constants myConstant = Constants();
    bool isSelected = city.isSelected;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? myConstant.primaryColor : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? myConstant.primaryColor.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: isSelected ? 15 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _toggleCitySelection(city),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icône de sélection animée
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? myConstant.primaryColor
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? myConstant.primaryColor
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),

                const SizedBox(width: 16),

                // Informations de la ville
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city.city,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? myConstant.primaryColor
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.public,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            city.country,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (city.region != null) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.location_city,
                              size: 16,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              city.region!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Drapeau du pays
                if (city.flag != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.2)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      city.flag!,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.2);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune ville trouvée',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez une autre recherche',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }
}
