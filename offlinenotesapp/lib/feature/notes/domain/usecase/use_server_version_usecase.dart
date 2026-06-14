import '../entities/note_entity.dart';
import '../repository/notes_repository.dart';

class UseServerVersionUsecase {
  final NotesRepository repository;

  UseServerVersionUsecase(this.repository);

  Future<void> call(NoteEntity note) {
    return repository.useServerVersion(note);
  }
}