import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offlinenotesapp/feature/notes/domain/entities/note_entity.dart';
import 'package:offlinenotesapp/feature/notes/domain/entities/sync_status.dart';
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

  Future<void> _onLoadNotes(
    LoadNotesEvent event,
    Emitter<NoteState> emit,
  ) async {
    emit(NoteLoading());

    await _emitLoaded(emit);
  }

  Future<void> _onAddNote(AddNoteEvent event, Emitter<NoteState> emit) async {
    await addNote(event.note.copyWith(syncStatus: SyncStatus.pending));
    await _emitLoaded(emit);
  }

  Future<void> _onUpdateNote(
    UpdateNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    await updateNote(event.note.copyWith(syncStatus: SyncStatus.pending));

    await _emitLoaded(emit);
  }

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

    print("IS DELETED => ${note.isDeleted}");
    print("UPDATED AT => ${note.updatedAt}");
    print("LAST SYNCED => ${note.lastSyncedAt}");

    await _emitLoaded(emit);
  }

  Future<void> _onSyncNotes(
    SyncNotesEvent event,
    Emitter<NoteState> emit,
  ) async {
    List<NoteEntity> previousNotes =[];
    try{
    print("SYNC STARTED");
    // get latest snapshot BEFORE sync
    final notes = await getNotes();
    final activeNotes = notes.where((n) => !n.isDeleted).toList();
    previousNotes = activeNotes;
    emit(NoteSyncing(previousNotes: activeNotes));
    final conflict = await syncNotes();

    if (conflict != null) {
      print("CONFLICT STATE EMITTED");
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

  Future<void> _onUseLocalVersion(
    UseLocalVersionEvent event,
    Emitter<NoteState> emit,
  ) async {
    final currentState = state;
    try {
      if (currentState is ConflictDetectedState) {
        emit(ConflictResolvingState(previousNotes: currentState.previousNotes));
      }
      print("LOCAL VERSION SELECTED");
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

  Future<void> _onUseServerVersion(
    UseServerVersionEvent event,
    Emitter<NoteState> emit,
  ) async {
    final currentState = state;
    try {
      if (currentState is ConflictDetectedState) {
        emit(ConflictResolvingState(previousNotes: currentState.previousNotes));
      }
      print("SERVER VERSION SELECTED");
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
  List<NoteEntity> _active(List<NoteEntity> notes) {
    return notes.where((n) => !n.isDeleted).toList();
  }

  Future<void> _emitLoaded(Emitter<NoteState> emit) async {
    final notes = await getNotes();
    emit(NoteLoaded(_active(notes), notes, lastSyncTime: getLastSyncTime()));
  }

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
