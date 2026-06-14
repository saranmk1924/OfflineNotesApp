import '../entities/note_entity.dart';
import '../repository/notes_repository.dart';

class UpdateNoteUsecase {
  final NotesRepository repository;

  UpdateNoteUsecase(this.repository);

  Future<void> call(NoteEntity note) async {
    await repository.updateNote(note);
  }
}