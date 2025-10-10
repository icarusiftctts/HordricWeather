import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../pages/weather_charts_page.dart';

class MiniChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> forecastData;
  final String location;
  final Map<String, dynamic>? currentWeatherData;

  const MiniChartWidget({
    Key? key,
    required this.forecastData,
    required this.location,
    this.currentWeatherData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeatherChartsPage(
              forecastData: forecastData,
              location: location,
              currentWeatherData: currentWeatherData,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade400,
                            Colors.purple.shade400,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.analytics_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Graphiques météo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Voir',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withOpacity(0.9),
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: _buildMiniTemperatureChart(),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildChartIndicator(
                  'Température',
                  Icons.thermostat,
                  Colors.orange.shade400,
                ),
                _buildChartIndicator(
                  'Précipitations',
                  Icons.water_drop,
                  Colors.blue.shade400,
                ),
                _buildChartIndicator(
                  'Humidité',
                  Icons.opacity,
                  Colors.teal.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 1600.ms, duration: 800.ms).slideY(begin: 0.3);
  }

  Widget _buildMiniTemperatureChart() {
    if (forecastData.isEmpty) {
      return Center(
        child: Text(
          'Aucune donnée disponible',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      );
    }

    List<FlSpot> temperatureSpots = [];
    
    for (int i = 0; i < forecastData.length && i < 6; i++) {
      final item = forecastData[i];
      final temp = item['main']['temp'].toDouble();
      temperatureSpots.add(FlSpot(i.toDouble(), temp));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 25,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < forecastData.length) {
                  final item = forecastData[value.toInt()];
                  return Text(
                    item['applicable_date'] ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: temperatureSpots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                Colors.orange.shade300,
                Colors.red.shade400,
              ],
            ),
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: Colors.white,
                  strokeWidth: 1.5,
                  strokeColor: Colors.orange.shade400,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade400.withOpacity(0.3),
                  Colors.red.shade400.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(enabled: false),
      ),
    );
  }

  Widget _buildChartIndicator(String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
