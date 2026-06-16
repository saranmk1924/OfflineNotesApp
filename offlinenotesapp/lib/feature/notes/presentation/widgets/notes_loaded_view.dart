import 'package:flutter/widgets.dart';
import 'package:offlinenotesapp/core/enums/platform_type.dart';
import 'package:offlinenotesapp/core/responsiveness/responsive_sizes.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_state.dart';
import 'package:offlinenotesapp/feature/notes/presentation/widgets/last_sync_status_widget.dart';
import 'package:offlinenotesapp/feature/notes/presentation/widgets/notes_list_view.dart';

/// This view is shown when notes are successfully loaded from local storage / sync.
/// It renders:
/// 1. Last sync status indicator
/// 2. Notes grid/list based on platform responsiveness
class NotesLoadedView extends StatelessWidget {
  final NoteLoaded state;
  final PlatformType platformType;
  const NotesLoadedView({
    super.key,
    required this.state,
    required this.platformType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LastSyncStatusWidget(),

        Expanded(
          child: NotesListView(
            notes: state.notes,
            isDelete: true,
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
    );
  }
}
