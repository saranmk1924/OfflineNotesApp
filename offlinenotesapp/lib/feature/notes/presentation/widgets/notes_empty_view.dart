import 'package:flutter/widgets.dart';
import 'package:offlinenotesapp/core/constants/app_palette.dart';
import 'package:offlinenotesapp/feature/notes/presentation/widgets/last_sync_status_widget.dart';

/// UI displayed when there are no notes available.
///
/// Shows the last sync status at the top and an empty-state message
/// in the center of the screen.
class NotesEmptyView extends StatelessWidget {
  const NotesEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LastSyncStatusWidget(),
        Expanded(
          child: const Center(
            child: Text(
              'No Notes Yet',
              style: TextStyle(
                color: AppPalette.white70,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
