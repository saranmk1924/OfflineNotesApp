import 'package:dio/dio.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/dio_client.dart';
import '../../models/note_model.dart';
import 'notes_remote_datasource.dart';

/// Remote data source implementation for handling notes API operations.
///
/// Uses [DioClient] to communicate with the backend API and perform
/// CRUD operations for notes. This layer is responsible only for
/// network communication and data mapping.
class NotesRemoteDataSourceImpl implements NotesRemoteDataSource {
  /// Dio client wrapper used for HTTP requests.
  final DioClient dioClient;

  /// Creates a new instance of [NotesRemoteDataSourceImpl].
  NotesRemoteDataSourceImpl(this.dioClient);

  /// Convenience getter for accessing the underlying Dio instance.
  Dio get dio => dioClient.dio;

  @override
  /// Fetches all notes from the remote server.
  Future<List<NoteModel>> getNotes() async {
    final response = await dio.get(ApiConstants.notes);

    return (response.data as List)
        .map((e) => NoteModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  /// Sends a request to create a new note on the server.
  Future<NoteModel> addNote(NoteModel note) async {
    final response = await dio.post(ApiConstants.notes, data: note.toJson());

    return NoteModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  @override
  /// Updates an existing note on the server.
  Future<NoteModel> updateNote(NoteModel note) async {
    final response = await dio.put(
      '${ApiConstants.notes}/${note.id}',
      data: note.toJson(),
    );

    return NoteModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  @override
  /// Deletes a note from the remote server using its [id].
  Future<void> deleteNote(String id) async {
    await dio.delete('${ApiConstants.notes}/$id');
  }

  @override
  /// Fetches a single note by its [id].
  ///
  /// Returns `null` if the note does not exist or an error occurs.
  Future<NoteModel?> getNoteById(String id) async {
    try {
      final response = await dio.get('${ApiConstants.notes}/$id');

      return NoteModel.fromJson(Map<String, dynamic>.from(response.data));
    } catch (_) {
      return null;
    }
  }
}
