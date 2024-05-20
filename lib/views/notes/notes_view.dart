import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/constants/routes.dart';
import 'package:project/enums/menu_action.dart';
import 'package:project/services/auth/auth_service.dart';
import 'package:project/services/auth/bloc/auth_bloc.dart';
import 'package:project/services/auth/bloc/auth_event.dart';
import 'package:project/services/cloud/cloud_note.dart';
import 'package:project/services/cloud/firebase_cloud_storage.dart';
import 'package:project/utilities/dialogs/logout_dialog.dart';
import 'package:project/views/notes/notes_list_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;

  String _searchQuery = '';
  late TextEditingController _searchController;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    super.initState();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text('Your Notes'),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
                },
                icon: const Icon(Icons.add),
              ),
              PopupMenuButton<MenuAction>(
                onSelected: (value) async {
                  switch (value) {
                    case MenuAction.logout:
                      final shouldLogout = await showLogOutDialog(context);
                      if (shouldLogout) {
                        context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
                        );
                      }
                  }
                },
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem<MenuAction>(
                      value: MenuAction.logout,
                      child: ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Log out'),
                      ),
                    ),
                  ];
                },
              ),
              IconButton( // Button to navigate to profile
                onPressed: () {
                  Navigator.of(context).pushNamed(profileRoute);
                },
                icon: const Icon(Icons.person),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search Notes',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            child: StreamBuilder(
              stream: _notesService.allNotes(ownerUserId: userId),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.active:
                    if (snapshot.hasData) {
                      final allNotes = snapshot.data as Iterable<CloudNote>;
                      final filteredNotes = _searchQuery.isEmpty
                          ? allNotes
                          : allNotes.where((note) =>
                      note.title.contains(_searchQuery) ||
                          note.text.contains(_searchQuery));
                      return NotesListView(
                        notes: filteredNotes,
                        onDeleteNote: (note) async {
                          await _notesService.deleteNote(
                              documentId: note.documentId);
                        },
                        onTap: (note) {
                          Navigator.of(context).pushNamed(
                            createOrUpdateNoteRoute,
                            arguments: note,
                          );
                        },
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  default:
                    return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
