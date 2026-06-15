import '../../models/note_model.dart';

abstract interface class NotesLocalDataSource {
  Future<void> addNote(NoteModel note);

  Future<void> updateNote(NoteModel note);

  Future<void> deleteNote(String id);

  Future<List<NoteModel>> getNotes();

  Future<void> saveNotes(List<NoteModel> notes);

  Future<void> saveLastSyncTime();
  
  DateTime? getLastSyncTime();
}
