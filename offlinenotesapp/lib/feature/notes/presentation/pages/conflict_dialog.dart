import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offlinenotesapp/core/constants/app_palette.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_bloc.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_event.dart';

class ConflictDialog {
  void showConflictDialog(
    BuildContext context,
    dynamic localNote,
    dynamic serverNote,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161616),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppPalette.purple),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppPalette.red,
                size: 30,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(width: 10),
              Text(
                'Conflict Detected',
                style: TextStyle(
                  color: AppPalette.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Both local and server versions were modified.',
                  style: TextStyle(color: AppPalette.white, fontSize: 17),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppPalette.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Local Version',
                        style: TextStyle(
                          color: AppPalette.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        localNote.title,
                        style: TextStyle(
                          color: AppPalette.white70,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        localNote.body,
                        style: TextStyle(
                          color: AppPalette.white70,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppPalette.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Server Version',
                        style: TextStyle(
                          color: AppPalette.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        serverNote.title,
                        style: TextStyle(
                          color: AppPalette.white70,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        serverNote.body,
                        style: TextStyle(
                          color: AppPalette.white70,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.purple,
                foregroundColor: AppPalette.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                context.read<NoteBloc>().add(UseLocalVersionEvent(localNote));

                Navigator.pop(context);
              },
              child: const Text(
                'Use Local',
                style: TextStyle(color: AppPalette.white, fontSize: 15),
              ),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppPalette.purple),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                context.read<NoteBloc>().add(UseServerVersionEvent(serverNote));

                Navigator.pop(context);
              },
              child: const Text(
                'Use Server',
                style: TextStyle(color: AppPalette.white, fontSize: 15),
              ),
            ),
          ],
        );
      },
    );
  }
}
