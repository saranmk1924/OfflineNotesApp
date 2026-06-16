import '../entities/note_entity.dart';
import '../repository/notes_repository.dart';

/// Use case responsible for checking synchronization conflicts.
///
/// This identifies cases where both local and remote versions of a note
/// have been modified independently, requiring conflict resolution.
class CheckConflictUsecase {
  final NotesRepository repository;

  CheckConflictUsecase(this.repository);

  Future<(NoteEntity, NoteEntity)?> call() {
    return repository.checkConflict();
  }
}
