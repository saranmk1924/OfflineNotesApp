import '../../domain/entities/note_entity.dart';
import '../../../../core/enums/sync_status.dart';

/// Data model representing a Note in the application.
///
/// Extends [NoteEntity] to include data-layer functionality such as
/// JSON serialization and deserialization for API and local storage.
/// This model acts as a bridge between domain entities and external data sources.
class NoteModel extends NoteEntity {
  /// Creates a new [NoteModel] instance.
  const NoteModel({
    required super.id,
    required super.title,
    required super.body,
    required super.updatedAt,
    required super.syncStatus,
    required super.isDeleted,
    super.lastSyncedAt,
  });

  /// Creates a [NoteModel] from a JSON map (e.g. API response or Hive data).
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      updatedAt: DateTime.parse(json['updatedAt'].toString()),
      syncStatus: SyncStatus.values.firstWhere(
        (status) => status.name == json['syncStatus']?.toString(),
        orElse: () => SyncStatus.pending,
      ),
      isDeleted: json['isDeleted'] ?? false,
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'].toString())
          : null,
    );
  }

  /// Converts this [NoteModel] into a JSON map for storage or API requests.
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

  /// Creates a [NoteModel] from a domain [NoteEntity].
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
  /// Creates a modified copy of this [NoteModel].
  ///
  /// Useful for maintaining immutability while updating specific fields.
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
