import 'dart:io';

import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' show basename;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tarea8/database/db_provider.dart';
import 'package:tarea8/models/post_model.dart';
import 'package:tarea8/utils/show_snackbar.dart';
import 'package:tarea8/widgets/custom_input.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isDeleting = false;
  bool isLoading = true;
  List<Posts> posts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final result = await DBProvider.db.getAllPosts();
    posts = result.reversed.toList();
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: deleteAll,
            icon: isDeleting
                ? const Center(
                    child: SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator.adaptive(
                        backgroundColor: Colors.white,
                      ),
                    ),
                  )
                : const Icon(Icons.delete),
          ),
        ],
      ),
      body: _getBodyDinamically(),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Crear Post',
        onPressed: openCreatePostDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _getBodyDinamically() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }
    if (posts.isEmpty && !isLoading) {
      return Center(
        child: Text(
          'No hay posts, crea uno ahora!',
          style: Theme.of(context).textTheme.headline6,
        ),
      );
    }
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (BuildContext context, int index) {
        return _PostItem(post: posts[index]);
      },
    );
  }

  void openCreatePostDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => const _CreatePostDialog(),
    );
    setState(() => isLoading = true);
    await _loadPosts();
  }

  void deleteAll() async {
    if (posts.isEmpty) {
      customSnackBar(context, 'No hay posts en la base de datos');
      return;
    }
    setState(() => isDeleting = true);
    await DBProvider.db.deleteAll();
    if (!mounted) return;
    posts = [];
    isDeleting = false;
    customSnackBar(context, 'Se han eliminado todos los posts');
    setState(() {});
  }
}

class _PostItem extends StatefulWidget {
  const _PostItem({Key? key, required this.post}) : super(key: key);
  final Posts post;

  @override
  State<_PostItem> createState() => __PostItemState();
}

class __PostItemState extends State<_PostItem> {
  bool isPlaying = false;
  final audioPlayer = ap.AudioPlayer();
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    audioPlayer.onPlayerStateChanged.listen((state) {
      isPlaying = state == ap.PlayerState.playing;
      setState(() {});
    });
    audioPlayer.onDurationChanged.listen((newDuration) {
      duration = newDuration;
      setState(() {});
    });
    audioPlayer.onPositionChanged.listen((newPosition) {
      position = newPosition;
      setState(() {});
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: widget.post.image.isEmpty
                      ? const AssetImage('assets/default.png')
                      : FileImage(File(widget.post.image)) as ImageProvider,
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5.0),
                      Text(
                        widget.post.description,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Slider(
              min: 0,
              max: duration.inSeconds.toDouble(),
              value: position.inSeconds.toDouble(),
              onChanged: (value) async {},
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatTime(position)),
                  Text(formatTime(duration - position)),
                ],
              ),
            ),
            Align(
              child: CircleAvatar(
                child: IconButton(
                  splashRadius: 25,
                  onPressed: () async {
                    if (widget.post.audio.isEmpty) {
                      customSnackBar(context, 'Este post no tiene audio...');
                      return;
                    }
                    if (isPlaying) {
                      isPlaying = false;
                      await audioPlayer.pause();
                    } else {
                      isPlaying = true;
                      await audioPlayer
                          .play(ap.DeviceFileSource(widget.post.audio));
                    }
                  },
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5.0),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                DateFormat('dd/MM/yyyy').format(widget.post.date),
                style: Theme.of(context).textTheme.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(':');
  }
}

class _CreatePostDialog extends StatefulWidget {
  const _CreatePostDialog({Key? key}) : super(key: key);

  @override
  State<_CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<_CreatePostDialog> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  XFile? selectedImage;
  File? recordedAudio;
  final recorder = FlutterSoundRecorder();

  @override
  void initState() {
    initRecorder();
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    recorder.closeRecorder();
    super.dispose();
  }

  Future initRecorder() async {
    try {
      final status = await Permission.microphone.request();
      print('Is granted: ${status.isGranted}');
      if (!status.isGranted) {
        return;
      }
      await recorder.openRecorder();
    } catch (e) {
      print('Exception: $e');
    }
  }

  Future record() async {
    await recorder.startRecorder(toFile: 'audio');
  }

  Future stop() async {
    final path = await recorder.stopRecorder();
    recordedAudio = File(path!);
    print('Recorded audio: $recordedAudio');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Crear Post',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar',
                    splashRadius: 25,
                    color: Colors.white,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomInput(
                    controller: titleController,
                    labelText: 'Título',
                    textCapitalization: TextCapitalization.sentences,
                    inputAction: TextInputAction.next,
                  ),
                  CustomInput(
                    controller: descriptionController,
                    labelText: 'Descripción',
                    textCapitalization: TextCapitalization.sentences,
                    textInputType: TextInputType.multiline,
                    inputAction: TextInputAction.next,
                    minLines: 1,
                    maxLines: 5,
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: selectedImage == null
                          ? const AssetImage('assets/default.png')
                          : FileImage(File(selectedImage!.path))
                              as ImageProvider,
                    ),
                    title: const Text('Seleccionar imágen'),
                    onTap: pickImage,
                  ),
                  ListTile(
                    leading: Icon(
                      recorder.isRecording ? Icons.stop : Icons.mic,
                    ),
                    title: const Text('Grabar audio'),
                    onTap: () async {
                      if (recorder.isRecording) {
                        await stop();
                      } else {
                        await record();
                      }
                      setState(() {});
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: recordedAudio != null
                        ? Text(
                            'Audio grabado!',
                            style: Theme.of(context).textTheme.caption,
                          )
                        : const SizedBox(),
                  ),
                  const SizedBox(height: 20.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(double.infinity, 35),
                      ),
                      onPressed: isValidFields() ? storePost : null,
                      child: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    selectedImage = image;
    setState(() {});
  }

  void storePost() async {
    String imagePath = '';
    String audioPath = '';
    if (selectedImage != null) {
      final fileDirectory = await getApplicationDocumentsDirectory();
      final fileName = basename(selectedImage!.path);
      await selectedImage!.saveTo('${fileDirectory.path}/$fileName');
      imagePath = '${fileDirectory.path}/$fileName';
    }
    if (recordedAudio != null) {
      final fileDirectory = await getApplicationDocumentsDirectory();
      final fileName = basename(recordedAudio!.path);
      await recordedAudio!.copy('${fileDirectory.path}/$fileName');
      audioPath = '${fileDirectory.path}/$fileName';
    }

    print('IMAGE PATH: $imagePath');
    print('RECORDED AUDIO: $audioPath');
    final newPost = Posts(
      title: "'${titleController.text}'",
      date: DateTime.now(),
      description: "'${descriptionController.text}'",
      image: "'$imagePath'",
      audio: "'$audioPath'",
    );
    await DBProvider.db.storePost(newPost);
    if (!mounted) return;
    Navigator.pop(context);
    customSnackBar(context, 'Post guardado');
  }

  bool isValidFields() {
    if (titleController.text.isEmpty) {
      return false;
    }
    if (descriptionController.text.isEmpty) {
      return false;
    }
    return true;
  }
}
