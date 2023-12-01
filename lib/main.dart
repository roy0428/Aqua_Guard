import 'package:flutter/material.dart';
import 'login_screen.dart';
// import 'basic_screen.dart';

void main() => runApp(const StaticApp());

class StaticApp extends StatefulWidget {
  const StaticApp({super.key});

  @override
  State<StaticApp> createState() => _StaticAppState();
}

class _StaticAppState extends State<StaticApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: LoginScreen());
  }
}
