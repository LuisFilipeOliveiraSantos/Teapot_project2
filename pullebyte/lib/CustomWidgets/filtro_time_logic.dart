import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class FiltroTimeLogic extends ChangeNotifier {
  final List<Map<String, dynamic>> timesSelecionados = [];
  List timesSelecionadosCheck = [];
  List<dynamic> timesSelecionadosFiltrados = [];
  List<dynamic> matchesData = [];

  void _filtrarMatches() {
    // Se nenhum time estiver selecionado, exibe todos os jogos
    if (timesSelecionadosCheck.isEmpty) {
      timesSelecionadosFiltrados = matchesData;
    } else {
      // Caso contrário, filtra os jogos com base nos times selecionados
      timesSelecionadosFiltrados = matchesData.where((campeonato) {
        List<dynamic> partidas = campeonato['partidas'];
        return partidas.any((partida) {
          return timesSelecionadosCheck.any((time) {
            return partida['EquipeMand'] == time['nome'] || partida['EquipeAdv'] == time['nome'];
          });
        });
      }).toList();
    }
    notifyListeners(); // Atualiza a interface após filtrar
  }

  Future<void> fetchMatchData() async {
    const url = 'https://pullebyte.onrender.com/matches-data';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      matchesData = json.decode(utf8.decode(response.bodyBytes))['campeonatos'];
      _filtrarMatches(); // Aplica a filtragem inicial após carregar os dados
    } else {
      // Trate o erro de carregamento de dados, se necessário
      matchesData = [];
      timesSelecionadosFiltrados = [];
    }
    notifyListeners(); // Atualiza a interface após carregar os dados
  }

  void adicionarTime(String nome, String escudoUrl, BuildContext context) {
    bool timeJaSelecionado = timesSelecionados.any((time) => time['nome'] == nome);
    if (!timeJaSelecionado) {
      timesSelecionados.add({
        'nome': nome,
        'escudoUrl': escudoUrl,
        'selecionado': false,
      });
      _salvarFiltrosNoFirestore();
    }
  }

  void alternarSelecao(int index) {
    if (index >= 0 && index < timesSelecionados.length) {
      timesSelecionados[index]['selecionado'] = !timesSelecionados[index]['selecionado'];
      timesChecked();
      _filtrarMatches(); // Atualiza a filtragem após alterar a seleção
      _salvarFiltrosNoFirestore();
      notifyListeners();
    }
  }

  void timesChecked() {
    timesSelecionadosCheck = timesSelecionados.where((time) => time['selecionado'] == true).toList();
    _filtrarMatches(); // Aplica a filtragem após atualizar a lista de times selecionados
    notifyListeners();
  }

  void excluirTime(int index) {
    if (index >= 0 && index < timesSelecionados.length) {
      timesSelecionados.removeAt(index);
      _salvarFiltrosNoFirestore();
      timesChecked(); // Atualiza a filtragem após remover um time
    }
  }

  Future<void> _salvarFiltrosNoFirestore() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('filtros').doc(user.uid).update({'timesSelecionados': timesSelecionados});
      }
    } catch (e) {
      throw Exception('Erro ao salvar filtros no Firestore: $e');
    }
    notifyListeners();
  }

  Future<void> carregarFiltrosDoFirestore() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('filtros').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('timesSelecionados')) {
            List<dynamic> times = data['timesSelecionados'];
            timesSelecionados.clear();
            timesSelecionados.addAll(times.map((item) => Map<String, dynamic>.from(item)));
            timesChecked(); // Atualiza a lista de times selecionados após carregar do Firestore
            _filtrarMatches(); // Filtra os jogos com base nos filtros carregados
          }
        }
      }
    } catch (e) {
      throw Exception('Erro ao carregar filtros do Firestore: $e');
    }
    notifyListeners();
  }
}
