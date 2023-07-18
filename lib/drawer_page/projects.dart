import 'package:flutter/material.dart';
import 'package:AIis/drawer_page/project.dart';

class Projects_Page extends StatefulWidget {
  @override
  _Projects_PageState createState() => _Projects_PageState();
}

class _Projects_PageState extends State<Projects_Page>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  int _state = 0;

  final List<Widget> _Project_list = [];
  final List<Widget> _projectPages = [];
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
                  print('Entered text: $_inputText');
                  final page = Project_Page(name: _inputText);
                  _addChild(page, _state++);
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }

  //新增project
  void _addChild(Project_Page page, int state) {
    _projectPages.add(page);
    setState(() {
      _Project_list.add(Column(children: [
        Row(
          children: [
            SizedBox(width: 10),
            Icon(Icons.folder, size: 50), // 前方檔案icon
            SizedBox(width: 20), // 加入一個間距
            Expanded(
              child: Text(
                page.name, // 檔案名稱
                style: TextStyle(fontSize: 35),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.edit, size: 40),
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
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Color.fromARGB(255, 53, 58, 83),
        //   title: const Text('Projects'),
        // ),
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
