import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import './drawer_page/home.dart';
// import './drawer_page/project.dart';
import './drawer_page/projects.dart';
import './drawer_page/setting.dart';
import 'drawer_page/project_video.dart';

class BasicScreen extends StatefulWidget {
  @override
  _BasicScreenState createState() => _BasicScreenState();
}

class _BasicScreenState extends State<BasicScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    Home_Page(),
    Settings_Page(),
    Projects_Page(),
    // Project_Page(name: "Temporary Project (Photo)"),
    Project_Video_Page(name: "Temporary Project (Video)"),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 53, 58, 83),
        title: const Text('AIiS'),
        centerTitle: true,
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            SizedBox(height: 20),
            Image.asset('assets/aiis_logo.png', height: 125, width: 100),
            GestureDetector(
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.home)),
                title: const Text('Home page', style: TextStyle(fontSize: 25)),
              ),
            ),
            SizedBox(height: 10),
            // GestureDetector(
            //   onTap: () {
            //     _onItemTapped(1);
            //     Navigator.pop(context);
            //   },
            //   child: ListTile(
            //     leading: const CircleAvatar(child: Icon(Icons.settings)),
            //     title: const Text('Settings', style: TextStyle(fontSize: 25)),
            //   ),
            // ),
            GestureDetector(
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.folder)),
                title: const Text('Projects', style: TextStyle(fontSize: 25)),
              ),
            ),
            SizedBox(height: 10),
            // GestureDetector(
            //   onTap: () {
            //     _onItemTapped(3);
            //     Navigator.pop(context);
            //   },
            //   child: ListTile(
            //     leading: const CircleAvatar(child: Icon(Icons.image)),
            //     title: const Text('Temporary Project (Photo)',
            //         style: TextStyle(fontSize: 25)),
            //   ),
            // ),
            // SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                _onItemTapped(3);
                Navigator.pop(context);
              },
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.videocam)),
                title:
                    const Text('Video Project', style: TextStyle(fontSize: 25)),
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                final Uri url = Uri.parse('http://www.aiengineer.tw');
                launchUrl(url);
              },
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.info)),
                title: const Text('About us', style: TextStyle(fontSize: 25)),
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
    );
  }
}
