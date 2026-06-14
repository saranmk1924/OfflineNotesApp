import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offlinenotesapp/feature/notes/domain/entities/sync_status.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_bloc.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_event.dart';
import 'package:offlinenotesapp/feature/notes/presentation/bloc/note_state.dart';
import 'package:offlinenotesapp/feature/notes/presentation/cubit/connectivity_cubit.dart';
import 'package:offlinenotesapp/feature/notes/presentation/pages/add_edit_note_page.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCubit, bool>(
      listener: (context, isConnected) {
        if (isConnected) {
          context.read<NoteBloc>().add(SyncNotesEvent());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notes'),
          actions: [
            IconButton(
              onPressed: () {
                context.read<NoteBloc>().add(SyncNotesEvent());
              },
              icon: const Icon(Icons.sync),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEditNotePage()),
            );
          },
          child: const Icon(Icons.add),
        ),
        body: BlocBuilder<NoteBloc, NoteState>(
          builder: (context, state) {
            if (state is NoteLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is NoteLoaded) {
              if (state.notes.isEmpty) {
                return const Center(child: Text('No Notes Yet'));
              }

              return ListView.builder(
                itemCount: state.notes.length,
                itemBuilder: (_, index) {
                  final note = state.notes[index];

                  return ListTile(
                    leading: Icon(
                      note.syncStatus == SyncStatus.synced
                          ? Icons.cloud_done
                          : Icons.cloud_upload,
                    ),
                    title: Text(note.title),
                    subtitle: Text(note.body),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditNotePage(note: note),
                        ),
                      );
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        context.read<NoteBloc>().add(DeleteNoteEvent(note.id));
                      },
                    ),
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
