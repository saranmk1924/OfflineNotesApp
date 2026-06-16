import 'package:hive_flutter/hive_flutter.dart';

import '../../models/note_model.dart';
import 'notes_local_datasource.dart';

/// Local data source implementation for managing notes using Hive storage.
///
/// Handles all offline CRUD operations and sync metadata persistence.
/// This acts as the single source of truth for locally cached notes.
class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  /// Hive box used for storing notes data.
  final Box notesBox;

  /// Hive box used for storing synchronization metadata (e.g. last sync time).
  final Box syncBox;

  /// Creates a new instance of [NotesLocalDataSourceImpl].
  NotesLocalDataSourceImpl(this.notesBox, this.syncBox);

  @override
  /// Adds a new note to local storage.
  Future<void> addNote(NoteModel note) async {
    await notesBox.put(note.id, note.toJson());
  }

  @override
  /// Updates an existing note in local storage.
  Future<void> updateNote(NoteModel note) async {
    await notesBox.put(note.id, note.toJson());
  }

  @override
  /// Deletes a note from local storage using its [id].
  Future<void> deleteNote(String id) async {
    await notesBox.delete(id);
  }

  @override
  /// Retrieves all notes from local storage.
  ///
  /// Notes are sorted by `updatedAt` in descending order.
  Future<List<NoteModel>> getNotes() async {
    final notes = notesBox.values
        .map((note) => NoteModel.fromJson(Map<String, dynamic>.from(note)))
        .toList();

    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return notes;
  }

  @override
  /// Replaces all locally stored notes with the provided list.
  ///
  /// Typically used during full sync from the server.
  Future<void> saveNotes(List<NoteModel> notes) async {
    await notesBox.clear();

    for (final note in notes) {
      await notesBox.put(note.id, note.toJson());
    }
  }

  @override
  /// Saves the current timestamp as the last successful sync time.
  Future<void> saveLastSyncTime() async {
    await syncBox.put('lastSyncTime', DateTime.now().toIso8601String());
  }

  @override
  /// Retrieves the last successful sync time from local storage.
  ///
  /// Returns `null` if no sync has been performed yet.
  DateTime? getLastSyncTime() {
    final value = syncBox.get('lastSyncTime');

    if (value == null) return null;

    return DateTime.parse(value);
  }
}
