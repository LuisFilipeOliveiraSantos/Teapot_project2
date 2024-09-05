import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pullebyte/CustomWidgets/bar_chart.dart';
import 'package:pullebyte/CustomWidgets/line_chart.dart';
import 'package:pullebyte/controller_canhotos.dart';

class GraficoInsight extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final canhotosList = context.watch<CanhotosController>().canhotosList;
    final filteredCanhotos = _filterCanhotos(canhotosList);
    final lucroValues = _calculateLucro(filteredCanhotos);

    final barChartData = _generateBarChartData(lucroValues);
    final ganhouData = _generateLineChartData(filteredCanhotos, 'Ganhou');
    final perdeuData = _generateLineChartData(filteredCanhotos, 'Perdeu');

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                LineChartWidget(ganhouData: ganhouData, perdeuData: perdeuData),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: BarChartWidget(
              barChartData: barChartData,
              titles: lucroValues.keys.toList(), legends: {'Ganhos': Colors.green[300]!, 'Perdas': Colors.pinkAccent[400]!},
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filterCanhotos(
      List<Map<String, dynamic>> canhotosList) {
    return canhotosList.where((canhoto) {
      return canhoto['pulleStatus'] == 'Ganhou' ||
          canhoto['pulleStatus'] == 'Perdeu';
    }).toList();
  }

  Map<String, double> _calculateLucro(List<Map<String, dynamic>> canhotos) {
    final Map<String, double> lucroValues = {};
    for (var canhoto in canhotos) {
      final title = canhoto['pulleTitle'];
      final value = (canhoto['pulleValue'] as num).toDouble();
      if (!lucroValues.containsKey(title)) {
        lucroValues[title] = 0.0;
      }
      lucroValues[title] = canhoto['pulleStatus'] == 'Ganhou'
          ? lucroValues[title]! + value
          : lucroValues[title]! - value;
    }
    return lucroValues;
  }

  List<BarChartGroupData> _generateBarChartData(
      Map<String, double> lucroValues) {
    return lucroValues.entries.map((entry) {
      return BarChartGroupData(
        x: lucroValues.keys.toList().indexOf(entry.key),
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: entry.value >= 0 ? Colors.green[300]! : Colors.pinkAccent[400]!,
            width: 20,
          ),
        ],
      );
    }).toList();
  }

  List<ChartData> _generateLineChartData(
      List<Map<String, dynamic>> canhotos, String status) {
    final Map<String, List<double>> values = {};
    for (var canhoto in canhotos) {
      if (canhoto['pulleStatus'] == status) {
        final title = canhoto['pulleTitle'];
        final value = (canhoto['pulleValue'] as num).toDouble();
        values.putIfAbsent(title, () => []).add(value);
      }
    }
    return values.entries.map((entry) {
      final averageValue =
          entry.value.reduce((a, b) => a + b) / entry.value.length;
      return ChartData(title: entry.key, averageValue: averageValue);
    }).toList();
  }
}

class ChartData {
  final String title;
  final double averageValue;

  ChartData({required this.title, required this.averageValue});
}
