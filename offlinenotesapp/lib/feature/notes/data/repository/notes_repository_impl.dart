import '../../domain/entities/note_entity.dart';
import '../../domain/repository/notes_repository.dart';
import '../datasource/local/notes_local_datasource.dart';
import '../models/note_model.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource localDataSource;

  NotesRepositoryImpl(this.localDataSource);

  @override
  Future<void> addNote(NoteEntity note) async {
    await localDataSource.addNote(
      NoteModel.fromEntity(note),
    );
  }

  @override
  Future<void> updateNote(NoteEntity note) async {
    await localDataSource.updateNote(
      NoteModel.fromEntity(note),
    );
  }

  @override
  Future<void> deleteNote(String id) async {
    await localDataSource.deleteNote(id);
  }

  @override
  Future<List<NoteEntity>> getNotes() async {
    return await localDataSource.getNotes();
  }
}