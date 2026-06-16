import '../../domain/entities/note_entity.dart';
import '../../../../core/enums/sync_status.dart';

class NoteModel extends NoteEntity {
  const NoteModel({
    required super.id,
    required super.title,
    required super.body,
    required super.updatedAt,
    required super.syncStatus,
    required super.isDeleted,
    super.lastSyncedAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      updatedAt: DateTime.parse(
        json['updatedAt'].toString(),
      ),
      syncStatus: SyncStatus.values.firstWhere(
        (status) => status.name == json['syncStatus']?.toString(),
        orElse: () => SyncStatus.pending,
      ),
      isDeleted: json['isDeleted'] ?? false,
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(
              json['lastSyncedAt'].toString(),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'updatedAt': updatedAt.toIso8601String(),
      'syncStatus': syncStatus.name,
      'isDeleted': isDeleted,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }

  factory NoteModel.fromEntity(NoteEntity entity) {
    return NoteModel(
      id: entity.id,
      title: entity.title,
      body: entity.body,
      updatedAt: entity.updatedAt,
      syncStatus: entity.syncStatus,
      isDeleted: entity.isDeleted,
      lastSyncedAt: entity.lastSyncedAt,
    );
  }

  @override
  NoteModel copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
    bool? isDeleted,
    DateTime? lastSyncedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}