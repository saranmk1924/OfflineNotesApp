import '../repository/notes_repository.dart';

class DeleteNoteUsecase {
  final NotesRepository repository;

  DeleteNoteUsecase(this.repository);

  Future<void> call(String id) async {
    await repository.deleteNote(id);
  }
}