import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offlinenotesapp/core/common/app_snackbar.dart';
import 'package:offlinenotesapp/core/constants/app_palette.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_bloc.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_event.dart';

/// Dialog used to confirm deletion of a note.
///
/// Displays the note title and asks the user for confirmation before
/// dispatching a delete event to [NoteBloc].
class DeleteConfirmationDialog {
  void show(BuildContext context, String noteId, String noteTitle) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161616),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppPalette.purple),
          ),

          /// Dialog title with delete icon
          title: const Row(
            children: [
              Icon(
                Icons.delete_forever_rounded,
                color: AppPalette.red,
                size: 30,
              ),
              SizedBox(width: 10),
              Text(
                'Delete Note',
                style: TextStyle(
                  color: AppPalette.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          /// Confirmation message and note preview
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to delete this note?',
                style: TextStyle(color: AppPalette.white, fontSize: 16),
              ),

              const SizedBox(height: 16),

              /// Note preview container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppPalette.white24),
                ),
                child: Text(
                  noteTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppPalette.white70,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),

          /// Action buttons
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                side: const BorderSide(color: AppPalette.purple),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppPalette.white),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                backgroundColor: AppPalette.red,
                foregroundColor: AppPalette.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                context.read<NoteBloc>().add(DeleteNoteEvent(noteId));

                Navigator.pop(context);

                AppSnackBar.show(
                  context,
                  message: 'Note Deleted',
                  icon: Icons.delete_outline,
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: AppPalette.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
