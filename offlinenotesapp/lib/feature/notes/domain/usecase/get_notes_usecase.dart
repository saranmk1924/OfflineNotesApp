import '../entities/note_entity.dart';
import '../repository/notes_repository.dart';

/// Use case responsible for retrieving all notes.
///
/// This encapsulates the business logic for fetching notes from the
/// repository, which may include local storage, remote source, or both.
class GetNotesUsecase {
  final NotesRepository repository;

  GetNotesUsecase(this.repository);

  Future<List<NoteEntity>> call() async {
    return await repository.getNotes();
  }
}
