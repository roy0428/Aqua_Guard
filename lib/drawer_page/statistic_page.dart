import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class StatisticPage extends StatelessWidget {
  final String imagePath;
  final String imageName;
  
  StatisticPage({
    required this.imagePath,
    required this.imageName,
  });

  void _showSaveDialog(BuildContext context) {
    Future<void> saveImageToGallery(String imagePath) async {
      ByteData data = await rootBundle.load(imagePath);
      List<int> bytes = data.buffer.asUint8List();
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path + '/temp_image.png';
      File(tempPath).writeAsBytesSync(bytes);
      await GallerySaver.saveImage(tempPath);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Are you sure you want to save this photo?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
              onPressed: () async {
                await saveImageToGallery(imagePath);
                Fluttertoast.showToast(
                    msg: "Photo saved!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Save')),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 53, 58, 83),
          title: Text(
            imageName,
            style: const TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              onPressed: () {
                _showSaveDialog(context);
              },
            )
          ]),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
              child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 5,
                  child: Image.asset(imagePath)
              )
          )
        ],
      ),
    );
  }
}
