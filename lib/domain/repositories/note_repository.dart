import 'package:fpdart/fpdart.dart';
import '../entities/note.dart';

abstract class NoteRepository {
  Stream<List<Note>> getUserNotesStream(String userId);
  Future<Either<String, void>> addNote(Note note);
  Future<Either<String, void>> updateNote(Note note);
  Future<Either<String, void>> deleteNote(String noteId);
}
