import 'package:flutter/widgets.dart';
import 'package:offlinenotesapp/core/enums/platform_type.dart';
import 'package:offlinenotesapp/core/responsiveness/responsive_sizes.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_state.dart';
import 'package:offlinenotesapp/feature/notes/presentation/widgets/last_sync_status_widget.dart';
import 'package:offlinenotesapp/feature/notes/presentation/widgets/notes_list_view.dart';

class NotesErrorView extends StatelessWidget {
  final NoteError state;
  const NotesErrorView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const LastSyncStatusWidget(),
        Expanded(
          child: NotesListView(
            notes: state.previousNotes,
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
