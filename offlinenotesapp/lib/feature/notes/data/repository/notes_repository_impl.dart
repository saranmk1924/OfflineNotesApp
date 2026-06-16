import 'package:offlinenotesapp/feature/notes/data/datasource/remote/notes_remote_datasource.dart';
import 'package:offlinenotesapp/feature/notes/domain/entities/conflict_entity.dart';
import 'package:offlinenotesapp/core/enums/sync_status.dart';

import '../../domain/entities/note_entity.dart';
import '../../domain/repository/notes_repository.dart';
import '../datasource/local/notes_local_datasource.dart';
import '../models/note_model.dart';

/// Repository implementation that coordinates between local and remote data sources.
///
/// This class acts as the single source of truth for note-related operations,
/// handling:
/// - Local CRUD operations (offline-first)
/// - Remote synchronization
/// - Conflict detection and resolution
/// - Data merging between local and server states
class NotesRepositoryImpl implements NotesRepository {
  /// Local data source (Hive-based storage).
  final NotesLocalDataSource localDataSource;

  /// Remote data source (API-based storage).
  final NotesRemoteDataSource remoteDataSource;

  /// Creates a new [NotesRepositoryImpl] instance.
  NotesRepositoryImpl(this.localDataSource, this.remoteDataSource);

  @override
  /// Adds a new note to local storage.
  Future<void> addNote(NoteEntity note) async {
    await localDataSource.addNote(NoteModel.fromEntity(note));
  }

  @override
  /// Updates an existing note in local storage.
  Future<void> updateNote(NoteEntity note) async {
    await localDataSource.updateNote(NoteModel.fromEntity(note));
  }

