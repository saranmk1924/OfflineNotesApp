import 'note_entity.dart';

/// Represents a data conflict between local and remote versions of a note.
///
/// This entity is used when both the local and server versions of a note
/// have been modified independently, requiring user or system resolution
/// to determine the correct final state.
class ConflictEntity {
  final NoteEntity localNote;
  final NoteEntity serverNote;

  /// Creates a new [ConflictEntity] representing a sync conflict.
  const ConflictEntity({required this.localNote, required this.serverNote});
}
