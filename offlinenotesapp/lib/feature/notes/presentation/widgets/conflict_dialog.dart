import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offlinenotesapp/core/common/app_snackbar.dart';
import 'package:offlinenotesapp/core/constants/app_palette.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_bloc.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_event.dart';
import 'package:offlinenotesapp/feature/notes/presentation/cubit/connectivity_cubit.dart';

/// Dialog used to resolve conflicts between local and server note versions.
///
/// Displays both versions side-by-side and allows the user to choose
/// either the local or server version as the final source of truth.
class ConflictDialog {
  void showConflictDialog(
    BuildContext context,
    dynamic localNote,
    dynamic serverNote,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161616),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppPalette.purple),
          ),

          /// Dialog title with warning indicator
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppPalette.red,
                size: 30,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(width: 10),
              Text(
                'Conflict Detected',
                style: TextStyle(
                  color: AppPalette.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          /// Displays both local and server versions of the note
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localNote.isDeleted
                      ? 'This note was deleted on this device but modified on another device.'
                      : 'Both local and server versions were modified.',
                  style: const TextStyle(color: AppPalette.white, fontSize: 17),
                ),

                const SizedBox(height: 20),

                /// Local version section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppPalette.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Local Version',
                        style: TextStyle(
                          color: AppPalette.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      if (localNote.isDeleted)
                        const Text(
                          '🗑️ Note Deleted',
                          style: TextStyle(
                            color: AppPalette.red,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else ...[
                        Text(
                          localNote.title,
                          style: const TextStyle(
                            color: AppPalette.white70,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          localNote.body,
                          style: const TextStyle(
                            color: AppPalette.white70,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const Divider(),

                /// Server version section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppPalette.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Server Version',
                        style: TextStyle(
                          color: AppPalette.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      if (serverNote.isDeleted)
                        const Text(
                          '🗑️ Note Deleted',
                          style: TextStyle(
                            color: AppPalette.red,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else ...[
                        Text(
                          serverNote.title,
                          style: const TextStyle(
                            color: AppPalette.white70,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          serverNote.body,
                          style: const TextStyle(
                            color: AppPalette.white70,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// Action buttons for resolving conflict
          actions: [
            /// Use local version button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                backgroundColor: AppPalette.purple,
                foregroundColor: AppPalette.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final isConnected = context.read<ConnectivityCubit>().state;

                if (!isConnected) {
                  AppSnackBar.show(
                    context,
                    message: 'Failed to resolve conflict',
                    icon: Icons.wifi_off,
                  );
                  Navigator.pop(context);
                  return;
                }

                context.read<NoteBloc>().add(UseLocalVersionEvent(localNote));
                Navigator.pop(context);
              },
              child: Text('Use Local'),
            ),

            /// Use server version button
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
                final isConnected = context.read<ConnectivityCubit>().state;

                if (!isConnected) {
                  AppSnackBar.show(
                    context,
                    message: 'Failed to resolve conflict',
                    icon: Icons.wifi_off,
                  );
                  Navigator.pop(context);
                  return;
                }

                context.read<NoteBloc>().add(UseServerVersionEvent(serverNote));
                Navigator.pop(context);
              },
              child: Text('Use Server'),
            ),
          ],
        );
      },
    );
  }
}
