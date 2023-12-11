import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:Aqua_Guard/camera/take_picture_screen.dart';

class ProcessedData {
  String imageid;
  double latitude;
  double longitude;
  String id;

  ProcessedData({
    required this.imageid,
    required this.latitude,
    required this.longitude,
    required this.id,
  });
}

class InformationData {
  String date;
  String time;
  String description;

  InformationData({
    required this.date,
    required this.time,
    required this.description,
  });
}

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({
    super.key,
    required this.username,
  });

  @override
  // ignore: no_logic_in_create_state
  State<HomePage> createState() => _HomePageState(username: username);
}

class _HomePageState extends State<HomePage> {
  final String username;
  _HomePageState({
    required this.username,
  });
  late GoogleMapController mapController;
  late Set<Marker> markers = {};
  List<ProcessedData> resultList = [];

  Future<List<ProcessedData>> _uploadLocation(double latitude, double longitude) async {
    Map<String, double> data = {'Latitude': latitude, 'Longitude': longitude};
    final url = Uri.parse('http://140.112.12.167:8000/uploadlocation/');
    http.Response response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    List<ProcessedData> resultList = [];
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      for (int i = 0; i < data['images']['ImageID'].length; i++) {
        ProcessedData processedData = ProcessedData(
          imageid: data['images']['ImageID'][i],
          latitude: data['images']['Latitude'][i],
          longitude: data['images']['Longitude'][i],
          id: data['images']['UserID'][i],
        );
        resultList.add(processedData);
      }
    }
    return resultList;
  }

  Future<InformationData> _uploadID(String imageID) async {
    final url = Uri.parse('http://140.112.12.167:8000/uploadid/');
    Map<String, String> data = {'ImageID': imageID};
    InformationData info = InformationData(
      date: "None",
      time: "None",
      description: "None",
    );
    http.Response response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      final Directory cacheDirectory = await getTemporaryDirectory();
      final path = '${cacheDirectory.path}/cache.jpeg';
      final Map<String, dynamic> data = json.decode(response.body);
      await File(path).writeAsBytes(base64Decode(data['image']['Image']), flush: true);
      setState(() => {imageCache.clear(), imageCache.clearLiveImages()});
      info.date = data['image']['Date'];
      info.time = data['image']['Time'];
      info.description = data['image']['Description'];
      // print(data['image']['Description']);
    }
    return info;
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    resultList = await _uploadLocation(53.8346519470215, -1.771159053);
    final Directory cacheDirectory = await getTemporaryDirectory();
    final path = '${cacheDirectory.path}/cache.jpeg';
    setState(() {
      markers = Set.from(
        resultList.map(
          (data) {
            BitmapDescriptor markerIcon = data.id != username
                ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
                : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
            return Marker(
              markerId: MarkerId('${data.latitude}-${data.longitude}'),
              position: LatLng(data.latitude, data.longitude),
              infoWindow: InfoWindow(title: data.imageid),
              icon: markerIcon,
              onTap: () async {
                InformationData info = await _uploadID(data.imageid);
                // ignore: use_build_context_synchronously
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ResultPage(
                              imagePath: path,
                              projectName: data.imageid,
                              info: info,
                              uploader: data.id,
                            )));
              },
            );
          },
        ),
      );
    });
    return;
  }

  void _pushToCamera(BuildContext context) async {
    final cameras = await availableCameras();
    // ignore: use_build_context_synchronously
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakePictureScreen(
          camera: cameras.first,
          username: username,
        ),
      ),
    );
    await fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GoogleMap(
          mapType: MapType.hybrid,
          myLocationButtonEnabled: false,
          onMapCreated: (controller) {
            setState(() {
              mapController = controller;
            });
          },
          initialCameraPosition: const CameraPosition(
            target: LatLng(53.8346519470215, -1.771159053),
            zoom: 15.0,
          ),
          markers: markers,
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: UniqueKey(),
          onPressed: () async {
            _pushToCamera(context);
          },
          child: const Icon(Icons.camera_alt),
        ));
  }
}

class ResultPage extends StatefulWidget {
  final String imagePath;
  final String projectName;
  final InformationData info;
  final String uploader;

  const ResultPage(
      {super.key,
      required this.imagePath,
      required this.projectName,
      required this.info,
      required this.uploader});

  @override
  State<ResultPage> createState() =>
      // ignore: no_logic_in_create_state
      _ResultPageState(
          imagePath: imagePath, imageName: projectName, info: info, uploader: uploader);
}

class _ResultPageState extends State<ResultPage> {
  final String imagePath;
  final String imageName;
  final InformationData info;
  final String uploader;
  _ResultPageState(
      {required this.imagePath,
      required this.imageName,
      required this.info,
      required this.uploader});

  void _showReportDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm'),
            content: const Text('Are you sure you want to report this photo?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Fluttertoast.showToast(
                      msg: "Report successed!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Report'),
              ),
            ],
          );
        });
  }

  void _showInformationDialog(BuildContext context, InformationData info) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Information'),
          content: Text(
              'Uploader: $uploader\nDate: ${info.date}\nTime: ${info.time}\nDescription: ${info.description}'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                _showReportDialog(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Report'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSaveDialog(BuildContext context) {
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
                await GallerySaver.saveImage(imagePath);
                Fluttertoast.showToast(
                    msg: "Photo saved!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0);
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
              child: const Text('Save')),
        ],
      ),
    );
  }

  @override
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
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 5,
                  child: Image.file(
                    File(imagePath),
                  )),
            )
          ],
        ),
        floatingActionButton: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              heroTag: UniqueKey(),
              onPressed: () {
                _showInformationDialog(context, info);
              },
              child: const Icon(Icons.info),
            )));
  }
}
