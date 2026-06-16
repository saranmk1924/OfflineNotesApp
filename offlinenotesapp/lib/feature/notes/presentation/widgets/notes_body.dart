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

class NotesBody extends StatelessWidget {
  final PlatformType platformType;
  const NotesBody({super.key, required this.platformType});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        BlocBuilder<NoteBloc, NoteState>(
          builder: (context, state) {
            if (state is NoteLoading) {
              return const Center(child: AppLoader());
            }

            if (state is NoteSyncing) {
              final List<NoteEntity> notes = state.previousNotes;
              return NoteSyncingView(notes: notes);
            }

            if (state is ConflictResolvingState) {
              return ConflictResolvingView(state: state);
            }

            if (state is NoteError) {
              return NotesErrorView(state: state);
            }

            if (state is ConflictDetectedState) {
              return ConflictDetectionView(state: state);
            }

            if (state is NoteLoaded) {
              if (state.notes.isEmpty) {
                return NotesEmptyView();
              }

              return NotesLoadedView(state: state, platformType: platformType,);
            }

            return const SizedBox.shrink();
          },
        ),
        Positioned(bottom: 70, child: AddNoteFabWidget()),
      ],
    );
  }
}
