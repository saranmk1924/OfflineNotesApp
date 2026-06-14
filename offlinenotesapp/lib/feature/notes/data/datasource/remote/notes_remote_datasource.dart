import '../../models/note_model.dart';

abstract interface class NotesRemoteDataSource {
  Future<List<NoteModel>> getNotes();

  Future<void> addNote(NoteModel note);

  Future<void> updateNote(NoteModel note);

  Future<void> deleteNote(String id);
}