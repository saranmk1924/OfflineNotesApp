import '../entities/note_entity.dart';
import '../repository/notes_repository.dart';
/// Use case responsible for adding a new note.
///
/// This encapsulates the business logic for creating a note and
/// delegates the actual data operation to the [NotesRepository].
class AddNoteUsecase {
  final NotesRepository repository;

  AddNoteUsecase(this.repository);

  Future<void> call(NoteEntity note) async {
    await repository.addNote(note);
  }
}
