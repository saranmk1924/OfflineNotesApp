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

  const NoteLoaded(this.notes);

  @override
  List<Object?> get props => [notes];
}

class ConflictDetectedState extends NoteState {
  final NoteEntity localNote;
  final NoteEntity serverNote;

  const ConflictDetectedState({
    required this.localNote,
    required this.serverNote,
  });

  @override
  List<Object?> get props => [
        localNote,
        serverNote,
      ];
}

class NoteError extends NoteState {
  final String message;

  const NoteError(this.message);

  @override
  List<Object?> get props => [message];
}

class NoteConflict extends NoteState {
  final NoteEntity localNote;
  final NoteEntity serverNote;

  const NoteConflict({
    required this.localNote,
    required this.serverNote,
  });

  @override
  List<Object?> get props => [
        localNote,
        serverNote,
      ];
}