import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pullebyte/CustomWidgets/insghts_card.dart';
import 'package:pullebyte/controller_canhotos.dart';

class InsightCardHolder extends StatelessWidget {
  final bool isLoading;

  const InsightCardHolder({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final canhotosList = context.watch<CanhotosController>().canhotosList;

    final filteredCanhotos = canhotosList.where((canhoto) {
      return canhoto['pulleStatus'] == 'Ganhou' ||
          canhoto['pulleStatus'] == 'Perdeu';
    }).toList();

    final totalGanhou = filteredCanhotos
        .where((canhoto) => canhoto['pulleStatus'] == 'Ganhou')
        .length;
    final totalPerdeu = filteredCanhotos
        .where((canhoto) => canhoto['pulleStatus'] == 'Perdeu')
        .length;

    final lucroAcumulado = filteredCanhotos.fold(0.0, (soma, canhoto) {
      return canhoto['pulleStatus'] == 'Ganhou'
          ? soma + (canhoto['pulleValue'] as num).toDouble()
          : soma - (canhoto['pulleValue'] as num).toDouble();
    });

    final perdasAcumuladas = filteredCanhotos.fold(0.0, (soma, canhoto) {
      return canhoto['pulleStatus'] == 'Perdeu'
          ? soma + (canhoto['pulleValue'] as num).toDouble()
          : soma;
    });

    final cotacaoMedia = filteredCanhotos.isNotEmpty
        ? filteredCanhotos.fold(
                0.0,
                (soma, canhoto) =>
                    soma + (canhoto['pulleValue'] as num).toDouble()) /
            filteredCanhotos.length
        : 0.0;

    final maiorCotacaoGanha = filteredCanhotos
        .where((canhoto) => canhoto['pulleStatus'] == 'Ganhou')
        .fold<double>(
            0.0,
            (max, canhoto) => (canhoto['pulleValue'] as num).toDouble() > max
                ? (canhoto['pulleValue'] as num).toDouble()
                : max);

    final formatter = NumberFormat.simpleCurrency(
      locale: 'pt_BR',
      decimalDigits: 2,
    );

    final List<Map<String, String>> insightsData = [
      {
        'titulo': 'Pulles\nbatidas',
        'conteudo': '$totalGanhou/${totalPerdeu + totalGanhou}',
      },
      {
        'titulo': 'Lucro\nacumulado',
        'conteudo': formatter.format(lucroAcumulado),
      },
      {
        'titulo': 'Cotação\nmédia',
        'conteudo': formatter.format(cotacaoMedia),
      },
      {
        'titulo': 'Perdas\nacumuladas',
        'conteudo': formatter.format(perdasAcumuladas),
      },
      {
        'titulo': 'Maior cotação\nganha',
        'conteudo': formatter.format(maiorCotacaoGanha),
      },
    ];

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Estatísticas dos\ncanhotos",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 2),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 220,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: insightsData.map((data) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: InsghtsCard(
                                titulo: data['titulo']!,
                                conteudo: data['conteudo']!,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
