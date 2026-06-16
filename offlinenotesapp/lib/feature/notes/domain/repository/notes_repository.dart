import '../entities/conflict_entity.dart';
import '../entities/note_entity.dart';

/// Contract for the Notes repository layer.
///
/// This abstraction defines all note-related operations, including:
/// - Local CRUD actions
/// - Synchronization with remote source
/// - Conflict detection and resolution strategies
///
/// The repository acts as a bridge between domain logic and data sources,
/// ensuring the rest of the app remains independent of implementation details.
abstract interface class NotesRepository {
  /// Adds a new note.
  Future<void> addNote(NoteEntity note);

  /// Updates an existing note.
  Future<void> updateNote(NoteEntity note);

  /// Deletes a note by its [id].
  Future<void> deleteNote(String id);

  /// Retrieves all available notes.
  Future<List<NoteEntity>> getNotes();

  /// Synchronizes local notes with the remote server.
  ///
  /// Returns a [ConflictEntity] if a sync conflict is detected,
  /// otherwise returns `null` when sync completes successfully.
  Future<ConflictEntity?> syncNotes();

  /// Checks for conflicts between local and remote notes.
  ///
  /// Returns a tuple of (localNote, serverNote) if a conflict exists,
  /// otherwise returns `null`.
  Future<(NoteEntity, NoteEntity)?> checkConflict();

  /// Resolves conflict by preferring the local version of the note.
  Future<void> useLocalVersion(NoteEntity localNote);

  /// Resolves conflict by preferring the server version of the note.
  Future<void> useServerVersion(NoteEntity serverNote);

  /// Retrieves the timestamp of the last successful synchronization.
  DateTime? getLastSyncTime();
}
