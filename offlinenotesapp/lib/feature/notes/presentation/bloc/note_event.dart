import 'package:equatable/equatable.dart';

import '../../domain/entities/note_entity.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotesEvent extends NoteEvent {}

class AddNoteEvent extends NoteEvent {
  final NoteEntity note;

  const AddNoteEvent(this.note);

  @override
  List<Object?> get props => [note];
}

class UpdateNoteEvent extends NoteEvent {
  final NoteEntity note;

  const UpdateNoteEvent(this.note);

  @override
  List<Object?> get props => [note];
}

class DeleteNoteEvent extends NoteEvent {
  final String noteId;

  const DeleteNoteEvent(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

class SyncNotesEvent extends NoteEvent {}

class ResolveConflictUseLocalEvent extends NoteEvent {
  final NoteEntity localNote;

  const ResolveConflictUseLocalEvent(this.localNote);

  @override
  List<Object?> get props => [localNote];
}

class ResolveConflictUseServerEvent extends NoteEvent {
  final NoteEntity serverNote;

  const ResolveConflictUseServerEvent(this.serverNote);

  @override
  List<Object?> get props => [serverNote];
}

class CheckConflictEvent extends NoteEvent {}

class UseLocalVersionEvent extends NoteEvent {
  final NoteEntity note;

  const UseLocalVersionEvent(this.note);

  @override
  List<Object?> get props => [note];
}

class UseServerVersionEvent extends NoteEvent {
  final NoteEntity note;

  const UseServerVersionEvent(this.note);

  @override
  List<Object?> get props => [note];
}