import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:offlinenotesapp/core/constants/hive_constants.dart';
import 'package:offlinenotesapp/core/dependency/init_dependencies.dart';
import 'package:offlinenotesapp/core/theme/app_theme.dart';
import 'package:offlinenotesapp/feature/notes/data/datasource/remote/notes_remote_datasource.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_bloc.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_event.dart';
import 'package:offlinenotesapp/feature/notes/presentation/pages/notes_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  final notesBox = await Hive.openBox(HiveConstants.notesBox);

  await initDependencies(notesBox);

//   //testing

//   final remoteDatasource =
//     sl<NotesRemoteDataSource>();

// final notes =
//     await remoteDatasource.getNotes();

// debugPrint(
//   'SERVER NOTES COUNT : ${notes.length}',
// );

  runApp(const OfflineNotesApp());
}

class OfflineNotesApp extends StatelessWidget {
  const OfflineNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NoteBloc>(
          create: (_) => sl<NoteBloc>()..add(LoadNotesEvent()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const NotesPage(),
      ),
    );
  }
}
