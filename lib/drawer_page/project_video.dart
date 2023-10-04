import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
// import 'package:http/http.dart' as http;
// import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
// import 'package:AIis/drawer_page/project.dart';


import 'package:AIis/camera/camera_page.dart';

class ProjectVideoPage extends StatefulWidget {
  final String name;
  const ProjectVideoPage({super.key, required this.name});

  @override
  // ignore: no_logic_in_create_state
  State<ProjectVideoPage> createState() => _ProjectVideoPageState(name: name);
}

class _ProjectVideoPageState extends State<ProjectVideoPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Widget> _videoslist = [];
  final String name;
  _ProjectVideoPageState({required this.name});

  void pushToCamera(BuildContext context) async {
    final String? videoPath = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraPage(),
      ),
    );
    if (videoPath != null) {
      final File file = File(videoPath);
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = DateTime.now().toIso8601String();
      await file.copy('${appDir.path}/VideoProjects/$name/$fileName.mp4');
      await _loadVidoesandImages();
    }
  }

  Future<void> _loadVidoesandImages() async {
    final appDir = await getApplicationDocumentsDirectory();
    final directory = Directory('${appDir.path}/VideoProjects/$name');
    final files = await directory.list().toList();
    files.sort((a, b) => a.path.compareTo(b.path));
    List<Widget> videoFiles = [];
    for (final file in files) {
      int slashIndex = file.path.lastIndexOf('/');
      String fileName = file.path.substring(slashIndex + 1);
      if (file.path.endsWith('.mp4')) {
        videoFiles.add(Column(children: [
          Row(
            children: [
              const SizedBox(width: 10),
              const Icon(Icons.videocam, size: 50),
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
                          builder: (context) => VideoResultPage(
                                filePath: file.path,
                              )));
                  await _loadVidoesandImages();
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
      else if(file.path.endsWith('.jpeg')){
        videoFiles.add(Column(children: [
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
                  await _loadVidoesandImages();
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
      _videoslist = videoFiles;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadVidoesandImages();
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
                children: _videoslist,
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: UniqueKey(),
          onPressed: () async {
            pushToCamera(context);
          },
          child: const Icon(Icons.videocam),
        ));
  }
}

class VideoResultPage extends StatefulWidget {
  final String filePath;
  const VideoResultPage({super.key, required this.filePath});

  @override
  // ignore: no_logic_in_create_state
  State<VideoResultPage> createState() => _VideoResultPageState(videoPath: filePath);
}

class _VideoResultPageState extends State<VideoResultPage> {
  final String videoPath;
  _VideoResultPageState({required this.videoPath});
  late final VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.filePath));
    _controller.initialize().then((_) => setState(() {}));
    _controller.setLooping(true);
    _controller.play();
  }

  Future<File> getFileFromPath(String path) async {
    return File(path);
  }

  //TODO
  
  // Future<File> _uploadVideo(String videoPath) async {
  //   final url = Uri.parse('TBD');
  //   final request = http.MultipartRequest('POST', url);
  //   request.files.add(await http.MultipartFile.fromPath('video', videoPath));
  //   final response = await request.send();
  //   if (response.statusCode == 200) {
  //     final fileResponse = await http.Response.fromStream(response);
  //     final bytes = fileResponse.bodyBytes;
  //     final appDir = await getApplicationDocumentsDirectory();
  //     String fileName = path.basenameWithoutExtension(videoPath);
  //     final orthoImageFile = File('${appDir.path}/$fileName' '_Result.jpeg');
  //     await orthoImageFile.writeAsBytes(bytes);
  //     Fluttertoast.showToast(
  //         msg: "Processed photo received!",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.BOTTOM,
  //         timeInSecForIosWeb: 1,
  //         backgroundColor: Colors.green,
  //         textColor: Colors.white,
  //         fontSize: 16.0);
  //     return orthoImageFile;
  //   }
  //   Fluttertoast.showToast(
  //       msg: "Invalid Photo!",
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.BOTTOM,
  //       timeInSecForIosWeb: 1,
  //       backgroundColor: Colors.green,
  //       textColor: Colors.white,
  //       fontSize: 16.0);
  //   return getFileFromPath(videoPath);
  // }

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
    int slashIndex = videoPath.lastIndexOf('/');
    String fileName = videoPath.substring(slashIndex + 1);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 53, 58, 83),
          title: Text(fileName),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                String newname = '';
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Rename Video'),
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
                                final File file = File(videoPath);
                                final appDir =
                                    await getApplicationDocumentsDirectory();
                                await file.copy(
                                    '${appDir.path}/VideoProject/$newname.mp4');
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
        body: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : Container(),
        floatingActionButton: Stack(
          children: <Widget>[
            Positioned.fill(
                child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                        padding: EdgeInsets.only(left: 32.0),
                        child: FloatingActionButton(
                          heroTag: UniqueKey(),
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Confirm'),
                                content: Text(
                                    'Are you sure you want to delete this video?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      File file = File(videoPath);
                                      file.delete();
                                      Fluttertoast.showToast(
                                          msg: "Video deleted!",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.green,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    child: Text('Delete'),
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Icon(Icons.delete),
                        )))),
            Positioned.fill(
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                        padding: EdgeInsets.only(left: 24.0),
                        child: FloatingActionButton(
                          heroTag: UniqueKey(),
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Confirm'),
                                content: Text(
                                    'Are you sure you want to upload this video?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      //await _uploadVideo(imagePath);
                                      showLoadingDialog(context);
                                      Fluttertoast.showToast(
                                          msg: "Not available right now!",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.green,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    child: Text('Upload'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Icon(Icons.upload),
                        )))),
            Positioned.fill(
                child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                        padding: EdgeInsets.only(left: 32.0),
                        child: FloatingActionButton(
                          heroTag: UniqueKey(),
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Confirm'),
                                content: Text(
                                    'Are you sure you want to save this video?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                      onPressed: () async {
                                        await GallerySaver.saveVideo(videoPath);
                                        Fluttertoast.showToast(
                                            msg: "Video saved!",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.green,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: Text('Save')),
                                ],
                              ),
                            );
                          },
                          child: const Icon(Icons.save),
                        ))))
          ],
        ));
  }
}

