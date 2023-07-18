import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import 'package:AIis/camera/camera_page.dart';

class Project_Video_Page extends StatefulWidget {
  final String name;
  Project_Video_Page({required this.name});
  @override
  _Project_Video_PageState createState() =>
      _Project_Video_PageState(name: name);
}

class _Project_Video_PageState extends State<Project_Video_Page>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Widget> _videos_list = [];
  final String name;
  _Project_Video_PageState({required this.name});

  void pushToCamera(BuildContext context) async {
    final String? videoPath = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraPage(),
      ),
    );
    if (videoPath != null) {
      await Future.delayed(Duration.zero);
      _saveVideo(videoPath);
    }
  }

  Future<void> _saveVideo(String videoPath) async {
    final File file = File(videoPath);
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = DateTime.now().toIso8601String();
    await file.copy('${appDir.path}/$fileName.mp4');
    setState(() {
      _videos_list.add(Column(children: [
        Row(
          children: [
            SizedBox(width: 10),
            Icon(Icons.videocam, size: 50),
            SizedBox(width: 20),
            Expanded(
              child: Text(
                '$fileName.mp4',
                style: TextStyle(fontSize: 15),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.search, size: 40),
              onPressed: () async {
                // ignore: unused_local_variable
                final File? new_image = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Result_Page(
                              filePath: '${appDir.path}/$fileName.jpeg',
                            )));
                // if (new_image != null) {
                //   await Future.delayed(Duration.zero);
                //   _saveVideo(new_image.path);
                // }
              },
            ),
            SizedBox(width: 10)
          ],
        ),
        SizedBox(height: 15),
        Container(
          height: 1,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(width: 1, color: Colors.grey)),
          ),
        ),
        SizedBox(height: 30)
      ]));
    });
    _loadVidoes();
  }

  // Future<void> _sort_with_date(files) async {
  //   files.sort((a, b) async {
  //     var statA = await (a as File).stat();
  //     var statB = await (b as File).stat();
  //     return statB.modified.compareTo(statA.modified);
  //   });
  // }

  Future<void> _loadVidoes() async {
    final appDir = await getApplicationDocumentsDirectory();
    final directory = Directory(appDir.path);
    final files = await directory.list().toList();
    files.sort((a, b) => a.path.compareTo(b.path));
    List<Widget> videoFiles = [];
    for (final file in files) {
      if (file.path.endsWith('.mp4')) {
        int slashIndex = file.path.lastIndexOf('/');
        String fileName = file.path.substring(slashIndex + 1);
        videoFiles.add(Column(children: [
          Row(
            children: [
              SizedBox(width: 10),
              Icon(Icons.videocam, size: 50),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  fileName,
                  style: TextStyle(fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.search, size: 40),
                onPressed: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Result_Page(
                                filePath: file.path,
                              )));
                  _loadVidoes();
                },
              ),
              SizedBox(width: 10)
            ],
          ),
          SizedBox(height: 15),
          Container(
            height: 1,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(width: 1, color: Colors.grey)),
            ),
          ),
          SizedBox(height: 30)
        ]));
      }
    }
    setState(() {
      _videos_list = videoFiles;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadVidoes();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 53, 58, 83),
          title: Text('$name'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: _videos_list,
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: UniqueKey(),
          onPressed: () async {
            this.pushToCamera(context);
          },
          child: const Icon(Icons.videocam),
        ));
  }
}

class Result_Page extends StatefulWidget {
  final String filePath;

  const Result_Page({required this.filePath});

  @override
  _Result_Page_State createState() => _Result_Page_State(videoPath: filePath);
}

class _Result_Page_State extends State<Result_Page> {
  final String videoPath;
  _Result_Page_State({required this.videoPath});
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

  Future<File> _uploadVideo(String videoPath) async {
    final url = Uri.parse('TBD');
    final request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('video', videoPath));
    final response = await request.send();
    if (response.statusCode == 200) {
      final fileResponse = await http.Response.fromStream(response);
      final bytes = fileResponse.bodyBytes;
      final appDir = await getApplicationDocumentsDirectory();
      String fileName = path.basenameWithoutExtension(videoPath);
      final orthoImageFile = File('${appDir.path}/$fileName' '_Result.jpeg');
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
        msg: "Invalid Photo!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
    return getFileFromPath(videoPath);
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
    int slashIndex = videoPath.lastIndexOf('/');
    String fileName = videoPath.substring(slashIndex + 1);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 53, 58, 83),
          title: Text(fileName),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                String new_name = '';
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Rename Video'),
                        content: TextField(
                          onChanged: (value) {
                            new_name = value;
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
                              if (new_name != '') {
                                final File file = File(videoPath);
                                final appDir =
                                    await getApplicationDocumentsDirectory();
                                await file.copy('${appDir.path}/$new_name.mp4');
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

class Result_Page_for_image extends StatelessWidget {
  late final String imagePath;
  Result_Page_for_image({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    int slashIndex = imagePath.lastIndexOf('/');
    String fileName = imagePath.substring(slashIndex + 1);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 53, 58, 83),
        title: Text(fileName),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
            ),
          )
        ],
      ),
    );
  }
}
