import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'dart:io';

class ImageDetail extends StatefulWidget {
  ImageDetail(this.filepath);
  final String filepath;

  @override
  _ImageDetailState createState() => new _ImageDetailState(filepath);
}

class _ImageDetailState extends State<ImageDetail> {
  _ImageDetailState(this.filepath);

  final String filepath;

  String recognizedText = "Loading ... ";

  void _initializeVision() async {

    final File imageFile = File(filepath);

    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(imageFile);

    final TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();

    final VisionText visionText = 
    await textRecognizer.processImage(visionImage);

    String mailPattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
    RegExp regEx = RegExp(mailPattern);

    String mailAddress = "Couldn't find any mail in the photo! Please Try again !";

    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        if (regEx.hasMatch(line.text)) {
          mailAddress = line.text;
        }
      }
    }

    if (this.mounted) {
      setState(() {
        recognizedText = mailAddress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _initializeVision();

    return Scaffold(
      appBar: AppBar(title: Text("Taken Photo")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: new Container(
              height: 300,
              child: Center(child: Image.file(File(filepath))),
              ),
              ),
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Text(
                  "Extracted Text:",
                  style: Theme.of(context).textTheme.headline,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(40.0),
                child: Text(
                  recognizedText,
                  style: Theme.of(context).textTheme.body1,
                  )),
            ],
          ));

  }
}