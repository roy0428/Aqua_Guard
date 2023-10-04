import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import './drawer_page/home.dart';
import './drawer_page/projects.dart';
// import './drawer_page/setting.dart';
import 'drawer_page/projects_video.dart';

class BasicScreen extends StatefulWidget {
  const BasicScreen({super.key});

  @override
  State<BasicScreen> createState() => _BasicScreenState();
}

class _BasicScreenState extends State<BasicScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    // Settings_Page(),
    const ProjectsPage(),
    const VideoProjectsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget listItem(BuildContext context, int index, IconData icon, String string,
      bool page) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (page) {
              _onItemTapped(index);
              Navigator.pop(context);
            } else {
              launchUrl(Uri.parse('http://www.aiengineer.tw'));
            }
          },
          child: ListTile(
            leading: CircleAvatar(child: Icon(icon)),
            title: Text(string, style: const TextStyle(fontSize: 25)),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 53, 58, 83),
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
            const SizedBox(height: 20),
            Image.asset('assets/aiis_logo.png', height: 125, width: 100),
            listItem(context, 0, Icons.home, 'Home page', true),
            listItem(context, 1, Icons.folder, 'Projects', true),
            listItem(context, 2, Icons.videocam, 'Video Projects', true),
            listItem(context, -1, Icons.info, 'About us', false),
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
