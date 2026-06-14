import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offlinenotesapp/feature/notes/domain/usecase/add_note_usecase.dart';
import 'package:offlinenotesapp/feature/notes/domain/usecase/delete_note_usecase.dart';
import 'package:offlinenotesapp/feature/notes/domain/usecase/get_notes_usecase.dart';
import 'package:offlinenotesapp/feature/notes/domain/usecase/sync_notes_usecase.dart';
import 'package:offlinenotesapp/feature/notes/domain/usecase/update_note_usecase.dart';
import 'note_event.dart';
import 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final AddNoteUsecase addNote;
  final UpdateNoteUsecase updateNote;
  final DeleteNoteUsecase deleteNote;
  final GetNotesUsecase getNotes;
  final SyncNotesUsecase syncNotes;

  NoteBloc({
    required this.addNote,
    required this.updateNote,
    required this.deleteNote,
    required this.getNotes,
    required this.syncNotes,
  }) : super(NoteInitial()) {
    on<LoadNotesEvent>(_onLoadNotes);
    on<AddNoteEvent>(_onAddNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<DeleteNoteEvent>(_onDeleteNote);
    on<SyncNotesEvent>(_onSyncNotes);
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
    await syncNotes();

    add(LoadNotesEvent());
  }
}
