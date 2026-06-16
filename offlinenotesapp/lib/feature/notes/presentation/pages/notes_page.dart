import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offlinenotesapp/core/common/app_snackbar.dart';
import 'package:offlinenotesapp/core/enums/platform_type.dart';
import 'package:offlinenotesapp/core/responsiveness/responsive_sizes.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_bloc.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_event.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_state.dart';
import 'package:offlinenotesapp/feature/notes/presentation/cubit/connectivity_cubit.dart';
import 'package:offlinenotesapp/feature/notes/presentation/widgets/conflict_dialog.dart';
import 'package:offlinenotesapp/feature/notes/presentation/widgets/notes_app_bar.dart';
import 'package:offlinenotesapp/feature/notes/presentation/widgets/notes_body.dart';

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
            if (state is NoteError) {
              AppSnackBar.show(
                context,
                message: state.message,
                icon: Icons.error,
              );
            }
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
            if (state is ConflictResolvedSuccess) {
              AppSnackBar.show(
                context,
                message: 'Conflict resolved successfully',
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
        appBar: NotesAppBar(
          syncController: _syncController,
          pulseAnimation: _pulseAnimation,
        ),

        body: NotesBody(
          platformType: ResponsiveSizes.isMobile(context)
              ? PlatformType.mobile
              : ResponsiveSizes.isTablet(context)
              ? PlatformType.tablet
              : ResponsiveSizes.isDesktop(context)
              ? PlatformType.desktop
              : ResponsiveSizes.isUltrahd(context)
              ? PlatformType.ultrahd
              : PlatformType.mobile,
        ),
      ),
    );
  }
}



//dummy check
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