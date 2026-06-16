import '../entities/note_entity.dart';
import '../repository/notes_repository.dart';

/// Use case responsible for updating an existing note.
///
/// This encapsulates the business logic for modifying note data and
/// delegates the update operation to the [NotesRepository].
class UpdateNoteUsecase {
  final NotesRepository repository;

  UpdateNoteUsecase(this.repository);

  Future<void> call(NoteEntity note) async {
    await repository.updateNote(note);
  }
}
