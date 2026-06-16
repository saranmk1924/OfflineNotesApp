import 'package:equatable/equatable.dart';

import '../../domain/entities/note_entity.dart';

/// Base class for all states emitted by the NoteBloc.
///
/// Represents the different UI states of the notes feature such as
/// loading, loaded, syncing, conflict detection, and error states.
abstract class NoteState extends Equatable {
  /// Creates a base [NoteState].
  const NoteState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any action is performed.
class NoteInitial extends NoteState {}

/// State when notes are being loaded or a background operation is running.
class NoteLoading extends NoteState {}

/// State when notes are successfully loaded.
///
/// Contains both filtered and raw note lists along with last sync time.
class NoteLoaded extends NoteState {
  final List<NoteEntity> notes;
  final List<NoteEntity> notesRaw;
  final DateTime? lastSyncTime;

  const NoteLoaded(this.notes, this.notesRaw, {this.lastSyncTime});

  @override
  List<Object?> get props => [notes, notesRaw, lastSyncTime];
}

/// State when a conflict between local and server data is detected.
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
  List<Object?> get props => [localNote, serverNote, previousNotes];
}

/// State when conflict resolution is in progress.
class ConflictResolvingState extends NoteState {
  final List<NoteEntity> previousNotes;

  const ConflictResolvingState({required this.previousNotes});

  @override
  List<Object?> get props => [previousNotes];
}

/// State when an error occurs during note operations.
class NoteError extends NoteState {
  final String message;
  final List<NoteEntity> previousNotes;

  const NoteError(this.message, {required this.previousNotes});

  @override
  List<Object?> get props => [message];
}

/// State when notes are being synchronized.
class NoteSyncing extends NoteState {
  final List<NoteEntity> previousNotes;
  const NoteSyncing({required this.previousNotes});
}

/// State when synchronization completes successfully.
class NoteSyncSuccess extends NoteState {}

/// State when the app is operating in offline mode.
class NoteOffline extends NoteState {}

/// State when conflict resolution succeeds.
class ConflictResolvedSuccess extends NoteState {}

/// State when conflict resolution fails.
class ConflictResolvedError extends NoteState {
  final String message;

  const ConflictResolvedError(this.message);

  @override
  List<Object?> get props => [message];
}
