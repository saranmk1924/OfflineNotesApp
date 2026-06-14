import 'note_entity.dart';

class ConflictEntity {
  final NoteEntity localNote;
  final NoteEntity serverNote;

  const ConflictEntity({
    required this.localNote,
    required this.serverNote,
  });
}