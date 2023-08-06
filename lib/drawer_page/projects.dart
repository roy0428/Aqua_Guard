import 'dart:io';

import 'package:flutter/material.dart';
import 'package:AIis/drawer_page/project.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Widget> projectlist = [];
  void _showDialog() {
    String inputText = '';
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Project Name'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  inputText = value;
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
                  _addProject(inputText);
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }

  Future<void> _loadFolders() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    appDir = Directory('${appDir.path}/Projects');

    if (await appDir.exists() == false) {
      await appDir.create().then((Directory directory) {});
    }

    List<FileSystemEntity> files = appDir.listSync();
    List<Directory> folders =
        files.whereType<Directory>().map((entity) => entity).toList();
    folders.sort((a, b) => a.path.compareTo(b.path));

    // ignore: no_leading_underscores_for_local_identifiers
    List<Widget> _projectlist = [];
    for (final folder in folders) {
      int slashIndex = folder.path.lastIndexOf('/');
      String projectName = folder.path.substring(slashIndex + 1);
      final page = ProjectPage(name: projectName);
      _projectlist.add(Column(children: [
        Row(
          children: [
            const SizedBox(width: 10),
            const Icon(Icons.folder, size: 50),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                projectName,
                style: const TextStyle(fontSize: 20),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.delete, size: 30),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm'),
                    content: const Text(
                        'Are you sure you want to delete this project?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
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
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red)),
                        child: const Text('Delete'),
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
    setState(() {
      projectlist = _projectlist;
    });
  }

  //新增project
  Future<void> _addProject(String projectName) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory newDirectory =
        Directory('${appDocDir.path}/Projects/$projectName');
    if (await newDirectory.exists() == false) {
      await newDirectory.create().then((Directory directory) {});
    }
    await _loadFolders();
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
          backgroundColor: const Color.fromARGB(255, 53, 58, 83),
          title: const Text('Projects'),
        ),
        body: Column(
          children: [
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: projectlist,
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
