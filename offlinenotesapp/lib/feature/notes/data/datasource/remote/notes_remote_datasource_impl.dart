import 'package:dio/dio.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/dio_client.dart';
import '../../models/note_model.dart';
import 'notes_remote_datasource.dart';

class NotesRemoteDataSourceImpl implements NotesRemoteDataSource {
  final DioClient dioClient;

  NotesRemoteDataSourceImpl(this.dioClient);

  Dio get dio => dioClient.dio;

  @override
  Future<List<NoteModel>> getNotes() async {
    final response = await dio.get(ApiConstants.notes);

    return (response.data as List)
        .map((e) => NoteModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<NoteModel> addNote(NoteModel note) async {
    final response = await dio.post(ApiConstants.notes, data: note.toJson());

    return NoteModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  @override
  Future<NoteModel> updateNote(NoteModel note) async {
    final response = await dio.put(
      '${ApiConstants.notes}/${note.id}',
      data: note.toJson(),
    );

    return NoteModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  @override
  Future<void> deleteNote(String id) async {
    await dio.delete('${ApiConstants.notes}/$id');
  }

  @override
  Future<NoteModel?> getNoteById(String id) async {
    try {
      final response = await dio.get('${ApiConstants.notes}/$id');

      return NoteModel.fromJson(Map<String, dynamic>.from(response.data));
    } catch (_) {
      return null;
    }
  }
}
