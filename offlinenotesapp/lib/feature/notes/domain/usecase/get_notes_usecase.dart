import '../entities/note_entity.dart';
import '../repository/notes_repository.dart';

class GetNotesUsecase {
  final NotesRepository repository;

  GetNotesUsecase(this.repository);

  Future<List<NoteEntity>> call() async {
    return await repository.getNotes();
  }
}