import 'package:flutter/material.dart';
import 'login_screen.dart';

void main() => runApp(StaticApp());

class StaticApp extends StatefulWidget {
  @override
  _StaticAppState createState() => _StaticAppState();
}

class _StaticAppState extends State<StaticApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: LoginScreen());
  }
}