class ResultPage extends StatelessWidget {
  final String imagePath;
  final String projectName;
  const ResultPage({super.key, required this.imagePath, required this.projectName});

  // Future<File> getFileFromPath(String path) async {
  //   return File(path);
  // }

  // Future<File> _uploadImage(String imagePath) async {
    // final url = Uri.parse('http://140.112.12.167:8000/upload/');
    // final request = http.MultipartRequest('POST', url);
    // request.files.add(await http.MultipartFile.fromPath('photo', imagePath));
    // final response = await request.send();
    // if (response.statusCode == 200) {
    //   final fileResponse = await http.Response.fromStream(response);
    //   final bytes = fileResponse.bodyBytes;
    //   String appDir = path.dirname(imagePath);
    //   String fileName = path.basenameWithoutExtension(imagePath);
    //   final orthoImageFile = File('$appDir/$fileName' '_Result.jpeg');
    //   await orthoImageFile.writeAsBytes(bytes);
    //   Fluttertoast.showToast(
    //       msg: "Processed photo received!",
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.BOTTOM,
    //       timeInSecForIosWeb: 1,
    //       backgroundColor: Colors.green,
    //       textColor: Colors.white,
    //       fontSize: 16.0);
    //   return orthoImageFile;
    // }
    // Fluttertoast.showToast(
    //     msg: "No Apriltag detected!",
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.BOTTOM,
    //     timeInSecForIosWeb: 1,
    //     backgroundColor: Colors.green,
    //     textColor: Colors.white,
    //     fontSize: 16.0);
    // return File(imagePath);
  // }

  // void showLoadingDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return const Stack(
  //         alignment: Alignment.center,
  //         children: [
  //           ModalBarrier(
  //             dismissible: false,
  //             color: Colors.black54,
  //           ),
  //           AbsorbPointer(
  //             absorbing: true,
  //             child: Dialog(
  //               child: Padding(
  //                 padding: EdgeInsets.all(16.0),
  //                 child: Row(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     CircularProgressIndicator(),
  //                     SizedBox(width: 16.0),
  //                     Text("Prediction processing..."),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

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
                                await file
                                    .copy('${appDir.path}/VideoProjects/$projectName/$newname.jpeg');
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
                                    // showLoadingDialog(context);
                                    // await _uploadImage(imagePath);
                                    // Navigator.pop(context);
                                    // Navigator.pop(context);
                                    // Navigator.pop(context);
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
                        content:
                            const Text('Are you sure you want to save this photo?'),
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
