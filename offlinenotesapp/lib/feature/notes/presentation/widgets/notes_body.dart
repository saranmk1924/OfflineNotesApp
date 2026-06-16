import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offlinenotesapp/core/common/app_loader.dart';
import 'package:offlinenotesapp/core/enums/platform_type.dart';
import 'package:offlinenotesapp/feature/notes/domain/entities/note_entity.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_bloc.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_state.dart';
import 'package:offlinenotesapp/feature/notes/presentation/widgets/add_note_fab_widget.dart';
import 'package:offlinenotesapp/feature/notes/presentation/widgets/conflict_detection_view.dart';
import 'package:offlinenotesapp/feature/notes/presentation/widgets/conflict_resolving_view.dart';
import 'package:offlinenotesapp/feature/notes/presentation/widgets/note_syncing_view.dart';
import 'package:offlinenotesapp/feature/notes/presentation/widgets/notes_empty_view.dart';
import 'package:offlinenotesapp/feature/notes/presentation/widgets/notes_error_view.dart';
import 'package:offlinenotesapp/feature/notes/presentation/widgets/notes_loaded_view.dart';

/// Main body widget for the Notes screen.
///
/// This widget acts as a state router that listens to [NoteBloc] and
/// displays the appropriate UI based on the current state:
/// - Loading
/// - Syncing
/// - Conflict detection/resolution
/// - Error state
/// - Loaded notes
class NotesBody extends StatelessWidget {
  /// Current platform type used for responsive layout decisions.
  final PlatformType platformType;
  const NotesBody({super.key, required this.platformType});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        BlocBuilder<NoteBloc, NoteState>(
          builder: (context, state) {
            /// Initial loading state
            if (state is NoteLoading) {
              return const Center(child: AppLoader());
            }

            /// Sync in progress state
            if (state is NoteSyncing) {
              final List<NoteEntity> notes = state.previousNotes;
              return NoteSyncingView(notes: notes);
            }

            /// Conflict resolution in progress
            if (state is ConflictResolvingState) {
              return ConflictResolvingView(state: state);
            }

            /// Error state
            if (state is NoteError) {
              return NotesErrorView(state: state);
            }

            /// Conflict detected state
            if (state is ConflictDetectedState) {
              return ConflictDetectionView(state: state);
            }

            /// Loaded state
            if (state is NoteLoaded) {
              // Loaded state without notes
              if (state.notes.isEmpty) {
                return NotesEmptyView();
              }
              // Loaded state with notes
              return NotesLoadedView(state: state, platformType: platformType);
            }

            /// Fallback UI
            return const SizedBox.shrink();
          },
        ),

        /// Floating action button for adding notes
        Positioned(bottom: 70, child: AddNoteFabWidget()),
      ],
    );
  }
}
