/// Contains Hive box names used for local data storage.
///
/// Centralizing box names helps prevent typos and makes it easier
/// to manage Hive storage configuration throughout the application.
class HiveConstants {
  /// Hive box used to store notes data.
  static const String notesBox = 'notes_box';

  /// Hive box used to store app-level data and preferences.
  static const appBox = 'app_box';
}
