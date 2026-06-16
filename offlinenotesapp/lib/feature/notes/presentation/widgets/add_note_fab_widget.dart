import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offlinenotesapp/core/constants/app_palette.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_bloc.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_state.dart';
import 'package:offlinenotesapp/feature/notes/presentation/pages/add_edit_note_page.dart';

/// Floating Action Button used to create a new note.
///
/// The button is disabled during sync operations or conflict resolution
/// to prevent data inconsistency.
class AddNoteFabWidget extends StatelessWidget {
  const AddNoteFabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoteBloc, NoteState>(
      builder: (context, state) {
        return FloatingActionButton(
          backgroundColor:
              state is NoteSyncing || state is ConflictResolvingState
              ? AppPalette.white24
              : AppPalette.purple,
          foregroundColor: AppPalette.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),

          /// Disables navigation while syncing or resolving conflicts
          onPressed: state is NoteSyncing || state is ConflictResolvingState
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddEditNotePage()),
                  );
                },
          child: const Icon(Icons.add),
        );
      },
    );
  }
}
