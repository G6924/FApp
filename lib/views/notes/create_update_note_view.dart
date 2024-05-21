import 'package:flutter/material.dart';
import 'package:project/services/auth/auth_service.dart';
import 'package:project/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:project/utilities/generics/get_arguments.dart';
import 'package:project/services/cloud/cloud_note.dart';
import 'package:project/services/cloud/firebase_cloud_storage.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _titleController;
  late final TextEditingController _textController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _videoUrlController;
  YoutubePlayerController? _youtubePlayerController;
  bool _showImage = true;
  bool _showVideo = false;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _titleController = TextEditingController();
    _textController = TextEditingController();
    _imageUrlController = TextEditingController();
    _videoUrlController = TextEditingController();
    super.initState();
  }

  void _initializeVideoPlayer() {
    final videoUrl = _videoUrlController.text;
    if (videoUrl.isNotEmpty) {
      final youtubeVideoId = YoutubePlayer.convertUrlToId(videoUrl);
      if (youtubeVideoId != null) {
        setState(() {
          _youtubePlayerController = YoutubePlayerController(
            initialVideoId: youtubeVideoId,
            flags: const YoutubePlayerFlags(
              autoPlay: false,
            ),
          );
          _showVideo = true;
        });
      } else {
        setState(() {
          _youtubePlayerController = null;
          _showVideo = false;
        });
      }
    } else {
      setState(() {
        _youtubePlayerController = null;
        _showVideo = false;
      });
    }
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();
    if (widgetNote != null) {
      _note = widgetNote;
      _titleController.text = widgetNote.title;
      _textController.text = widgetNote.text;
      _imageUrlController.text = widgetNote.imageUrl;
      _videoUrlController.text = widgetNote.videoUrl;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newNote = await _notesService.createNewNote(ownerUserId: userId);
    _note = newNote;
    return newNote;
  }

  void _saveNote() async {
    final note = _note;
    if (note != null) {
      final title = _titleController.text;
      final text = _textController.text;
      final imageUrl = _imageUrlController.text;
      final videoUrl = _videoUrlController.text;
      if (title.isNotEmpty || text.isNotEmpty || imageUrl.isNotEmpty || videoUrl.isNotEmpty) {
        await _notesService.updateNote(
          documentId: note.documentId,
          title: title,
          text: text,
          imageUrl: imageUrl,
          videoUrl: videoUrl,
        );
        if (videoUrl.isNotEmpty) {
          _initializeVideoPlayer();
        }
        setState(() {
          _showImage = imageUrl.isNotEmpty;
          _showVideo = videoUrl.isNotEmpty;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    _imageUrlController.dispose();
    _videoUrlController.dispose();
    _youtubePlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
        actions: [
          IconButton(
            onPressed: () async {
              final text = _textController.text;
              if (_note == null || text.isEmpty) {
                await showCannotShareEmptyNoteDialog(context);
              } else {
                Share.share(text);
              }
            },
            icon: const Icon(Icons.share),
          ),
          IconButton(
            onPressed: () async {
              _saveNote();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          future: createOrGetExistingNote(context),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              TextField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                  labelText: 'Title',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      _titleController.clear();
                                    },
                                    icon: const Icon(Icons.clear),
                                  ),
                                ),
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _textController,
                                decoration: InputDecoration(
                                  labelText: 'Text',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      _textController.clear();
                                    },
                                    icon: const Icon(Icons.clear),
                                  ),
                                ),
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _imageUrlController,
                                decoration: InputDecoration(
                                  labelText: 'Image URL',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      _imageUrlController.clear();
                                      setState(() {
                                        _showImage = false;
                                      });
                                    },
                                    icon: const Icon(Icons.clear),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (_showImage)
                                Image.network(
                                  _imageUrlController.text,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Text('Could not load image');
                                  },
                                ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _videoUrlController,
                                decoration: InputDecoration(
                                  labelText: 'Video URL',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      _videoUrlController.clear();
                                      setState(() {
                                        _showVideo = false;
                                        _youtubePlayerController = null;
                                      });
                                    },
                                    icon: const Icon(Icons.clear),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (_showVideo && _youtubePlayerController != null)
                                YoutubePlayer(
                                  controller: _youtubePlayerController!,
                                  showVideoProgressIndicator: true,
                                  progressIndicatorColor: Colors.amber,
                                  progressColors: const ProgressBarColors(
                                    playedColor: Colors.amber,
                                    handleColor: Colors.amberAccent,
                                  ),
                                  onReady: () {
                                    print('Player is ready.');
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              default:
                return const Center(
                  child: CircularProgressIndicator(),
                );
            }
          },
        ),
      ),
    );
  }
}
