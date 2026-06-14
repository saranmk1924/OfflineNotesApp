import '../entities/note_entity.dart';
import '../repository/notes_repository.dart';

class UseLocalVersionUsecase {
  final NotesRepository repository;

  UseLocalVersionUsecase(this.repository);

  Future<void> call(NoteEntity note) {
    return repository.useLocalVersion(note);
  }
}