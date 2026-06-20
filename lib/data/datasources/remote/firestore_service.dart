import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/note_model.dart';
import '../../../domain/entities/user.dart';

part 'firestore_service.g.dart';

@Riverpod(keepAlive: true)
FirestoreService firestoreService(FirestoreServiceRef ref) {
  return FirestoreService(FirebaseFirestore.instance);
}

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService(this._firestore);

  // Users
  Future<void> createUserProfile(User user) async {
    await _firestore.collection('users').doc(user.id).set({
      'name': user.name,
      'email': user.email,
    });
  }

  Future<User?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return User(
        id: userId,
        name: doc.data()?['name'] ?? '',
        email: doc.data()?['email'] ?? '',
      );
    }
    return null;
  }

  // Notes
  Stream<List<NoteModel>> getUserNotesStream(String userId) {
    return _firestore
        .collection('notes')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => NoteModel.fromJson(doc.data(), doc.id)).toList();
    });
  }

  Future<void> addNote(NoteModel note) async {
    await _firestore.collection('notes').doc(note.id).set(note.toJson());
  }

  Future<void> updateNote(NoteModel note) async {
    await _firestore.collection('notes').doc(note.id).update({
      'title': note.title,
      'description': note.description,
      'updatedAt': note.updatedAt.toIso8601String(),
    });
  }

  Future<void> deleteNote(String noteId) async {
    await _firestore.collection('notes').doc(noteId).delete();
  }
}
