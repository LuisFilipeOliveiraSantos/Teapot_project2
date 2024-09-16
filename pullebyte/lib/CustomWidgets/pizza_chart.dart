import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatelessWidget {
  final double porcentagemVencedoras;
  final double porcentagemPerdedoras;
  final Color surfaceColor;

  const PieChartWidget({
    Key? key,
    required this.porcentagemVencedoras,
    required this.porcentagemPerdedoras,
    required this.surfaceColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Apostas vencedoras x perdedoras',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1.1,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 0,
                  sections: [
                    PieChartSectionData(
                      color: Colors.purple,
                      value: porcentagemVencedoras,
                      title: '${porcentagemVencedoras.toStringAsFixed(1)}%',
                      radius: 125,
                      titleStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.orange,
                      value: porcentagemPerdedoras,
                      title: '${porcentagemPerdedoras.toStringAsFixed(1)}%',
                      radius: 125,
                      titleStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Indicator(
                  color: Colors.purple,
                  text: 'Vencedoras',
                  isSquare: true,
                  size: 15, 
                  fontSize: 13, 
                  spacing: 8, 
                ),
                SizedBox(width: 10),
                Indicator(
                  color: Colors.orange,
                  text: 'Perdedoras',
                  isSquare: true,
                  size: 15, 
                  fontSize: 13, 
                  spacing: 8, 
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size; // Novo parâmetro para o tamanho do ícone
  final double fontSize; // Novo parâmetro para o tamanho do texto
  final double spacing; // Novo parâmetro para espaçamento entre ícone e texto

  const Indicator({
    Key? key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16, // Valor padrão de tamanho
    this.fontSize = 16, // Valor padrão do tamanho do texto
    this.spacing = 4, // Valor padrão de espaçamento
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: size, // Usa o novo parâmetro para definir o tamanho
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        SizedBox(width: spacing), // Usa o novo parâmetro para o espaçamento
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize, // Usa o novo parâmetro para o tamanho do texto
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
