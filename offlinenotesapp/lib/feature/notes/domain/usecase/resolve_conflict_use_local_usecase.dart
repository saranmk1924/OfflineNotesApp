import '../entities/note_entity.dart';
import '../repository/notes_repository.dart';

class ResolveConflictUseLocalUsecase {
  final NotesRepository repository;

  ResolveConflictUseLocalUsecase(this.repository);

  Future<void> call(NoteEntity note) async {
    await repository.resolveWithLocal(note);
  }
}