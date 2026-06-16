import '../entities/note_entity.dart';
import '../repository/notes_repository.dart';

/// Use case responsible for resolving a sync conflict by choosing the server version.
///
/// This ensures that the remote (server) version of the note is treated as the
/// source of truth and is applied to the local storage during conflict resolution.
class UseServerVersionUsecase {
  final NotesRepository repository;

  UseServerVersionUsecase(this.repository);

  Future<void> call(NoteEntity note) {
    return repository.useServerVersion(note);
  }
}
