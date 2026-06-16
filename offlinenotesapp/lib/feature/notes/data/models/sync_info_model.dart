/// Represents synchronization metadata for the application.
///
/// Stores information about the last successful sync operation,
/// which can be used to determine whether local data is up to date
/// with the remote server.
class SyncInfo {
  /// The timestamp of the last successful synchronization.
  ///
  /// Can be `null` if no sync has been performed yet.
  final DateTime? lastSyncTime;

  /// Creates a new [SyncInfo] instance.
  const SyncInfo({this.lastSyncTime});
}
