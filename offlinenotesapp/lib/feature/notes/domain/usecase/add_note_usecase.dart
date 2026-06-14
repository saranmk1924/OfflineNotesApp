import '../entities/note_entity.dart';
import '../repository/notes_repository.dart';

class AddNoteUsecase {
  final NotesRepository repository;

  AddNoteUsecase(this.repository);

  Future<void> call(NoteEntity note) async {
    await repository.addNote(note);
  }
}