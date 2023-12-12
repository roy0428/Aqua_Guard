import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'basic_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Future<bool> checkValid(String username, String password) async {
    Map<String, String> data = {'username': username, 'password': password};
    String jsonData = jsonEncode(data);
    Uri url = Uri.parse('http://140.112.12.167:8000/login/');
    http.Response response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonData,
    );
    return (response.statusCode == 200) ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 53, 58, 83),
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Image.asset('assets/CAE.png', height: 140, width: 350),
            ),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                String username = _usernameController.text;
                String password = _passwordController.text;
                bool valid = await checkValid(username, password);
                if (valid) {
                  // ignore: use_build_context_synchronously
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BasicScreen(username: username)),
                  );
                } else {
                  _passwordController.text = '';
                  Fluttertoast.showToast(
                      msg: "Wrong username or password!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
