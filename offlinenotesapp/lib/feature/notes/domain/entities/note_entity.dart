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
    lastSyncedAt
  ];
}
