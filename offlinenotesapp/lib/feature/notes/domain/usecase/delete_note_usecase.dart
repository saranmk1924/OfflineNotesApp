import '../repository/notes_repository.dart';

/// Use case responsible for deleting a note.
///
/// This encapsulates the business logic for removing a note by its ID
/// and delegates the operation to the [NotesRepository].
class DeleteNoteUsecase {
  final NotesRepository repository;

  DeleteNoteUsecase(this.repository);

  Future<void> call(String id) async {
    await repository.deleteNote(id);
  }
}
