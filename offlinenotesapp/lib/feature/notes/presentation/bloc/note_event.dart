import 'package:equatable/equatable.dart';

import '../../domain/entities/note_entity.dart';

/// Base class for all note-related events used in the NoteBloc.
///
/// Each event represents a user or system action that triggers
/// a change in the note state, such as loading, adding, updating,
/// deleting, syncing, or resolving conflicts.
abstract class NoteEvent extends Equatable {
  /// Creates a base [NoteEvent].
  const NoteEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all notes from local storage.
class LoadNotesEvent extends NoteEvent {}

/// Event to add a new note.
class AddNoteEvent extends NoteEvent {
  final NoteEntity note;

  const AddNoteEvent(this.note);

  @override
  List<Object?> get props => [note];
}

/// Event to update an existing note.
class UpdateNoteEvent extends NoteEvent {
  final NoteEntity note;

  const UpdateNoteEvent(this.note);

  @override
  List<Object?> get props => [note];
}

/// Event to delete a note by its ID.
class DeleteNoteEvent extends NoteEvent {
  final String noteId;

  const DeleteNoteEvent(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

/// Event to trigger full synchronization with the remote server.
class SyncNotesEvent extends NoteEvent {}

/// Event to resolve conflict using the local version of a note.
class ResolveConflictUseLocalEvent extends NoteEvent {
  final NoteEntity localNote;

  const ResolveConflictUseLocalEvent(this.localNote);

  @override
  List<Object?> get props => [localNote];
}

/// Event to resolve conflict using the server version of a note.
class ResolveConflictUseServerEvent extends NoteEvent {
  final NoteEntity serverNote;

  const ResolveConflictUseServerEvent(this.serverNote);

  @override
  List<Object?> get props => [serverNote];
}

/// Event to check for sync conflicts between local and remote data.
class CheckConflictEvent extends NoteEvent {}

/// Event to forcefully use the local version of a note.
class UseLocalVersionEvent extends NoteEvent {
  final NoteEntity note;

  const UseLocalVersionEvent(this.note);

  @override
  List<Object?> get props => [note];
}

/// Event to forcefully use the server version of a note.
class UseServerVersionEvent extends NoteEvent {
  final NoteEntity note;

  const UseServerVersionEvent(this.note);

  @override
  List<Object?> get props => [note];
}
