import 'package:offlinenotesapp/feature/notes/data/datasource/remote/notes_remote_datasource.dart';
import 'package:offlinenotesapp/feature/notes/domain/entities/conflict_entity.dart';
import 'package:offlinenotesapp/feature/notes/domain/entities/sync_status.dart';

import '../../domain/entities/note_entity.dart';
import '../../domain/repository/notes_repository.dart';
import '../datasource/local/notes_local_datasource.dart';
import '../models/note_model.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource localDataSource;
  final NotesRemoteDataSource remoteDataSource;

  NotesRepositoryImpl(this.localDataSource, this.remoteDataSource);

  @override
  Future<void> addNote(NoteEntity note) async {
    await localDataSource.addNote(NoteModel.fromEntity(note));
  }

  @override
  Future<void> updateNote(NoteEntity note) async {
    await localDataSource.updateNote(NoteModel.fromEntity(note));
  }

  @override
  Future<void> deleteNote(String id) async {
    // await localDataSource.deleteNote(id);
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
  Future<List<NoteEntity>> getNotes() async {
    return await localDataSource.getNotes();

    // return notes.where((e) => !e.isDeleted).toList();
  }

  @override
  Future<ConflictEntity?> syncNotes() async {
    final localNotes = await localDataSource.getNotes();

    // print("LOCAL COUNT => ${localNotes.length}");

    // for (final note in localNotes) {
    //   print("LOCAL NOTE => ${note.id} | ${note.title} | ${note.syncStatus}");
    // }
    // print(":Local notesssssssssss: $localNotes");

    final updatedNotes = <NoteModel>[];

    for (final note in localNotes) {
      if (note.isDeleted) {
        try {
          await remoteDataSource.deleteNote(note.id);

          continue;
        } catch (_) {
          updatedNotes.add(note);
          continue;
        }
      }
      if (note.syncStatus != SyncStatus.pending) {
        updatedNotes.add(NoteModel.fromEntity(note));
        continue;
      }

      try {
        NoteModel syncedNote;
        final serverNote = await remoteDataSource.getNoteById(note.id);
        print("LOCAL UPDATED => ${note.updatedAt}");
        print("LOCAL LASTSYNC => ${note.lastSyncedAt}");

        print("SERVER UPDATED => ${serverNote?.updatedAt}");

        print(
          "LOCAL CHANGED => ${note.lastSyncedAt != null && note.updatedAt.isAfter(note.lastSyncedAt!)}",
        );

        print(
          "SERVER CHANGED => ${serverNote != null && note.lastSyncedAt != null && serverNote.updatedAt.isAfter(note.lastSyncedAt!)}",
        );
        if (serverNote != null &&
            note.lastSyncedAt != null &&
            note.updatedAt.isAfter(note.lastSyncedAt!) &&
            serverNote.updatedAt.isAfter(note.lastSyncedAt!)) {
          print("CONFLICT DETECTED");
          return ConflictEntity(localNote: note, serverNote: serverNote);
        }

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
        // print("SYNC FAILED FOR NOTE ${note.id} => $e");
        throw Exception('No internet connection');
        // updatedNotes.add(NoteModel.fromEntity(note));
      }
    }

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
            // print("REMOTE NOTE SYNC FAILED ${remoteNote.id} => $e");

            updatedNotes.add(remoteNote);
          }
        }
      }
    } catch (e) {
      // print('FAILED TO FETCH REMOTE NOTES => $e');
    }

    await localDataSource.saveNotes(updatedNotes);
    return null;
  }

  @override
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
  Future<void> useLocalVersion(NoteEntity localNote) async {
    final syncedNote = NoteModel.fromEntity(
      localNote,
    ).copyWith(syncStatus: SyncStatus.synced, lastSyncedAt: DateTime.now());

    await remoteDataSource.updateNote(syncedNote);

    await localDataSource.updateNote(syncedNote);
  }

  @override
  Future<void> useServerVersion(NoteEntity serverNote) async {
    final syncedNote = NoteModel.fromEntity(
      serverNote,
    ).copyWith(syncStatus: SyncStatus.synced, lastSyncedAt: DateTime.now());

    await localDataSource.updateNote(syncedNote);
  }
}
