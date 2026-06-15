import 'package:flutter/material.dart';
import 'package:offlinenotesapp/core/constants/app_palette.dart';
import 'package:offlinenotesapp/feature/notes/domain/entities/note_entity.dart';
import 'package:offlinenotesapp/feature/notes/domain/entities/sync_status.dart';
import 'package:offlinenotesapp/feature/notes/presentation/pages/add_edit_note_page.dart';
import 'package:offlinenotesapp/feature/notes/presentation/pages/delete_confirmation_dialog.dart';

class NotesListView extends StatelessWidget {
  final List<NoteEntity> notes;
  final bool isDelete;
  const NotesListView({super.key, required this.notes, required this.isDelete});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (_, index) {
        final note = notes[index];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppPalette.purple, width: 0.8),
          ),
          child: Material(
            color: AppPalette.cardBackground,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: isDelete
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditNotePage(note: note),
                        ),
                      );
                    }
                  : null,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppPalette.purple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    note.syncStatus == SyncStatus.synced
                        ? Icons.cloud_done
                        : Icons.cloud_upload,
                    color: note.syncStatus == SyncStatus.synced
                        ? AppPalette.purple
                        : AppPalette.red,
                  ),
                ),
                title: Text(
                  note.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppPalette.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    note.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppPalette.white70),
                  ),
                ),

                trailing: Opacity(
                  opacity: isDelete ? 1.0 : 0.2,

                  child: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppPalette.white70,
                    ),
                    onPressed: isDelete
                        ? () {
                            DeleteConfirmationDialog().show(
                              context,
                              note.id,
                              note.title,
                            );
                          }
                        : null,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
