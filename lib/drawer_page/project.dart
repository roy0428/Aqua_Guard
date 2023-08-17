import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:AIis/camera/take_picture_screen.dart';

class ProjectPage extends StatefulWidget {
  final String name;
  const ProjectPage({super.key, required this.name});

  @override
  // ignore: no_logic_in_create_state
  State<ProjectPage> createState() => _ProjectPageState(name: name);
}

class _ProjectPageState extends State<ProjectPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Widget> imageslist = [];
  final String name;
  _ProjectPageState({required this.name});

  Future<void> _loadImages() async {
    final appDir = await getApplicationDocumentsDirectory();
    final directory = Directory('${appDir.path}/Projects/$name');
    final files = await directory.list().toList();
    files.sort((a, b) => a.path.compareTo(b.path));
    // ignore: no_leading_underscores_for_local_identifiers
    List<Widget> _imageslist = [];
    for (final file in files) {
      if (file.path.endsWith('.jpeg')) {
        int slashIndex = file.path.lastIndexOf('/');
        String fileName = file.path.substring(slashIndex + 1);
        _imageslist.add(Column(children: [
          Row(
            children: [
              const SizedBox(width: 10),
              const Icon(Icons.image, size: 50),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  fileName,
                  style: const TextStyle(fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.search, size: 40),
                onPressed: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ResultPage(
                                imagePath: file.path,
                                projectName: name,
                              )));
                  await _loadImages();
                },
              ),
              const SizedBox(width: 10)
            ],
          ),
          const SizedBox(height: 15),
          Container(
            height: 1,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(width: 1, color: Colors.grey)),
            ),
          ),
          const SizedBox(height: 30)
        ]));
      }
    }
    setState(() {
      imageslist = _imageslist;
    });
  }

  void pushToCamera(BuildContext context) async {
    final cameras = await availableCameras();
    // ignore: use_build_context_synchronously
    final String? imagePath = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakePictureScreen(camera: cameras.first),
      ),
    );
    if (imagePath != null) {
      final File file = File(imagePath);
      final appDir = await getApplicationDocumentsDirectory();
      final directory = Directory('${appDir.path}/Projects/$name');
      final fileName = DateTime.now().toIso8601String();
      await file.copy('${directory.path}/$fileName.jpeg');
      await _loadImages();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 53, 58, 83),
          title: Text(name),
          centerTitle: true,
        ),
        body: Column(
          children: [
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: imageslist,
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: UniqueKey(),
          onPressed: () async {
            pushToCamera(context);
          },
          child: const Icon(Icons.camera_alt),
        ));
  }
}

class ResultPage extends StatelessWidget {
  final String imagePath;
  final String projectName;
  const ResultPage(
      {super.key, required this.imagePath, required this.projectName});

  // Future<File> getFileFromPath(String path) async {
  //   return File(path);
  // }

  Future<File> _uploadImage(String imagePath) async {
    final url = Uri.parse('http://140.112.12.167:8000/upload/');
    final request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('photo', imagePath));
    final response = await request.send();
    if (response.statusCode == 200) {
      final fileResponse = await http.Response.fromStream(response);
      final bytes = fileResponse.bodyBytes;
      String appDir = path.dirname(imagePath);
      String fileName = path.basenameWithoutExtension(imagePath);
      final orthoImageFile = File('$appDir/$fileName' '_Result.jpeg');
      await orthoImageFile.writeAsBytes(bytes);
      Fluttertoast.showToast(
          msg: "Processed photo received!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
      return orthoImageFile;
    }
    Fluttertoast.showToast(
        msg: "No Apriltag detected!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
    return File(imagePath);
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Stack(
          alignment: Alignment.center,
          children: [
            ModalBarrier(
              dismissible: false,
              color: Colors.black54,
            ),
            AbsorbPointer(
              absorbing: true,
              child: Dialog(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16.0),
                      Text("Prediction processing..."),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int slashIndex = imagePath.lastIndexOf('/');
    String fileName = imagePath.substring(slashIndex + 1);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 53, 58, 83),
          title: Text(fileName),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                String newname = '';
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Rename Photo'),
                        content: TextField(
                          onChanged: (value) {
                            newname = value;
                          },
                          decoration: const InputDecoration(
                            hintText: 'Enter some text',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              if (newname != '') {
                                final File file = File(imagePath);
                                final appDir =
                                    await getApplicationDocumentsDirectory();
                                // final directory =
                                //     Directory('${appDir.path}/Projects/$projectName');
                                await file.copy(
                                    '${appDir.path}/Projects/$projectName/$newname.jpeg');
                                file.delete();
                              }
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    });
              },
            )
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 5,
                  child: Image.file(
                    File(imagePath),
                  )),
            )
          ],
        ),
        floatingActionButton: Stack(
          children: <Widget>[
            Positioned.fill(
                child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 32.0),
                        child: FloatingActionButton(
                          heroTag: UniqueKey(),
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirm'),
                                content: const Text(
                                    'Are you sure you want to delete this photo?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      File file = File(imagePath);
                                      file.delete();
                                      Fluttertoast.showToast(
                                          msg: "Photo deleted!",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.green,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.red)),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Icon(Icons.delete),
                        )))),
            Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                    padding: const EdgeInsets.only(left: 24.0),
                    child: FloatingActionButton(
                      heroTag: UniqueKey(),
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm'),
                            content: const Text(
                                'Are you sure you want to upload this photo?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                  onPressed: () async {
                                    showLoadingDialog(context);
                                    await _uploadImage(imagePath);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Upload')),
                            ],
                          ),
                        );
                      },
                      child: const Icon(Icons.upload),
                    ))),
            Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  heroTag: UniqueKey(),
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm'),
                        content: const Text(
                            'Are you sure you want to save this photo?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                              onPressed: () async {
                                await GallerySaver.saveImage(imagePath);
                                Fluttertoast.showToast(
                                    msg: "Photo saved!",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: const Text('Save')),
                        ],
                      ),
                    );
                  },
                  child: const Icon(Icons.save),
                ))
          ],
        ));
  }
}
