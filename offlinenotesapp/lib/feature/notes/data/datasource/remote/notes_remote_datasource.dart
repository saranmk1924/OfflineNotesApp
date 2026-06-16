import '../../models/note_model.dart';

/// Contract for remote data operations related to notes.
///
/// Defines all required API interactions for managing notes on a server,
/// including fetching, creating, updating, deleting, and retrieving
/// individual notes.
///
/// This abstraction allows the data layer to switch implementations
/// (e.g., mock API, real backend, or testing service) without affecting
/// the rest of the application.
abstract interface class NotesRemoteDataSource {
  /// Fetches all notes from the remote server.
  Future<List<NoteModel>> getNotes();

  /// Creates a new note on the remote server.
  Future<NoteModel> addNote(NoteModel note);

  /// Updates an existing note on the remote server.
  Future<NoteModel> updateNote(NoteModel note);

  /// Deletes a note from the remote server using its [id].
  Future<void> deleteNote(String id);

  /// Fetches a single note by its [id] from the remote server.
  ///
  /// Returns `null` if the note is not found or the request fails.
  Future<NoteModel?> getNoteById(String id);
}
