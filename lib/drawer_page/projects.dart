import 'dart:io';

import 'package:flutter/material.dart';
import 'package:AIis/drawer_page/project.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Projects_Page extends StatefulWidget {
  @override
  _Projects_PageState createState() => _Projects_PageState();
}

class _Projects_PageState extends State<Projects_Page>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Widget> _Project_list = [];
  //打字視窗
  void _showDialog() {
    String _inputText = '';
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Project Name'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  _inputText = value;
                });
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
                onPressed: () {
                  Navigator.of(context).pop();
                  _addProject(_inputText);
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }

  Future<void> _loadFolders() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files = appDir.listSync();
    List<Directory> folders = files
        .where((entity) => entity is Directory)
        .map((entity) => entity as Directory)
        .toList();
    folders.sort((a, b) => a.path.compareTo(b.path));

    List<Widget> Project_list = [];
    for (final folder in folders) {
      int slashIndex = folder.path.lastIndexOf('/');
      String projectName = folder.path.substring(slashIndex + 1);
      final page = Project_Page(name: projectName);
      Project_list.add(Column(children: [
        Row(
          children: [
            SizedBox(width: 10),
            Icon(Icons.folder, size: 50), // 前方檔案icon
            SizedBox(width: 20), // 加入一個間距
            Expanded(
              child: Text(
                projectName, // 檔案名稱
                style: TextStyle(fontSize: 20),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.delete, size: 30),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Confirm'),
                    content:
                        Text('Are you sure you want to delete this project?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final Directory_to_be_deleted =
                              Directory('${appDir.path}/$projectName');
                          Directory_to_be_deleted.delete(recursive: true);
                          Fluttertoast.showToast(
                              msg: "Project deleted!",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              fontSize: 16.0);
                          await _loadFolders();
                          Navigator.pop(context);
                        },
                        child: Text('Delete'),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => page),
                );
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
    setState(() {
      _Project_list = Project_list;
    });
  }

  //新增project
  Future<void> _addProject(String ProjectName) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory newDirectory = Directory('${appDocDir.path}/$ProjectName');
    if (await newDirectory.exists() == false) {
      newDirectory.create().then((Directory directory) {});
    }
    _loadFolders();
  }

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 53, 58, 83),
          title: const Text('Projects'),
        ),
        body: Column(
          children: [
            SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: _Project_list,
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: UniqueKey(),
          onPressed: _showDialog,
          child: const Icon(Icons.add),
        ));
  }
}
