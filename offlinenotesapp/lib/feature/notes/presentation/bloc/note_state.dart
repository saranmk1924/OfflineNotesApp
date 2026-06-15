import 'package:equatable/equatable.dart';

import '../../domain/entities/note_entity.dart';

abstract class NoteState extends Equatable {
  const NoteState();

  @override
  List<Object?> get props => [];
}

class NoteInitial extends NoteState {}

class NoteLoading extends NoteState {}

class NoteLoaded extends NoteState {
  final List<NoteEntity> notes;
  final List<NoteEntity> notesRaw;
  final DateTime? lastSyncTime;

  const NoteLoaded(this.notes, this.notesRaw, {this.lastSyncTime});

  @override
  List<Object?> get props => [notes, notesRaw, lastSyncTime];
}

class ConflictDetectedState extends NoteState {
  final NoteEntity localNote;
  final NoteEntity serverNote;
  final List<NoteEntity> previousNotes;
  const ConflictDetectedState({
    required this.localNote,
    required this.serverNote,
    required this.previousNotes,
  });

  @override
  List<Object?> get props => [localNote, serverNote,previousNotes];
}

class ConflictResolvingState extends NoteState {
  final List<NoteEntity> previousNotes;

  const ConflictResolvingState({required this.previousNotes});

  @override
  List<Object?> get props => [previousNotes];
}

class NoteError extends NoteState {
  final String message;

  const NoteError(this.message);

  @override
  List<Object?> get props => [message];
}

class NoteSyncing extends NoteState {
  final List<NoteEntity> previousNotes;
  const NoteSyncing({required this.previousNotes});
}

class NoteSyncSuccess extends NoteState {}

class NoteOffline extends NoteState {}


class ConflictResolvedSuccess extends NoteState {}

class ConflictResolvedError extends NoteState {
  final String message;

  const ConflictResolvedError(this.message);

  @override
  List<Object?> get props => [message];
}

