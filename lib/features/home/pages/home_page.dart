import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hordricweather/widgets/custom_snackbar.dart'; // ✅ added
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/weather_widget_service.dart';
import '../../../shared/services/background_service.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isRefreshing = false;

  Future<void> _refreshWeather() async {
    setState(() => _isRefreshing = true);
    try {
      // Simulate your weather refresh logic here
      await Future.delayed(const Duration(seconds: 1));

      // ✅ Show the custom floating SnackBar instead of default one
      showCustomSnackBar(context, 'Weather updated successfully!');
    } catch (e) {
      showCustomSnackBar(
        context,
        'Failed to refresh weather data',
        isError: true,
      );
    } finally {
      setState(() => _isRefreshing = false);
    }
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
                child: RefreshIndicator(
                  onRefresh: _refreshWeather,
                  color: AppTheme.textOnPrimary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppTheme.spacingXL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppTheme.spacingXL),
                        const Text(
                          'Welcome to HordricWeather',
                          style: TextStyle(
                            color: AppTheme.textOnPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),
                        const SizedBox(height: AppTheme.spacingXL),
                        ElevatedButton.icon(
                          onPressed: _refreshWeather,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh Weather'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.overlay20,
                            foregroundColor: AppTheme.textOnPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
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
              onPressed: () {
                // Example button: show floating SnackBar when pressed
                showCustomSnackBar(context, 'Home button pressed!');
              },
              icon: const Icon(
                Icons.home,
                color: AppTheme.textOnPrimary,
                size: AppTheme.iconSizeM,
              ),
            ),
          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3),
          const SizedBox(width: AppTheme.spacingXL),
          const Text(
            'HordricWeather',
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
}
