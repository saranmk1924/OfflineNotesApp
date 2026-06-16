import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offlinenotesapp/feature/notes/domain/entities/note_entity.dart';
import 'package:offlinenotesapp/core/enums/sync_status.dart';
import 'package:offlinenotesapp/feature/notes/domain/usecase/add_note_usecase.dart';
import 'package:offlinenotesapp/feature/notes/domain/usecase/check_conflict_usecase.dart';
import 'package:offlinenotesapp/feature/notes/domain/usecase/delete_note_usecase.dart';
import 'package:offlinenotesapp/feature/notes/domain/usecase/get_last_sync_time_usecase.dart';
import 'package:offlinenotesapp/feature/notes/domain/usecase/get_notes_usecase.dart';
import 'package:offlinenotesapp/feature/notes/domain/usecase/sync_notes_usecase.dart';
import 'package:offlinenotesapp/feature/notes/domain/usecase/update_note_usecase.dart';
import 'package:offlinenotesapp/feature/notes/domain/usecase/use_local_version_usecase.dart';
import 'package:offlinenotesapp/feature/notes/domain/usecase/use_server_version_usecase.dart';
import 'note_event.dart';
import 'note_state.dart';

/// Business Logic Component (BLoC) responsible for managing note state.
///
/// Handles:
/// - CRUD operations
/// - Offline-first state management
/// - Synchronization with remote server
/// - Conflict detection and resolution
/// - Emitting UI states based on note operations
class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final AddNoteUsecase addNote;
  final UpdateNoteUsecase updateNote;
  final DeleteNoteUsecase deleteNote;
  final GetNotesUsecase getNotes;
  final SyncNotesUsecase syncNotes;
  final CheckConflictUsecase checkConflict;
  final UseLocalVersionUsecase useLocalVersion;
  final UseServerVersionUsecase useServerVersion;
  final GetLastSyncTimeUsecase getLastSyncTime;

  /// Creates a new [NoteBloc] instance and registers event handlers.
  NoteBloc({
    required this.addNote,
    required this.updateNote,
    required this.deleteNote,
    required this.getNotes,
    required this.syncNotes,
    required this.checkConflict,
    required this.useLocalVersion,
    required this.useServerVersion,
    required this.getLastSyncTime,
  }) : super(NoteInitial()) {
    on<LoadNotesEvent>(_onLoadNotes);
    on<AddNoteEvent>(_onAddNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<DeleteNoteEvent>(_onDeleteNote);
    on<SyncNotesEvent>(_onSyncNotes);
    on<CheckConflictEvent>(_onCheckConflict);
    on<UseLocalVersionEvent>(_onUseLocalVersion);
    on<UseServerVersionEvent>(_onUseServerVersion);
  }

  /// Loads all notes and emits [NoteLoaded] state.
  Future<void> _onLoadNotes(
    LoadNotesEvent event,
    Emitter<NoteState> emit,
  ) async {
    emit(NoteLoading());

    await _emitLoaded(emit);
  }

  /// Adds a new note and refreshes state.
  Future<void> _onAddNote(AddNoteEvent event, Emitter<NoteState> emit) async {
    await addNote(event.note.copyWith(syncStatus: SyncStatus.pending));
    await _emitLoaded(emit);
  }

  /// Updates an existing note and refreshes state.
  Future<void> _onUpdateNote(
    UpdateNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    await updateNote(event.note.copyWith(syncStatus: SyncStatus.pending));

    await _emitLoaded(emit);
  }

  /// Marks a note as deleted (soft delete) and refreshes state.
  Future<void> _onDeleteNote(
    DeleteNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    final List<NoteEntity> notes = await getNotes();
    final NoteEntity note = notes.firstWhere((n) => n.id == event.noteId);

    await updateNote(
      note.copyWith(
        isDeleted: true,
        syncStatus: SyncStatus.pending,
        updatedAt: DateTime.now(),
      ),
    );

    await _emitLoaded(emit);
  }

  /// Syncs local notes with remote server and handles conflicts.
  Future<void> _onSyncNotes(
    SyncNotesEvent event,
    Emitter<NoteState> emit,
  ) async {
    List<NoteEntity> previousNotes = [];
    try {
      // get latest snapshot BEFORE sync
      final notes = await getNotes();
      final activeNotes = notes.where((n) => !n.isDeleted).toList();
      previousNotes = activeNotes;
      emit(NoteSyncing(previousNotes: activeNotes));
      final conflict = await syncNotes();

      if (conflict != null) {
        emit(
          ConflictDetectedState(
            localNote: conflict.localNote,
            serverNote: conflict.serverNote,
            previousNotes: activeNotes,
          ),
        );
        return;
      }

      await _markAllSynced();

      emit(NoteSyncSuccess());

      await _emitLoaded(emit);
    } catch (e) {
      emit(NoteError("Failed to sync", previousNotes: previousNotes));
    }
  }

  /// Checks for conflicts between local and server data.
  Future<void> _onCheckConflict(
    CheckConflictEvent event,
    Emitter<NoteState> emit,
  ) async {
    final conflict = await checkConflict();

    if (conflict != null) {
      final notes = await getNotes();
      emit(
        ConflictDetectedState(
          localNote: conflict.$1,
          serverNote: conflict.$2,
          previousNotes: notes,
        ),
      );
    }
  }

  /// Resolves conflict by choosing local version.
  Future<void> _onUseLocalVersion(
    UseLocalVersionEvent event,
    Emitter<NoteState> emit,
  ) async {
    final currentState = state;
    try {
      if (currentState is ConflictDetectedState) {
        emit(ConflictResolvingState(previousNotes: currentState.previousNotes));
      }
      await useLocalVersion(event.note);

      emit(NoteSyncSuccess());

      await _emitLoaded(emit);
    } catch (e) {
      if (currentState is ConflictDetectedState) {
        emit(
          ConflictDetectedState(
            localNote: currentState.localNote,
            serverNote: currentState.serverNote,
            previousNotes: currentState.previousNotes,
          ),
        );
      }
    }
  }

  /// Resolves conflict by choosing server version.
  Future<void> _onUseServerVersion(
    UseServerVersionEvent event,
    Emitter<NoteState> emit,
  ) async {
    final currentState = state;
    try {
      if (currentState is ConflictDetectedState) {
        emit(ConflictResolvingState(previousNotes: currentState.previousNotes));
      }
      await useServerVersion(event.note);

      emit(NoteSyncSuccess());

      await _emitLoaded(emit);
    } catch (e) {
      if (currentState is ConflictDetectedState) {
        emit(
          ConflictDetectedState(
            localNote: currentState.localNote,
            serverNote: currentState.serverNote,
            previousNotes: currentState.previousNotes,
          ),
        );
      }
    }
  }

  //Helper
  /// Returns only active (non-deleted) notes.
  List<NoteEntity> _active(List<NoteEntity> notes) {
    return notes.where((n) => !n.isDeleted).toList();
  }

  /// Emits the loaded state with latest notes and sync info.
  Future<void> _emitLoaded(Emitter<NoteState> emit) async {
    final notes = await getNotes();
    emit(NoteLoaded(_active(notes), notes, lastSyncTime: getLastSyncTime()));
  }

  /// Marks all notes as synced after successful sync operation.
  Future<void> _markAllSynced() async {
    final notes = await getNotes();

    for (final note in notes) {
      if (note.syncStatus != SyncStatus.synced) {
        await updateNote(
          note.copyWith(
            syncStatus: SyncStatus.synced,
            lastSyncedAt: DateTime.now(),
          ),
        );
      }
    }
  }
}
