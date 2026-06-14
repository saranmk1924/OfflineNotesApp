import '../entities/note_entity.dart';
import '../repository/notes_repository.dart';

class CheckConflictUsecase {
  final NotesRepository repository;

  CheckConflictUsecase(this.repository);

  Future<(NoteEntity, NoteEntity)?> call() {
    return repository.checkConflict();
  }
}