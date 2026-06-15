import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offlinenotesapp/core/common/app_snackbar.dart';
import 'package:offlinenotesapp/core/constants/app_palette.dart';
import 'package:offlinenotesapp/feature/notes/domain/entities/note_entity.dart';
import 'package:offlinenotesapp/feature/notes/domain/entities/sync_status.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_bloc.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_event.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_state.dart';
import 'package:offlinenotesapp/feature/notes/presentation/cubit/connectivity_cubit.dart';
import 'package:offlinenotesapp/feature/notes/presentation/pages/add_edit_note_page.dart';
import 'package:offlinenotesapp/feature/notes/presentation/pages/conflict_dialog.dart';
import 'package:offlinenotesapp/feature/notes/presentation/pages/notes_list_view.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> with TickerProviderStateMixin {
  late final AnimationController _syncController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _syncController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _syncController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ConnectivityCubit, bool>(
          listener: (context, isConnected) {
            if (isConnected) {
              AppSnackBar.show(
                context,
                message: 'Back to Online - Syncing...',
                icon: Icons.wifi,
              );

              context.read<NoteBloc>().add(SyncNotesEvent());
            } else {
              AppSnackBar.show(
                context,
                message: 'Offline Mode',
                icon: Icons.wifi_off,
              );
            }
          },
        ),

        BlocListener<NoteBloc, NoteState>(
          listener: (context, state) {
            if (state is NoteSyncing) {
              _syncController.repeat();
            }
            if (state is NoteSyncSuccess) {
              _syncController.stop();
              _syncController.reset();

              AppSnackBar.show(
                context,
                message: 'Synced Successfully',
                icon: Icons.check_circle,
              );
            }

            if (state is ConflictDetectedState) {
              _syncController.stop();
              _syncController.reset();

              ConflictDialog().showConflictDialog(
                context,
                state.localNote,
                state.serverNote,
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppPalette.black,
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
                      blurRadius: 15,
                    ),
                    Shadow(
                      color: isConnected ? AppPalette.purple : AppPalette.red,
                      blurRadius: 25,
                    ),
                  ],
                ),
              );
            },
          ),
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
                icon: BlocBuilder<ConnectivityCubit, bool>(
                  builder: (context, isConnected) {
                    return BlocBuilder<NoteBloc, NoteState>(
                      builder: (context, state) {
                        final state = context.watch<NoteBloc>().state;

                        final allNotes = (state is NoteLoaded)
                            ? state
                                  .notesRaw // we will add this
                            : (state is NoteSyncing)
                            ? state.previousNotes
                            : <NoteEntity>[];

                        final pendingCount = allNotes
                            .where((n) => n.syncStatus == SyncStatus.pending)
                            .length;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
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
                                        ? AppPalette.purple.withValues(
                                            alpha: 0.15,
                                          )
                                        : AppPalette.red.withValues(
                                            alpha: 0.15,
                                          ),
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
        ),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            BlocBuilder<NoteBloc, NoteState>(
              builder: (context, state) {
                if (state is NoteLoading) {
                  return const Center(
                    child: CupertinoActivityIndicator(
                      radius: 40,
                      color: AppPalette.purple,
                    ),
                  );
                }

                if (state is NoteSyncing) {
                  final notes = state.previousNotes;

                  return Stack(
                    children: [
                      NotesListView(notes: notes, isDelete: false),
                      const Center(
                        child: CupertinoActivityIndicator(
                          radius: 30,
                          color: AppPalette.purple,
                        ),
                      ),
                    ],
                  );
                }

                if (state is NoteLoaded) {
                  if (state.notes.isEmpty) {
                    return const Center(
                      child: Text(
                        'No Notes Yet',
                        style: TextStyle(
                          color: AppPalette.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                    );
                  }

                  return NotesListView(notes: state.notes, isDelete: true);
                }

                return const SizedBox.shrink();
              },
            ),
            Positioned(
              bottom: 70,
              child: BlocBuilder<NoteBloc, NoteState>(
                builder: (context, state) {
                  return FloatingActionButton(
                    backgroundColor: state is NoteSyncing
                        ? AppPalette.white24
                        : AppPalette.purple,
                    foregroundColor: AppPalette.white,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    onPressed: state is NoteSyncing
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddEditNotePage(),
                              ),
                            );
                          },
                    child: const Icon(Icons.add),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}














//  //dummy check
//               ConflictDialog().showConflictDialog(
//                 context,
//                 NoteEntity(
//                   id: "123",
//                   title: "kjasbfkjas",
//                   body: "dafkjna",
//                   updatedAt: DateTime.now(),
//                   syncStatus: SyncStatus.pending,
//                   isDeleted: false,
//                 ),
//                 NoteEntity(
//                   id: "123",
//                   title: "kjasbfkjas",
//                   body: "dafkjna",
//                   updatedAt: DateTime.now(),
//                   syncStatus: SyncStatus.pending,
//                   isDeleted: false,
//                 ),
//               );