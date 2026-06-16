import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offlinenotesapp/core/common/app_snackbar.dart';
import 'package:offlinenotesapp/core/constants/app_palette.dart';
import 'package:offlinenotesapp/feature/notes/domain/entities/note_entity.dart';
import 'package:offlinenotesapp/core/enums/sync_status.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_bloc.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_event.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_state.dart';
import 'package:offlinenotesapp/feature/notes/presentation/cubit/connectivity_cubit.dart';

/// Custom AppBar for the Notes feature.
///
/// Shows:
/// - Connectivity status (online/offline)
/// - App title
/// - Sync action button with pending sync indicator
class NotesAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AnimationController _syncController;
  final Animation<double> _pulseAnimation;
  const NotesAppBar({
    super.key,
    required this._syncController,
    required this._pulseAnimation,
  });
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppPalette.black,

      /// Connectivity indicator (wifi / offline)
      leadingWidth: 50,
      leading: BlocBuilder<ConnectivityCubit, bool>(
        builder: (context, isConnected) {
          return Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Icon(
              isConnected ? Icons.wifi : Icons.wifi_off,
              size: 28,
              color: isConnected ? AppPalette.purple : AppPalette.red,
              shadows: [
                Shadow(
                  color: isConnected ? AppPalette.purple : AppPalette.red,
                  blurRadius: 10,
                ),
                Shadow(
                  color: isConnected ? AppPalette.purple : AppPalette.red,
                  blurRadius: 0,
                ),
              ],
            ),
          );
        },
      ),

      /// App title
      title: Padding(
        padding: const EdgeInsets.only(left: 0),
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppPalette.white, AppPalette.white],
          ).createShader(bounds),
          child: const Text(
            'Notes',
            style: TextStyle(
              color: AppPalette.white,
              fontWeight: FontWeight.w600,
              fontSize: 28,
            ),
          ),
        ),
      ),

      /// Sync action button
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            onPressed: () {
              final isConnected = context.read<ConnectivityCubit>().state;

              if (!isConnected) {
                AppSnackBar.show(
                  context,
                  message: 'Offline Mode',
                  icon: Icons.wifi_off,
                );
                return;
              }
              context.read<NoteBloc>().add(SyncNotesEvent());
            },

            /// Sync icon with animation + pending badge
            icon: BlocBuilder<ConnectivityCubit, bool>(
              builder: (context, isConnected) {
                return BlocBuilder<NoteBloc, NoteState>(
                  builder: (context, state) {
                    final state = context.watch<NoteBloc>().state;

                    final allNotes = (state is NoteLoaded)
                        ? state.notesRaw
                        : (state is NoteSyncing)
                        ? state.previousNotes
                        : <NoteEntity>[];

                    final pendingCount = allNotes
                        .where((n) => n.syncStatus == SyncStatus.pending)
                        .length;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        /// Rotating + pulsing sync icon
                        ScaleTransition(
                          scale: (isConnected && pendingCount > 0)
                              ? _pulseAnimation
                              : const AlwaysStoppedAnimation(1.0),
                          child: RotationTransition(
                            turns: _syncController,
                            child: Container(
                              padding: const EdgeInsets.all(8),

                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isConnected
                                    ? AppPalette.purple.withValues(alpha: 0.15)
                                    : AppPalette.red.withValues(alpha: 0.15),
                                border: Border.all(
                                  color: isConnected
                                      ? AppPalette.purple
                                      : AppPalette.red,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isConnected
                                        ? AppPalette.purple.withValues(
                                            alpha: 0.35,
                                          )
                                        : AppPalette.red.withValues(
                                            alpha: 0.35,
                                          ),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.sync,
                                color: isConnected
                                    ? AppPalette.white
                                    : AppPalette.red,
                              ),
                            ),
                          ),
                        ),

                        /// Pending sync count badge
                        if (pendingCount > 0 && isConnected)
                          Positioned(
                            top: -4,
                            right: -12,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppPalette.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                pendingCount.toString(),
                                style: TextStyle(
                                  color: AppPalette.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
