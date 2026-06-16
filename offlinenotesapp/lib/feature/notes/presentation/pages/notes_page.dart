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

/// Main page that displays the list of notes and handles syncing,
/// connectivity changes, and conflict resolution.
///
/// This page listens to:
/// - Network connectivity changes
/// - NoteBloc state changes (sync, errors, conflicts)
class NotesPage extends StatefulWidget {
  /// Creates the NotesPage.
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> with TickerProviderStateMixin {
  /// Controls sync animation (rotation/loading indicator).
  late final AnimationController _syncController;

  /// Controls pulsing animation for UI elements.
  late final AnimationController _pulseController;

  /// Tween animation for pulsing effect.
  late final Animation<double> _pulseAnimation;

  @override
  /// Initializes animation controllers and pulse animation.
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
  /// Disposes animation controllers to free resources.
  void dispose() {
    _syncController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  /// Builds the Notes UI with connectivity and sync listeners.
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        /// Listens for network connectivity changes.
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

        /// Listens for note-related state changes.
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

      /// Main scaffold containing app bar and notes body.
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
