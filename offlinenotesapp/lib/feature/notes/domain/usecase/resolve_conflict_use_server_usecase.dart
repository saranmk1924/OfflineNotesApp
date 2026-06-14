import '../entities/note_entity.dart';
import '../repository/notes_repository.dart';

class ResolveConflictUseServerUsecase {
  final NotesRepository repository;

  ResolveConflictUseServerUsecase(this.repository);

  Future<void> call(NoteEntity note) async {
    await repository.resolveWithServer(note);
  }
}