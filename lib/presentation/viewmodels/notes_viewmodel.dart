import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/note.dart';
import '../../data/repositories_impl/note_repository_impl.dart';
import 'auth_viewmodel.dart';
import 'package:uuid/uuid.dart';

part 'notes_viewmodel.g.dart';

@riverpod
class NotesViewModel extends _$NotesViewModel {
  @override
  Stream<List<Note>> build() {
    final userAsync = ref.watch(authViewModelProvider);
    return userAsync.when(
      data: (user) {
        if (user == null) return const Stream.empty();
        return ref.watch(noteRepositoryProvider).getUserNotesStream(user.id);
      },
      loading: () => const Stream.empty(),
      error: (_, __) => const Stream.empty(),
    );
  }

  Future<void> addNote(String title, String description) async {
    final user = ref.read(authViewModelProvider).value;
    if (user == null) return;

    final note = Note(
      id: const Uuid().v4(),
      userId: user.id,
      title: title,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(noteRepositoryProvider).addNote(note);
  }

  Future<void> updateNote(Note note, String newTitle, String newDescription) async {
    final updatedNote = note.copyWith(
      title: newTitle,
      description: newDescription,
      updatedAt: DateTime.now(),
    );
    await ref.read(noteRepositoryProvider).updateNote(updatedNote);
  }

  Future<void> deleteNote(String noteId) async {
    await ref.read(noteRepositoryProvider).deleteNote(noteId);
  }
}
