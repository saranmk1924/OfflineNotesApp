import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offlinenotesapp/feature/notes/domain/entities/note_entity.dart';
import 'package:offlinenotesapp/feature/notes/domain/entities/sync_status.dart';
import 'package:offlinenotesapp/feature/notes/domain/usecase/add_note_usecase.dart';
import 'package:offlinenotesapp/feature/notes/domain/usecase/check_conflict_usecase.dart';
import 'package:offlinenotesapp/feature/notes/domain/usecase/delete_note_usecase.dart';
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

  NoteBloc({
    required this.addNote,
    required this.updateNote,
    required this.deleteNote,
    required this.getNotes,
    required this.syncNotes,
    required this.checkConflict,
    required this.useLocalVersion,
    required this.useServerVersion,
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
        syncStatus: SyncStatus.pending, // keep explicit
        updatedAt: DateTime.now(),
      ),
    );

    await _emitLoaded(emit);
  }

  Future<void> _onSyncNotes(
    SyncNotesEvent event,
    Emitter<NoteState> emit,
  ) async {
    print("SYNC STARTED");
    // get latest snapshot BEFORE sync
    final notes = await getNotes();
    final activeNotes = notes.where((n) => !n.isDeleted).toList();
    emit(NoteSyncing(previousNotes: activeNotes));
    final conflict = await syncNotes();

    if (conflict != null) {
      print("CONFLICT STATE EMITTED");
      emit(
        ConflictDetectedState(
          localNote: conflict.localNote,
          serverNote: conflict.serverNote,
        ),
      );
      return;
    }
    emit(NoteSyncSuccess());

    await _emitLoaded(emit);
  }

  Future<void> _onCheckConflict(
    CheckConflictEvent event,
    Emitter<NoteState> emit,
  ) async {
    final conflict = await checkConflict();

    if (conflict != null) {
      emit(
        ConflictDetectedState(localNote: conflict.$1, serverNote: conflict.$2),
      );
    }
  }

  Future<void> _onUseLocalVersion(
    UseLocalVersionEvent event,
    Emitter<NoteState> emit,
  ) async {
    print("LOCAL VERSION SELECTED");
    await useLocalVersion(event.note);

    emit(NoteSyncSuccess());

    add(LoadNotesEvent());
  }

  Future<void> _onUseServerVersion(
    UseServerVersionEvent event,
    Emitter<NoteState> emit,
  ) async {
    print("SERVER VERSION SELECTED");
    await useServerVersion(event.note);

    emit(NoteSyncSuccess());

    add(LoadNotesEvent());
  }

  //Helper
  List<NoteEntity> _active(List<NoteEntity> notes) {
    return notes.where((n) => !n.isDeleted).toList();
  }

  Future<void> _emitLoaded(Emitter<NoteState> emit) async {
    final notes = await getNotes();
    emit(NoteLoaded(_active(notes), notes));
  }
}