  @override
  /// Marks a note as deleted locally (soft delete).
  ///
  /// The note is not immediately removed; instead, it is flagged for
  /// deletion and synced with the server later.
  Future<void> deleteNote(String id) async {
    final notes = await localDataSource.getNotes();

    final note = notes.firstWhere((n) => n.id == id);

    await localDataSource.updateNote(
      note.copyWith(
        isDeleted: true,
        syncStatus: SyncStatus.pending,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  /// Retrieves all locally stored notes.
  ///
  /// This method returns offline-first data and does not directly
  /// query the remote server.
  Future<List<NoteEntity>> getNotes() async {
    return await localDataSource.getNotes();
  }

  @override
  /// Synchronizes local notes with the remote server.
  ///
  /// Handles:
  /// - Uploading local changes
  /// - Downloading remote updates
  /// - Detecting conflicts between local and server versions
  /// - Merging and persisting final state
  Future<ConflictEntity?> syncNotes() async {
    try {
      final localNotes = await localDataSource.getNotes();

      final updatedNotes = <NoteModel>[];

      for (final note in localNotes) {
        final serverNote = await remoteDataSource.getNoteById(note.id);

        /// Handle deleted notes first.
        if (note.isDeleted) {
          final localDeletedAfterSync =
              note.lastSyncedAt != null &&
              note.updatedAt.isAfter(note.lastSyncedAt!);

          final serverChangedAfterSync =
              serverNote != null &&
              note.lastSyncedAt != null &&
              serverNote.updatedAt.isAfter(note.lastSyncedAt!);

          if (localDeletedAfterSync && serverChangedAfterSync) {
            return ConflictEntity(localNote: note, serverNote: serverNote);
          }

          try {
            await remoteDataSource.deleteNote(note.id);

            continue;
          } catch (_) {
            updatedNotes.add(note);
            continue;
          }
        }

        /// Skip already synced notes.
        if (note.syncStatus != SyncStatus.pending) {
          updatedNotes.add(NoteModel.fromEntity(note));
          continue;
        }

        try {
          NoteModel syncedNote;

          final localChanged =
              note.lastSyncedAt != null &&
              note.updatedAt.isAfter(note.lastSyncedAt!);

          final serverChanged =
              serverNote != null &&
              note.lastSyncedAt != null &&
              serverNote.updatedAt.isAfter(note.lastSyncedAt!);

          /// LOCAL edited, SERVER deleted
          if (serverNote != null && serverNote.isDeleted && localChanged) {
            return ConflictEntity(localNote: note, serverNote: serverNote);
          }

          /// LOCAL deleted, SERVER edited
          if (note.isDeleted && serverNote != null && serverChanged) {
            return ConflictEntity(localNote: note, serverNote: serverNote);
          }

          /// Both LOCAL and SERVER modified
          if (serverNote != null && localChanged && serverChanged) {
            return ConflictEntity(localNote: note, serverNote: serverNote);
          }

          /// Create note on server if it doesn't exist.
          if (serverNote == null) {
            final createdNote = await remoteDataSource.addNote(
              NoteModel.fromEntity(note),
            );

            syncedNote = await remoteDataSource.updateNote(
              createdNote.copyWith(
                syncStatus: SyncStatus.synced,
                lastSyncedAt: DateTime.now(),
              ),
            );
          } else {
            syncedNote = await remoteDataSource.updateNote(
              NoteModel.fromEntity(note).copyWith(
                syncStatus: SyncStatus.synced,
                lastSyncedAt: DateTime.now(),
              ),
            );
          }

          updatedNotes.add(syncedNote);
        } catch (e) {
          throw Exception('No internet connection');
        }
      }

      /// Pull remote updates after local sync.
      try {
        final remoteNotes = await remoteDataSource.getNotes();

        for (final remoteNote in remoteNotes) {
          final exists = updatedNotes.any(
            (localNote) => localNote.id == remoteNote.id,
          );

          if (!exists &&
              !localNotes.any((n) => n.id == remoteNote.id && n.isDeleted)) {
            try {
              if (remoteNote.syncStatus != SyncStatus.synced) {
                final syncedNote = await remoteDataSource.updateNote(
                  remoteNote.copyWith(
                    syncStatus: SyncStatus.synced,
                    lastSyncedAt: remoteNote.lastSyncedAt ?? DateTime.now(),
                  ),
                );
                updatedNotes.add(syncedNote);
              } else {
                updatedNotes.add(
                  remoteNote.copyWith(
                    syncStatus: SyncStatus.synced,
                    lastSyncedAt: remoteNote.lastSyncedAt ?? DateTime.now(),
                  ),
                );
              }
            } catch (e) {
              updatedNotes.add(remoteNote);
            }
          }
        }
      } catch (e) {
        // Remote fetch failure is non-fatal for sync process.
      }

      await localDataSource.saveNotes(updatedNotes);
      await localDataSource.saveLastSyncTime();
      return null;
    } catch (e) {
      throw Exception('Sync failed due to server/network issue: $e');
    }
  }

  @override
  /// Checks for conflicts between local and remote notes.
  Future<(NoteEntity, NoteEntity)?> checkConflict() async {
    final localNotes = await localDataSource.getNotes();
    final remoteNotes = await remoteDataSource.getNotes();

    for (final localNote in localNotes) {
      final serverNote = remoteNotes.where((note) => note.id == localNote.id);

      if (serverNote.isEmpty) continue;

      final remoteNote = serverNote.first;

      final localChangedAfterSync =
          localNote.lastSyncedAt != null &&
          localNote.updatedAt.isAfter(localNote.lastSyncedAt!);

      final remoteChangedAfterSync =
          remoteNote.lastSyncedAt != null &&
          remoteNote.updatedAt.isAfter(remoteNote.lastSyncedAt!);

      if (localChangedAfterSync && remoteChangedAfterSync) {
        return (localNote, remoteNote);
      }
    }

    return null;
  }

  @override
  /// Forces the local version of a note to take precedence.
  Future<void> useLocalVersion(NoteEntity localNote) async {
    final syncedNote = NoteModel.fromEntity(
      localNote,
    ).copyWith(syncStatus: SyncStatus.synced, lastSyncedAt: DateTime.now());

    await remoteDataSource.updateNote(syncedNote);

    await localDataSource.updateNote(syncedNote);

    await localDataSource.saveLastSyncTime();
  }

  @override
  /// Forces the server version of a note to take precedence.
  Future<void> useServerVersion(NoteEntity serverNote) async {
    final syncedNote = NoteModel.fromEntity(
      serverNote,
    ).copyWith(syncStatus: SyncStatus.synced, lastSyncedAt: DateTime.now());

    await localDataSource.updateNote(syncedNote);

    await localDataSource.saveLastSyncTime();
  }

  @override
  /// Retrieves the last successful synchronization timestamp.
  DateTime? getLastSyncTime() {
    return localDataSource.getLastSyncTime();
  }
}
