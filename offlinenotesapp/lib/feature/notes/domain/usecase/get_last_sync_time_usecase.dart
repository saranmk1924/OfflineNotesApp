import 'package:offlinenotesapp/feature/notes/domain/repository/notes_repository.dart';

class GetLastSyncTimeUsecase {
  final NotesRepository repository;

  GetLastSyncTimeUsecase(this.repository);

  DateTime? call() {
    return repository.getLastSyncTime();
  }
}