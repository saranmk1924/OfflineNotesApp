import 'package:flutter_bloc/flutter_bloc.dart';
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

    final notes = await getNotes();

    emit(NoteLoaded(notes));
  }

  Future<void> _onAddNote(AddNoteEvent event, Emitter<NoteState> emit) async {
    await addNote(event.note);

    add(LoadNotesEvent());
  }

  Future<void> _onUpdateNote(
    UpdateNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    await updateNote(event.note);

    add(LoadNotesEvent());
  }

  Future<void> _onDeleteNote(
    DeleteNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    await deleteNote(event.noteId);

    add(LoadNotesEvent());
  }

  Future<void> _onSyncNotes(
    SyncNotesEvent event,
    Emitter<NoteState> emit,
  ) async {
    final conflict = await syncNotes();

    if (conflict != null) {
      emit(
        ConflictDetectedState(
          localNote: conflict.localNote,
          serverNote: conflict.serverNote,
        ),
      );
      return;
    }

    add(LoadNotesEvent());
  }

  Future<void> _onCheckConflict(
    CheckConflictEvent event,
    Emitter<NoteState> emit,
  ) async {
    final conflict = await checkConflict();

    if (conflict != null) {
      emit(NoteConflict(localNote: conflict.$1, serverNote: conflict.$2));
    }
  }

  Future<void> _onUseLocalVersion(
    UseLocalVersionEvent event,
    Emitter<NoteState> emit,
  ) async {
    await useLocalVersion(event.note);

    add(LoadNotesEvent());
  }

  Future<void> _onUseServerVersion(
    UseServerVersionEvent event,
    Emitter<NoteState> emit,
  ) async {
    await useServerVersion(event.note);

    add(LoadNotesEvent());
  }
}
