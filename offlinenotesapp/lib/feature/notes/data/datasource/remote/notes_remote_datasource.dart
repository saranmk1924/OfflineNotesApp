import '../../models/note_model.dart';

abstract interface class NotesRemoteDataSource {
  Future<List<NoteModel>> getNotes();

  Future<NoteModel> addNote(NoteModel note);

  Future<NoteModel> updateNote(NoteModel note);

  Future<void> deleteNote(String id);

  Future<NoteModel?> getNoteById(String id);
}
