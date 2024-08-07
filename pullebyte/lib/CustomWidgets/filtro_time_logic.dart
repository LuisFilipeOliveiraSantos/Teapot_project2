import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pullebyte/theme/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FiltroTimeLogic {
  final List<Map<String, dynamic>> timesSelecionados = [];

  void adicionarTime(String nome, String escudoUrl, BuildContext context) {
    bool timeJaSelecionado =
        timesSelecionados.any((time) => time['nome'] == nome);
    if (!timeJaSelecionado) {
      timesSelecionados.add({
        'nome': nome,
        'escudoUrl': escudoUrl,
        'selecionado': false,
      });
      _salvarFiltrosNoFirestore();
    } else {
      Fluttertoast.showToast(
        webBgColor: CustomColors.buttonColor,
        msg: 'O time $nome já foi selecionado.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 4,
        backgroundColor: CustomColors.buttonColor,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void alternarSelecao(int index) {
    if (index >= 0 && index < timesSelecionados.length) {
      timesSelecionados[index]['selecionado'] =
          !timesSelecionados[index]['selecionado'];
      _salvarFiltrosNoFirestore();
    }
  }

  void excluirTime(int index) {
    if (index >= 0 && index < timesSelecionados.length) {
      timesSelecionados.removeAt(index);
      _salvarFiltrosNoFirestore();
    }
  }
  
  Future<void> _salvarFiltrosNoFirestore() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (timesSelecionados.isEmpty) {
        return await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'timesSelecionados': []});
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'timesSelecionados': timesSelecionados});
    }
  } catch (e) {
    print('Erro ao salvar filtros no Firestore: $e');
  }
}

Future<void> carregarFiltrosDoFirestore() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('timesSelecionados')) {
          List<dynamic> times = data['timesSelecionados'];
          timesSelecionados.clear();
          timesSelecionados.addAll(times.map((item) => Map<String, dynamic>.from(item)));
        } else {
          // Se o campo não existir, inicialize-o como uma lista vazia
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'timesSelecionados': [],
          });
          timesSelecionados.clear();
        }
      }
    }
  } catch (e) {
    print('Erro ao carregar filtros do Firestore: $e');
  }
}
}