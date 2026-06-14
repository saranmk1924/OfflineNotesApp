import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/note_entity.dart';
import '../../domain/entities/sync_status.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_event.dart';

class AddEditNotePage extends StatefulWidget {
  final NoteEntity? note;

  const AddEditNotePage({
    super.key,
    this.note,
  });

  @override
  State<AddEditNotePage> createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  late final TextEditingController titleController;
  late final TextEditingController bodyController;

  bool get isEdit => widget.note != null;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.note?.title ?? '',
    );

    bodyController = TextEditingController(
      text: widget.note?.body ?? '',
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  void saveNote() {
    final title = titleController.text.trim();
    final body = bodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      return;
    }

    if (isEdit) {
      final updatedNote = NoteEntity(
        id: widget.note!.id,
        title: title,
        body: body,
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
        isDeleted: false, lastSyncedAt: widget.note?.lastSyncedAt,
      );

      context.read<NoteBloc>().add(
            UpdateNoteEvent(updatedNote),
          );
    } else {
      final note = NoteEntity(
        id: const Uuid().v4(),
        title: title,
        body: body,
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
        isDeleted: false, lastSyncedAt: null,
      );

      context.read<NoteBloc>().add(
            AddNoteEvent(note),
          );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Note' : 'Add Note',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bodyController,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Body',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveNote,
                child: Text(
                  isEdit ? 'Update' : 'Save',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}