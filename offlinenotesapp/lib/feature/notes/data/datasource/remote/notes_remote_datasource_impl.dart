import 'package:dio/dio.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/dio_client.dart';
import '../../models/note_model.dart';
import 'notes_remote_datasource.dart';

class NotesRemoteDataSourceImpl
    implements NotesRemoteDataSource {
  final DioClient dioClient;

  NotesRemoteDataSourceImpl(
    this.dioClient,
  );

  Dio get dio => dioClient.dio;

  @override
  Future<List<NoteModel>> getNotes() async {
    final response = await dio.get(
      ApiConstants.notes,
    );

    return (response.data as List)
        .map(
          (e) => NoteModel.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }

  @override
  Future<void> addNote(
    NoteModel note,
  ) async {
    await dio.post(
      ApiConstants.notes,
      data: note.toJson(),
    );
  }

  @override
  Future<void> updateNote(
    NoteModel note,
  ) async {
    await dio.put(
      '${ApiConstants.notes}/${note.id}',
      data: note.toJson(),
    );
  }

  @override
  Future<void> deleteNote(
    String id,
  ) async {
    await dio.delete(
      '${ApiConstants.notes}/$id',
    );
  }
}