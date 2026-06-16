import 'package:flutter/cupertino.dart';
import 'package:offlinenotesapp/core/constants/app_palette.dart';
import 'package:offlinenotesapp/core/enums/platform_type.dart';
import 'package:offlinenotesapp/core/responsiveness/responsive_sizes.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_state.dart';
import 'package:offlinenotesapp/feature/notes/presentation/widgets/last_sync_status_widget.dart';
import 'package:offlinenotesapp/feature/notes/presentation/widgets/notes_list_view.dart';

class ConflictResolvingView extends StatelessWidget {
  final ConflictResolvingState state;
  const ConflictResolvingView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            const LastSyncStatusWidget(),
            Expanded(
              child: NotesListView(
                notes: state.previousNotes,
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
