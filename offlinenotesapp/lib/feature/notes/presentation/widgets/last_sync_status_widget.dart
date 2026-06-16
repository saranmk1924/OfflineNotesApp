import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_bloc.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_state.dart';
import 'package:timeago_flutter/timeago_flutter.dart';

class LastSyncStatusWidget extends StatelessWidget {
  const LastSyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoteBloc, NoteState>(
      builder: (context, state) {
        if (state is NoteError) {
         return syncMessage(message: 'Sync failed');
        }
        if (state is NoteSyncing) {
         return syncMessage(message: 'Syncing...');
        }

        if (state is ConflictResolvingState || state is ConflictDetectedState) {
         return syncMessage(message: 'Resolving Conflict...');
        }

        if (state is! NoteLoaded) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.sync, size: 18),
              const SizedBox(width: 8),
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
