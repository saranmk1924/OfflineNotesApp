import '../../models/note_model.dart';

/// Contract for local data operations related to notes.
///
/// Defines all required methods for interacting with local storage
/// (e.g., Hive) including CRUD operations and sync metadata handling.
///
/// This abstraction allows different implementations (mock, Hive, etc.)
/// without affecting the rest of the application.
abstract interface class NotesLocalDataSource {
  /// Adds a new note to local storage.
  Future<void> addNote(NoteModel note);

  /// Updates an existing note in local storage.
  Future<void> updateNote(NoteModel note);

  /// Deletes a note from local storage using its [id].
  Future<void> deleteNote(String id);

  /// Retrieves all locally stored notes.
  Future<List<NoteModel>> getNotes();

  /// Replaces all local notes with the provided list.
  Future<void> saveNotes(List<NoteModel> notes);

  /// Saves the timestamp of the last successful sync operation.
  Future<void> saveLastSyncTime();

  /// Retrieves the last saved sync timestamp, if available.
  DateTime? getLastSyncTime();
}
