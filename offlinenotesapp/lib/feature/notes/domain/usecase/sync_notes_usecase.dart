import '../repository/notes_repository.dart';

class SyncNotesUsecase {
  final NotesRepository repository;

  SyncNotesUsecase(this.repository);

  Future<void> call() async {
    await repository.syncNotes();
  }
}