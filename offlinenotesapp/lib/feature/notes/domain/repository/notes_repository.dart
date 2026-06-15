import '../entities/conflict_entity.dart';
import '../entities/note_entity.dart';

abstract interface class NotesRepository {
  Future<void> addNote(NoteEntity note);

  Future<void> updateNote(NoteEntity note);

  Future<void> deleteNote(String id);

  Future<List<NoteEntity>> getNotes();

  Future<ConflictEntity?> syncNotes();

  Future<(NoteEntity, NoteEntity)?> checkConflict();

  Future<void> useLocalVersion(NoteEntity localNote);

  Future<void> useServerVersion(NoteEntity serverNote);

  DateTime? getLastSyncTime();
}
