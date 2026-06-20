import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/repositories/note_repository.dart';
import '../datasources/remote/firestore_service.dart';
import '../datasources/local/hive_storage_service.dart';
import '../models/note_model.dart';

part 'note_repository_impl.g.dart';

@riverpod
NoteRepository noteRepository(NoteRepositoryRef ref) {
  return NoteRepositoryImpl(
    ref.watch(firestoreServiceProvider),
    ref.watch(hiveStorageServiceProvider),
  );
}

class NoteRepositoryImpl implements NoteRepository {
  final FirestoreService _firestoreService;
  final HiveStorageService _hiveStorage;

  NoteRepositoryImpl(this._firestoreService, this._hiveStorage);

  @override
  Stream<List<Note>> getUserNotesStream(String userId) {
    return _firestoreService.getUserNotesStream(userId).map((noteModels) {
      // Cache notes locally whenever they update
      _hiveStorage.cacheNotes(noteModels);
      return noteModels.map((model) => model.toEntity()).toList();
    }).handleError((error) {
      // Fallback to local cache if network fails (basic offline support)
      final cached = _hiveStorage.getCachedNotes();
      return cached.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<Either<String, void>> addNote(Note note) async {
    try {
      final model = NoteModel.fromEntity(note);
      await _firestoreService.addNote(model);
      return const Right(null);
    } catch (e) {
      return Left('Failed to add note: $e');
    }
  }

  @override
  Future<Either<String, void>> updateNote(Note note) async {
    try {
      final model = NoteModel.fromEntity(note);
      await _firestoreService.updateNote(model);
      return const Right(null);
    } catch (e) {
      return Left('Failed to update note: $e');
    }
  }

  @override
  Future<Either<String, void>> deleteNote(String noteId) async {
    try {
      await _firestoreService.deleteNote(noteId);
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete note: $e');
    }
  }
}
