import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:pullebyte/theme/colors.dart';

class UniquePoint {
  final String label;
  final double value;
  final bool isVictory;

  UniquePoint({
    required this.label,
    required this.value,
    required this.isVictory,
  });
}

class UniqueLineChart extends StatelessWidget {
  final List<UniquePoint> dataPoints;
  final String title;

  UniqueLineChart({required this.dataPoints, required this.title});

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = _calculateAccumulatedValues();

    double minY = spots.isNotEmpty ? spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b) : 0;
    double maxY = spots.isNotEmpty ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) : 0;

    return Card(
      color: customColorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            Text(
              title, 
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: customColorScheme.onPrimary,
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 400,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          final dataPoint = dataPoints[spot.x.toInt()];
                          return LineTooltipItem(
                            '${dataPoint.label}\nValor: R\$ ${spot.y.toStringAsFixed(2)}',
                            const TextStyle(color: Colors.white),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        reservedSize: 50,
                        showTitles: true,
                        getTitlesWidget: (value, titleMeta) {
                          return SideTitleWidget(
                            axisSide: titleMeta.axisSide,
                            child: Text(
                              _formatYAxis(value),
                              style: TextStyle(
                                color: customColorScheme.onPrimary,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: customColorScheme.onSecondary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) {
                          final point = dataPoints[index];
                          return FlDotCirclePainter(
                            radius: 4,
                            color: point.isVictory ? Colors.green : Colors.red,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.orange.withOpacity(0.3),
                      ),
                    ),
                  ],
                  minY: minY - ((maxY - minY) * 0.1), // Ajuste o valor mínimo do eixo Y
                  maxY: maxY + ((maxY - minY) * 0.1), // Ajuste o valor máximo do eixo Y
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend(color: Colors.green[300]!, text: 'Vitória'),
                SizedBox(width: 10),
                _buildLegend(color: Colors.pinkAccent[400]!, text: 'Derrota'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _calculateAccumulatedValues() {
    double accumulatedValue = 0;
    List<FlSpot> spots = [];

    for (int i = 0; i < dataPoints.length; i++) {
      final point = dataPoints[i];
      accumulatedValue += point.isVictory ? point.value : -point.value;
      spots.add(FlSpot(i.toDouble(), accumulatedValue));
    }

    return spots;
  }


  String _formatYAxis(double value) {
    final formatter = NumberFormat('#,##0');
    return formatter.format(value.toInt());
  }

  Widget _buildLegend({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 16, 
          height: 16, 
          decoration: BoxDecoration(
            color: color,
          ),
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12, 
            color: customColorScheme.onPrimary,
          ),
        ),
      ],
    );
  }
}
