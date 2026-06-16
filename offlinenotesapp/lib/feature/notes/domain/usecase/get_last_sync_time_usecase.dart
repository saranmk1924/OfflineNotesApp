import 'package:offlinenotesapp/feature/notes/domain/repository/notes_repository.dart';

/// Use case responsible for retrieving the last synchronization timestamp.
///
/// This provides information about when the application last successfully
/// synced local data with the remote server.
class GetLastSyncTimeUsecase {
  final NotesRepository repository;

  GetLastSyncTimeUsecase(this.repository);

  DateTime? call() {
    return repository.getLastSyncTime();
  }
}
