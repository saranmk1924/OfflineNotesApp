import 'package:equatable/equatable.dart';

import 'sync_status.dart';

class NoteEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final SyncStatus syncStatus;
  final bool isDeleted;
  final DateTime? lastSyncedAt;

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
  List<Object?> get props => [
    id,
    title,
    body,
    updatedAt,
    syncStatus,
    isDeleted,
    lastSyncedAt,
  ];

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
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt
    );
  }
}
