import '../entities/note_entity.dart';

abstract interface class NotesRepository {
  Future<void> addNote(NoteEntity note);

  Future<void> updateNote(NoteEntity note);

  Future<void> deleteNote(String id);

  Future<List<NoteEntity>> getNotes();

  Future<void> syncNotes();
}