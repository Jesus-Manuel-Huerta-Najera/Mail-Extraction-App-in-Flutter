import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'load_image.dart';


List<CameraDescription> cameras;

Future<void> main() async {
  cameras = await availableCameras();
  runApp(MyApp());
}




class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Mail Extractor'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CameraController _controller;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }

      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _takePicturePressed() {
    _takePicture().then((String filepath) {
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ImageDetail(filepath)));
      }
    });
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<String> _takePicture() async {
    if (!_controller.value.isInitialized) {
      print("Controller is not yet initlialized.");
      return null;
    }

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String photoDir = '${extDir.path}/Photos/image_test';
    await Directory(photoDir).create(recursive: true);
    final String filepath = '$photoDir/${timestamp()}.jpg';

    if (!_controller.value.isTakingPicture) {
      print("Currently already taking a picture");
      return null;
    }

    try {
      await _controller.takePicture(filepath);
    } on CameraException catch (e) {
      print("Camera exception occured: $e");
      return null;
    }

    return filepath;
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Center(child: Text("Controller is not yet initialized !"));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          verticalDirection: VerticalDirection.up,
          children: <Widget>[
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: CameraPreview(_controller),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: RaisedButton.icon(
                  icon: Icon(Icons.camera),
                  label: Text("Take Picture"),
                  onPressed: _takePicturePressed,
                  ),
              ),
            )  
          ],
        ),
      ),
    );
  }

  }
