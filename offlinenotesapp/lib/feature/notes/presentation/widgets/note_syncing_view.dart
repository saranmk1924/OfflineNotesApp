import 'package:flutter/cupertino.dart';
import 'package:offlinenotesapp/core/constants/app_palette.dart';
import 'package:offlinenotesapp/core/enums/platform_type.dart';
import 'package:offlinenotesapp/core/responsiveness/responsive_sizes.dart';
import 'package:offlinenotesapp/feature/notes/domain/entities/note_entity.dart';
import 'package:offlinenotesapp/feature/notes/presentation/widgets/last_sync_status_widget.dart';
import 'package:offlinenotesapp/feature/notes/presentation/widgets/notes_list_view.dart';

/// UI shown while notes are actively syncing with the server.
///
/// Displays the current list of notes in the background along with
/// a loading overlay to indicate sync progress.
class NoteSyncingView extends StatelessWidget {
  final List<NoteEntity> notes;
  const NoteSyncingView({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            LastSyncStatusWidget(),
            Expanded(
              child: NotesListView(
                notes: notes,
                isDelete: false,
                platformType: ResponsiveSizes.isMobile(context)
                    ? PlatformType.mobile
                    : ResponsiveSizes.isTablet(context)
                    ? PlatformType.tablet
                    : ResponsiveSizes.isDesktop(context)
                    ? PlatformType.desktop
                    : ResponsiveSizes.isUltrahd(context)
                    ? PlatformType.ultrahd
                    : PlatformType.mobile,
              ),
            ),
          ],
        ),
        Container(color: AppPalette.loaderShade),
        const Center(
          child: CupertinoActivityIndicator(
            radius: 30,
            color: AppPalette.purple,
          ),
        ),
      ],
    );
  }
}
