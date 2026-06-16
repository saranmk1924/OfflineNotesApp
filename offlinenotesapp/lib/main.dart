import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:offlinenotesapp/core/constants/hive_constants.dart';
import 'package:offlinenotesapp/core/dependency/init_dependencies.dart';
import 'package:offlinenotesapp/core/theme/app_theme.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_bloc.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_event.dart';
import 'package:offlinenotesapp/feature/notes/presentation/cubit/connectivity_cubit.dart';
import 'package:offlinenotesapp/feature/notes/presentation/pages/notes_page.dart';

/// Entry point of the application
/// This is where:
/// 1. Flutter bindings are initialized
/// 2. Local storage (Hive) is set up
/// 3. Dependency injection is configured
/// 4. The root widget is launched
Future<void> main() async {
  // Ensures Flutter engine is initialized before any async/native calls
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize Hive (lightweight NoSQL DB for offline storage)
  /// Used here for storing notes locally and app metadata
  await Hive.initFlutter();

  /// Open persistent storage boxes:
  /// - notesBox: stores all notes (CRUD + sync state)
  /// - appBox: stores app-level metadata (e.g. last sync time)
  final notesBox = await Hive.openBox(HiveConstants.notesBox);
  final appBox = await Hive.openBox(HiveConstants.appBox);

  /// Initialize dependency injection container
  /// This wires up:
  /// - repositories
  /// - data sources (local + remote)
  /// - blocs/cubits
  /// - use cases
  await initDependencies(notesBox, appBox);

  /// Launch the application root widget
  runApp(const OfflineNotesApp());
}

/// Root widget of the application
/// Responsible for:
/// - Providing global Bloc instances
/// - Defining app theme
/// - Setting initial screen
class OfflineNotesApp extends StatelessWidget {
  const OfflineNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        /// Notes BLoC:
        /// - Handles all note operations (CRUD + sync + conflict resolution)
        /// - Automatically loads notes on startup
        BlocProvider<NoteBloc>(
          create: (_) => sl<NoteBloc>()..add(LoadNotesEvent()),
        ),

        /// Connectivity Cubit:
        /// - Listens to network changes
        /// - Triggers sync when device comes online
        BlocProvider(create: (_) => sl<ConnectivityCubit>()),
      ],
      child: MaterialApp(
        /// Removes debug banner in release-like UI
        debugShowCheckedModeBanner: false,

        /// Global app theme (dark mode UI for notes app)
        theme: AppTheme.darkTheme,

        /// Initial screen of the application
        home: const NotesPage(),
      ),
    );
  }
}
