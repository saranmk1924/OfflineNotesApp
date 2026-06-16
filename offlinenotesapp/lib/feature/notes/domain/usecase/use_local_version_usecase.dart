import '../entities/note_entity.dart';
import '../repository/notes_repository.dart';

/// Use case responsible for resolving a sync conflict by choosing the local version.
///
/// This ensures that the locally stored note is treated as the source of truth
/// and is pushed to the remote server during conflict resolution.
class UseLocalVersionUsecase {
  final NotesRepository repository;

  UseLocalVersionUsecase(this.repository);

  Future<void> call(NoteEntity note) {
    return repository.useLocalVersion(note);
  }
}
