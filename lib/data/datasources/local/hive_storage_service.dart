import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/note_model.dart';

part 'hive_storage_service.g.dart';

@Riverpod(keepAlive: true)
HiveStorageService hiveStorageService(HiveStorageServiceRef ref) {
  return HiveStorageService();
}

class HiveStorageService {
  static const String _notesBoxName = 'notes_box';
  Box<NoteModel>? _notesBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(NoteModelAdapter());
    _notesBox = await Hive.openBox<NoteModel>(_notesBoxName);
  }

  Future<void> cacheNotes(List<NoteModel> notes) async {
    if (_notesBox == null) return;
    await _notesBox!.clear(); // Clear existing cache
    
    final Map<String, NoteModel> notesMap = {
      for (var note in notes) note.id: note
    };
    
    await _notesBox!.putAll(notesMap);
  }

  List<NoteModel> getCachedNotes() {
    if (_notesBox == null) return [];
    return _notesBox!.values.toList();
  }
  
  Future<void> clearCache() async {
    if (_notesBox != null) {
      await _notesBox!.clear();
    }
  }
}
