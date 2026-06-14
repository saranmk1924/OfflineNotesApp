import '../entities/conflict_entity.dart';
import '../repository/notes_repository.dart';

class SyncNotesUsecase {
  final NotesRepository repository;

  SyncNotesUsecase(this.repository);

  Future<ConflictEntity?> call() async {
    return await repository.syncNotes();
  }
}