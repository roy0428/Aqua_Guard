import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import './drawer_page/home.dart';
import './drawer_page/profile.dart';
import './drawer_page/statistic_example.dart';

class BasicScreen extends StatefulWidget {
  final String username;

  const BasicScreen({
    super.key,
    required this.username,
  });

  @override
  // ignore: no_logic_in_create_state
  State<BasicScreen> createState() => _BasicScreenState(username: username);
}

class _BasicScreenState extends State<BasicScreen> {
  final String username;
  _BasicScreenState({
    required this.username,
  });

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget listItem(BuildContext context, int index, IconData icon, String string, bool page) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (page) {
              _onItemTapped(index);
              Navigator.pop(context);
            } else {
              if (index == 0) {
                launchUrl(Uri.parse('http://www.aiengineer.tw'));
              } else if (index == 1) {
                launchUrl(Uri.parse('https://www.wrcgroup.com/about/'));
              } else if (index == 2) {
                launchUrl(Uri.parse('http://rainplusplus.com'));
              } else if (index == 3) {
                launchUrl(Uri.parse('https://www.gov.uk/government/organisations/natural-england'));
              }
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
    final List<Widget> _widgetOptions = <Widget>[
      HomePage(username: username),
      ProfilePage(),
      Statistic_page(),
    ];

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 20),
            Image.asset('assets/moisture.png', height: 125, width: 100),
            listItem(context, 0, Icons.home, 'Home page', true),
            listItem(context, 1, Icons.account_circle, 'Profile', true),
            listItem(context, 2, Icons.assessment, 'Statistics', true),
            listItem(context, 1, Icons.info, 'Water Research Centre', false),
            listItem(context, 2, Icons.info, 'Rain++', false),
            listItem(context, 3, Icons.info, 'Natural England', false),
            listItem(context, 0, Icons.info, 'About us', false),
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
