import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Adicionar reunião
  Future<void> addMeeting(
      String nome, String resumo, String horario, DateTime data) async {
    try {
      await _firestore.collection('reunioes').add({
        'nome': nome,
        'resumo': resumo,
        'horario': horario,
        'data': data,
      });
    } catch (e) {
      print('Erro ao adicionar reunião: $e');
    }
  }

  // Obter reuniões / lista de mapas
  Stream<List<Map<String, dynamic>>> getMeetings() {
    return _firestore.collection('reunioes').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return { 
          'id': doc.id,
          'nome': doc['nome'],
          'resumo': doc['resumo'],
          'horario': doc['horario'],
          'data': doc['data'].toDate(),
        };
      }).toList();
    });
  }

  // Obter nomes das reuniões como uma lista de strings
  Stream<List<String>> getMeetingNames() {
    return _firestore.collection('reunioes').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc['nome'] as String).toList();
    });
  }

  // Obter reunião pelo ID
  Future<DocumentSnapshot> getMeetingById(String id) async {
    return await _firestore.collection('reunioes').doc(id).get();
  }

  // Atualizar reunião
  Future<void> updateMeeting(String id, String nome, String resumo,
      String horario, DateTime data) async {
    try {
      await _firestore.collection('reunioes').doc(id).update({
        'nome': nome,
        'resumo': resumo,
        'horario': horario,
        'data': data,
      });
    } catch (e) {
      print('Erro ao atualizar reunião: $e');
    }
  }

  // Deletar reunião
  Future<void> deleteMeeting(String id) async {
    try {
      await _firestore.collection('reunioes').doc(id).delete();
    } catch (e) {
      print('Erro ao deletar reunião: $e');
    }
  }
}
