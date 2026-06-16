import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:offlinenotesapp/core/network/connectivity_service.dart';
import 'package:offlinenotesapp/core/network/dio_client.dart';
import 'package:offlinenotesapp/feature/notes/data/datasource/remote/notes_remote_datasource.dart';
import 'package:offlinenotesapp/feature/notes/data/datasource/remote/notes_remote_datasource_impl.dart';
import 'package:offlinenotesapp/feature/notes/domain/usecase/add_note_usecase.dart';
import 'package:offlinenotesapp/feature/notes/domain/usecase/check_conflict_usecase.dart';
import 'package:offlinenotesapp/feature/notes/domain/usecase/delete_note_usecase.dart';
import 'package:offlinenotesapp/feature/notes/domain/usecase/get_last_sync_time_usecase.dart';
import 'package:offlinenotesapp/feature/notes/domain/usecase/get_notes_usecase.dart';
import 'package:offlinenotesapp/feature/notes/domain/usecase/sync_notes_usecase.dart';
import 'package:offlinenotesapp/feature/notes/domain/usecase/update_note_usecase.dart';
import 'package:offlinenotesapp/feature/notes/domain/usecase/use_local_version_usecase.dart';
import 'package:offlinenotesapp/feature/notes/domain/usecase/use_server_version_usecase.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_bloc.dart';
import 'package:offlinenotesapp/feature/notes/presentation/cubit/connectivity_cubit.dart';

import '../../feature/notes/data/datasource/local/notes_local_datasource.dart';
import '../../feature/notes/data/datasource/local/notes_local_datasource_impl.dart';
import '../../feature/notes/data/repository/notes_repository_impl.dart';
import '../../feature/notes/domain/repository/notes_repository.dart';

/// Global service locator instance used for dependency injection
/// throughout the application.
final sl = GetIt.instance;

/// Registers and initializes all application dependencies.
///
/// This includes:
/// - Core services
/// - Data sources
/// - Repositories
/// - Use cases
/// - BLoCs and Cubits
///
/// [notesBox] is used for storing notes locally.
/// [appBox] is used for storing app-level preferences and metadata.
Future<void> initDependencies(Box notesBox, Box appBox) async {
  /// Core network client.
  sl.registerLazySingleton(DioClient.new);

  /// Local data source responsible for Hive operations.
  sl.registerLazySingleton<NotesLocalDataSource>(
    () => NotesLocalDataSourceImpl(notesBox, appBox),
  );

  /// Remote data source responsible for API operations.
  sl.registerLazySingleton<NotesRemoteDataSource>(
    () => NotesRemoteDataSourceImpl(sl()),
  );

  /// Repository implementation that coordinates local and remote data.
  sl.registerLazySingleton<NotesRepository>(
    () => NotesRepositoryImpl(sl(), sl()),
  );

  /// Note management use cases.
  sl.registerLazySingleton(() => AddNoteUsecase(sl()));
  sl.registerLazySingleton(() => UpdateNoteUsecase(sl()));
  sl.registerLazySingleton(() => DeleteNoteUsecase(sl()));
  sl.registerLazySingleton(() => GetNotesUsecase(sl()));
  sl.registerLazySingleton(() => SyncNotesUsecase(sl()));
  sl.registerLazySingleton(() => GetLastSyncTimeUsecase(sl()));
  sl.registerLazySingleton(() => CheckConflictUsecase(sl()));
  sl.registerLazySingleton(() => UseLocalVersionUsecase(sl()));
  sl.registerLazySingleton(() => UseServerVersionUsecase(sl()));

  /// Factory registration ensures a new BLoC instance is created
  /// whenever it is requested.
  sl.registerFactory(
    () => NoteBloc(
      addNote: sl(),
      updateNote: sl(),
      deleteNote: sl(),
      getNotes: sl(),
      syncNotes: sl(),
      checkConflict: sl(),
      useLocalVersion: sl(),
      useServerVersion: sl(),
      getLastSyncTime: sl(),
    ),
  );

  /// Connectivity plugin for monitoring network status.
  sl.registerLazySingleton(Connectivity.new);

  /// Service that wraps connectivity-related functionality.
  sl.registerLazySingleton(() => ConnectivityService(sl()));

  /// Cubit responsible for exposing connectivity state to the UI.
  sl.registerLazySingleton(() => ConnectivityCubit(sl()));
}
