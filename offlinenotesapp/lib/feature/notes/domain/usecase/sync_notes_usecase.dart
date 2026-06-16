import '../entities/conflict_entity.dart';
import '../repository/notes_repository.dart';

/// Use case responsible for synchronizing local notes with the remote server.
///
/// This triggers the full sync process, including uploading local changes,
/// fetching remote updates, and detecting conflicts if any arise.
class SyncNotesUsecase {
  final NotesRepository repository;

  SyncNotesUsecase(this.repository);

  Future<ConflictEntity?> call() async {
    return await repository.syncNotes();
  }
}
