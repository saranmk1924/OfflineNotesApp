import 'package:equatable/equatable.dart';

import '../../../../core/enums/sync_status.dart';

/// Core domain entity representing a Note.
///
/// This is the pure business model used across the application layers.
/// It contains no framework or data-source dependencies and defines
/// the essential properties and behavior of a note.
class NoteEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final SyncStatus syncStatus;
  final bool isDeleted;
  final DateTime? lastSyncedAt;

  /// Creates a new immutable [NoteEntity].
  const NoteEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDeleted,
    this.lastSyncedAt,
  });

  @override
  /// Properties used for value comparison.
  List<Object?> get props => [
    id,
    title,
    body,
    updatedAt,
    syncStatus,
    isDeleted,
    lastSyncedAt,
  ];

  /// Creates a copy of this [NoteEntity] with updated fields.
  ///
  /// Useful for maintaining immutability while modifying specific values.
  NoteEntity copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
    bool? isDeleted,
    DateTime? lastSyncedAt,
  }) {
    return NoteEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}
