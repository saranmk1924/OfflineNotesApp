import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:offlinenotesapp/core/constants/app_palette.dart';
import 'package:offlinenotesapp/core/enums/platform_type.dart';
import 'package:offlinenotesapp/feature/notes/domain/entities/note_entity.dart';
import 'package:offlinenotesapp/core/enums/sync_status.dart';
import 'package:offlinenotesapp/feature/notes/presentation/pages/add_edit_note_page.dart';
import 'package:offlinenotesapp/feature/notes/presentation/widgets/delete_confirmation_dialog.dart';

/// Grid-based list view for displaying notes.
///
/// Uses a staggered grid layout that adapts to different [PlatformType]s
/// and supports edit/delete actions depending on configuration.

class NotesListView extends StatefulWidget {
  final List<NoteEntity> notes;
  final bool isDelete;
  final PlatformType platformType;
  const NotesListView({
    super.key,
    required this.notes,
    required this.isDelete,
    required this.platformType,
  });

  @override
  State<NotesListView> createState() => _NotesListViewState();
}

class _NotesListViewState extends State<NotesListView> {
  /// Scroll controller used for custom scrollbar behavior.
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawScrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      thickness: 6,
      padding: EdgeInsets.only(right: 1),
      radius: const Radius.circular(20),
      scrollbarOrientation: ScrollbarOrientation.right,
      thumbColor: AppPalette.purple.withValues(alpha: 0.7),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: ScrollConfiguration(
          behavior: ScrollBehavior().copyWith(scrollbars: false),
          child: MasonryGridView.builder(
            controller: _scrollController,
            itemCount: widget.notes.length,

            /// Responsive column count
            gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.platformType == PlatformType.mobile
                  ? 1
                  : widget.platformType == PlatformType.tablet
                  ? 2
                  : 3,
            ),

            /// Spacing based on platform
            crossAxisSpacing: widget.platformType == PlatformType.mobile
                ? 0
                : widget.platformType == PlatformType.tablet
                ? 18
                : widget.platformType == PlatformType.desktop
                ? 18
                : widget.platformType == PlatformType.ultrahd
                ? 18
                : 12,
            mainAxisSpacing: widget.platformType == PlatformType.mobile
                ? 6
                : widget.platformType == PlatformType.tablet
                ? 10
                : widget.platformType == PlatformType.desktop
                ? 10
                : widget.platformType == PlatformType.ultrahd
                ? 10
                : 12,

            itemBuilder: (_, index) {
              final note = widget.notes[index];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppPalette.purple, width: 0.8),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),

                  /// Tap to edit note (only when delete mode enabled)
                  onTap: widget.isDelete
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditNotePage(note: note),
                            ),
                          );
                        }
                      : null,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),

                    /// Sync status indicator
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppPalette.purple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        note.syncStatus == SyncStatus.synced
                            ? Icons.cloud_done
                            : Icons.cloud_upload,
                        color: note.syncStatus == SyncStatus.synced
                            ? AppPalette.purple
                            : AppPalette.red,
                      ),
                    ),

                    /// Note title
                    title: Text(
                      note.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppPalette.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),

                    /// Note body preview
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        note.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppPalette.white70),
                      ),
                    ),

                    /// Delete action button
                    trailing: Opacity(
                      opacity: widget.isDelete ? 1.0 : 0.2,

                      child: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppPalette.white70,
                        ),
                        onPressed: widget.isDelete
                            ? () {
                                DeleteConfirmationDialog().show(
                                  context,
                                  note.id,
                                  note.title,
                                );
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
