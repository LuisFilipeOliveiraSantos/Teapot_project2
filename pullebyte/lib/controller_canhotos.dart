import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

const uuid = Uuid();
final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseStorage _storage = FirebaseStorage.instance;

class Canhoto {
  String? pulleTitulo;
  DateTime? pulleData;
  double? pulleValor;
  String? pulleTimeEscolhido;
  String? pulleTimeEscolhidoID;
  String? pulleStatus;
  String? pulleImagem = 'https://via.placeholder.com/150';

  Canhoto({
    this.pulleTitulo,
    this.pulleData,
    this.pulleValor,
    this.pulleTimeEscolhido,
    this.pulleTimeEscolhidoID,
    this.pulleStatus,
    this.pulleImagem,
  });
}

class CanhotosRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> saveCanhotos(List<Map<String, dynamic>> canhotosList) async {
    try {
      User? user = auth.currentUser;
      if (user != null) {
        final docRef = firestore.collection('canhotos').doc(user.uid);
        await docRef.set({'canhotosCadastrados': canhotosList}, SetOptions(merge: true));
      }
    } catch (e) {
      throw Exception('Erro ao salvar canhotos no Firestore: $e');
    }
  }

  Future<List<Map<String, dynamic>>> loadCanhotos() async {
    try {
      User? user = auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await firestore.collection('canhotos').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('canhotosCadastrados')) {
            return List<Map<String, dynamic>>.from(data['canhotosCadastrados']);
          } else {
            await firestore.collection('canhotos').doc(user.uid).update({'canhotosCadastrados': []});
            return [];
          }
        }
      }
      return [];
    } catch (e) {
      throw Exception('Erro ao carregar canhotos do Firestore: $e');
    }
  }
}

class CanhotosController extends ChangeNotifier {
  final CanhotosRepository repository = CanhotosRepository();
  List<Map<String, dynamic>> canhotosList = [];

  Future<void> addCanhoto({
    required String pulleID,
    required String pulleTitulo,
    required Timestamp pulleData,
    required double pulleValor,
    required String pulleTimeEscolhido,
    required String pulleTimeEscolhidoID,
    String? pulleStatus,
    String? pulleImagem,
  }) async {
    canhotosList.add({
      'id': pulleID,
      'pulleTitle': pulleTitulo,
      'pulleDate': pulleData,
      'pulleValue': pulleValor,
      'pulleChosenTeam': pulleTimeEscolhido,
      'pulleChosenTeamID': pulleTimeEscolhidoID,
      'pulleStatus': pulleStatus,
      'pulleImage': pulleImagem,
    });
    await repository.saveCanhotos(canhotosList);
    notifyListeners();
  }

  Future<String> updateCanhotoPicture(File filePath, String canhotoId) async {
    var user = _auth.currentUser;

    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    final filename = path.basename(filePath.path);
    final ref = _storage.ref().child('canhotos/${user.uid}/$canhotoId/$filename');

    // Obter a URL da imagem
    await ref.putFile(filePath).catchError((e) {
      throw Exception('Erro ao enviar imagem para o Firebase Storage: $e');
    });

    try {
      var url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      throw Exception('Erro ao obter URL da imagem: $e');
    }
  }

  Future<void> carregarFiltrosDoFirestore() async {
    try {
      canhotosList = await repository.loadCanhotos();
      notifyListeners();
    } catch (e) {
      throw Exception('Erro ao carregar filtros do Firestore: $e');
    }
  }

  void deleteCanhoto(String id) {
    canhotosList.removeWhere((canhoto) => canhoto['id'] == id);
    notifyListeners();
    repository.saveCanhotos(canhotosList);
  }

  void editCanhoto(String id, Map<String, dynamic> data) {
    int index = canhotosList.indexWhere((canhoto) => canhoto['id'] == id);

    if (index != -1) {
      canhotosList[index] = {
        'id': id,
        'pulleTitle': data['pulleTitle'] ?? canhotosList[index]['pulleTitle'],
        'pulleDate': data['pulleDate'] ?? canhotosList[index]['pulleDate'],
        'pulleValue': data['pulleValue'] ?? canhotosList[index]['pulleValue'],
        'pulleChosenTeam': data['pulleChosenTeam'] ?? canhotosList[index]['pulleChosenTeam'],
        'pulleChosenTeamID': data['pulleChosenTeamID'] ?? canhotosList[index]['pulleChosenTeamID'],
        'pulleStatus': data['pulleStatus'] ?? canhotosList[index]['pulleStatus'],
        'pulleImage': data['pulleImage'] ?? canhotosList[index]['pulleImage'],
      };

      notifyListeners();
      repository.saveCanhotos(canhotosList);
    } else {
      throw Exception('Canhoto com ID $id não encontrado');
    }
  }
}
