import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_bloc.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_state.dart';
import 'package:timeago_flutter/timeago_flutter.dart';

/// Widget that displays the current sync status of notes.
///
/// It reacts to [NoteBloc] state changes and shows:
/// - Sync progress (syncing, resolving conflicts, errors)
/// - Last successful sync time when available
class LastSyncStatusWidget extends StatelessWidget {
  const LastSyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoteBloc, NoteState>(
      builder: (context, state) {
        /// Show error state message
        if (state is NoteError) {
          return syncMessage(message: 'Sync failed');
        }

        /// Show syncing state message
        if (state is NoteSyncing) {
          return syncMessage(message: 'Syncing...');
        }

        /// Show conflict resolution state message
        if (state is ConflictResolvingState || state is ConflictDetectedState) {
          return syncMessage(message: 'Resolving Conflict...');
        }

        /// Hide widget if notes are not loaded yet

        if (state is! NoteLoaded) {
          return const SizedBox.shrink();
        }

        /// Show last sync time
        return Padding(
          padding: const EdgeInsets.only(
            left: 26,
            right: 26,
            top: 8,
            bottom: 5,
          ),
          child: Row(
            children: [
              const Icon(Icons.sync, size: 18),
              const SizedBox(width: 8),

              /// If never synced
              if (state.lastSyncTime == null)
                const Text('Never Synced')
              else ...[
                Timeago(
                  date: state.lastSyncTime!,
                  refreshRate: const Duration(minutes: 1),
                  builder: (context, value) {
                    return Text('Last Synced: $value');
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Builds a simple sync status message row.
  Widget syncMessage({required String message}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 26, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.sync, size: 18),
          SizedBox(width: 8),
          Text(message),
        ],
      ),
    );
  }
}
