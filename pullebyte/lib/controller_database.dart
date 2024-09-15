import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class DatabaseController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String defaultProfilePictureUrl = 'https://i.yourimageshare.com/uuzM2gyY18.png';

  getUserProfile() {
    var user = _auth.currentUser;
    return user;
  }

  Future<void> updateProfilePicture(File filePath) async {
    var user = _auth.currentUser;

    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    final filename = path.basename(filePath.path);
    final ref = _storage.ref().child('users/${user.uid}/$filename');

    // Obter a URL da imagem
    await ref.putFile(filePath).catchError((e) {
      print('Erro ao enviar imagem para o Firebase Storage: $e');
    });

    try {
      var url = await ref.getDownloadURL();
      await user.updatePhotoURL(url);
    } catch (e) {
      throw Exception('Erro ao obter URL da imagem: $e');
    }
  }

  Future<void> updateUserName(String name) async {
    var user = _auth.currentUser;
    try {
      if (user?.displayName != name) {
        await user?.updateDisplayName(name);
        await _firestore.collection('filtros').doc(user?.uid).update({
          'userInfo.name': user?.displayName,
        });
        const SnackBar(
          content: Text('Informações atualizadas com sucesso'),
        );
      }
    } catch (e) {
      throw Exception('Erro ao atualizar nome do usuário: $e');
    }
  }

  Future<void> updateUserEmail(String email) async {
    var user = _auth.currentUser;

    try {
      if (user?.email != email) {
        await user?.verifyBeforeUpdateEmail(email);
        await _firestore.collection('filtros').doc(user?.uid).update({
          'userInfo.email': user?.email,
        });
        const SnackBar(
          content: Text('Verifique seu e-mail para confirmar a alteração'),
        );
      }
    } catch (e) {
      throw Exception('Erro ao atualizar email do usuário: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> addUserInfo() async {
    try {
      var user = _auth.currentUser;
      DocumentSnapshot snapshot = await _firestore.collection('filtros').doc(user?.uid).get();
      if (!snapshot.exists) {
        await _firestore.collection('filtros').doc(user?.uid).set({
          'userInfo': {
            'name': user?.displayName,
            'email': user?.email,
            'createdAt': FieldValue.serverTimestamp(),
          },
          'timesSelecionados': [],
        });
      } else {
        throw Exception('Usuário já existe no Firestore');
      }
    } catch (e) {
      throw Exception('Erro ao adicionar usuário: $e');
    }
  }

    Future<void> resetPassword() async {
    var user = _auth.currentUser;

    try {
      await _auth.sendPasswordResetEmail(email: user!.email!);
    } catch (e) {
      throw Exception('Erro ao redefinir senha: $e');
    }
  }

  Future<void> resetPasswordWithEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Erro ao redefinir senha: $e');
    }
  }

  //metodo para login
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception('Erro ao realizar login: $e');
    }
  }

  // Método para cadastro
  Future<void> registerWithEmailAndPassword(String email, String password, String username) async {
    UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    // Adicione o nome de usuário ao perfil do usuário
    await result.user?.updateDisplayName(username).catchError((e) {
      throw Exception('Erro ao atualizar nome de usuário: $e');
    });
  }
}
