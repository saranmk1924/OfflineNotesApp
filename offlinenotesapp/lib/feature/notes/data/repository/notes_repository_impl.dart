import 'package:offlinenotesapp/feature/notes/data/datasource/remote/notes_remote_datasource.dart';
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
    await localDataSource.deleteNote(id);
  }

  @override
  Future<List<NoteEntity>> getNotes() async {
    return await localDataSource.getNotes();
  }

  @override
  Future<void> syncNotes() async {
    final localNotes = await localDataSource.getNotes();

    // print("LOCAL COUNT => ${localNotes.length}");

    // for (final note in localNotes) {
    //   print("LOCAL NOTE => ${note.id} | ${note.title} | ${note.syncStatus}");
    // }
    // print(":Local notesssssssssss: $localNotes");

    final updatedNotes = <NoteModel>[];

    for (final note in localNotes) {
      if (note.syncStatus != SyncStatus.pending) {
        updatedNotes.add(NoteModel.fromEntity(note));
        continue;
      }

      try {
        NoteModel syncedNote;
        final serverNote = await remoteDataSource.getNoteById(note.id);

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

        updatedNotes.add(NoteModel.fromEntity(note));
      }
    }

    try {
      final remoteNotes = await remoteDataSource.getNotes();

      for (final remoteNote in remoteNotes) {
        final exists = updatedNotes.any(
          (localNote) => localNote.id == remoteNote.id,
        );

        if (!exists) {
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
  }
}
