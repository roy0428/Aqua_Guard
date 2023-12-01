import 'package:camera/camera.dart';
import './display_picture_screen.dart';
import 'package:flutter/material.dart';

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;
  final String username;
  const TakePictureScreen(
      {super.key, required this.camera, required this.username});

  @override
  TakePictureScreenState createState() =>
      // ignore: no_logic_in_create_state
      TakePictureScreenState(username: username);
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final String username;
  TakePictureScreenState({
    required this.username,
  });

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.max,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Stack(
      alignment: Alignment.bottomCenter,
      children: [
        FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(_controller);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        FloatingActionButton(
          child: const Icon(Icons.camera_alt),
          onPressed: () async {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            if (!mounted) return;
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  imagePath: image.path,
                  username: username,
                ),
              ),
            );
          },
        ),
      ],
    ));
  }
}
