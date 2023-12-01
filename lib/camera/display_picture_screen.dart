import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final String username;

  const DisplayPictureScreen(
      {super.key, required this.imagePath, required this.username});

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

  Future<String> _uploadImage(String imagePath) async {
    String description = "";
    final url = Uri.parse('http://140.112.12.167:8000/uploadImageForSeminar/');
    final request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('photo', imagePath));
    final response = await request.send();
    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(await response.stream.bytesToString());
      description = data["description"];
    }
    return description;
  }

  Future<void> _uploadImageInfo(String description, String user_id) async {
    final url = Uri.parse('http://140.112.12.167:8000/update/');
    List<int> bytes = File(imagePath).readAsBytesSync();
    String base64Image = base64Encode(bytes);
    Map<String, dynamic> data = {
      'Image': base64Image,
      'Latitude': 53.8,
      'Longitude': -1.7,
      'Description': description,
      'UserID': user_id,
    };
    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        elevation: 0,
        backgroundColor: Colors.black26,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm'),
                  content:
                      const Text('Are you sure you want to upload this photo?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          String description = await _uploadImage(imagePath);
                          // ignore: use_build_context_synchronously
                          showLoadingDialog(context);
                          // ignore: use_build_context_synchronously
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Description'),
                                  content: TextField(
                                    onChanged: (value) {
                                      description = value;
                                    },
                                    decoration: const InputDecoration(
                                      hintText: 'Modify the description',
                                    ),
                                    controller: TextEditingController(
                                        text: description),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        if (description != '') {
                                          await _uploadImageInfo(
                                            description,
                                            username,
                                          );
                                        }
                                        Fluttertoast.showToast(
                                            msg: "Photo uploaded!",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.green,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              });
                        },
                        child: const Text('Upload')),
                  ],
                ),
              );
              // Navigator.of(context).pop(imagePath);
              // Navigator.of(context).pop(imagePath);
            },
          )
        ],
      ),
      body: Container(
        child: Image.file(
          File(imagePath),
        ),
      ),
    );
  }
}
