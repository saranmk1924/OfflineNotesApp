import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../models/note_model.dart';
import 'notes_local_datasource.dart';

class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  final Box notesBox;
  final Box syncBox;

  NotesLocalDataSourceImpl(this.notesBox, this.syncBox);

  @override
  Future<void> addNote(NoteModel note) async {
    await notesBox.put(note.id, note.toJson());
    debugPrint("LOCAL ID => ${note.id}");
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    await notesBox.put(note.id, note.toJson());
  }

  @override
  Future<void> deleteNote(String id) async {
    await notesBox.delete(id);
  }

  @override
  Future<List<NoteModel>> getNotes() async {
    final notes = notesBox.values
        .map((note) => NoteModel.fromJson(Map<String, dynamic>.from(note)))
        .toList();

    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return notes;
  }

  @override
  Future<void> saveNotes(List<NoteModel> notes) async {
    await notesBox.clear();

    for (final note in notes) {
      await notesBox.put(note.id, note.toJson());
    }
  }

  @override
  Future<void> saveLastSyncTime() async {
    await syncBox.put('lastSyncTime', DateTime.now().toIso8601String());
  }

  @override
  DateTime? getLastSyncTime() {
  final value = syncBox.get('lastSyncTime');

  if (value == null) return null;

  return DateTime.parse(value);
}
}
