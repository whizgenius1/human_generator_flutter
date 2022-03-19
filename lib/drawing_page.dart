import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:human_generator/generated_image.dart';
import 'package:human_generator/sketcher.dart';
import 'package:http/http.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'drawn_line.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({Key? key}) : super(key: key);

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  final GlobalKey _globalKey = GlobalKey();

  List<DrawnLine> _lines = <DrawnLine>[];
  DrawnLine _line = DrawnLine([], Colors.white, 2);

  final StreamController<DrawnLine> _currentLineStreamController =
      StreamController<DrawnLine>.broadcast();

  final StreamController<List<DrawnLine>> _linesStreamController =
      StreamController<List<DrawnLine>>.broadcast();

  Widget imageOutPut = Container(
    margin: const EdgeInsets.all(10),
    width: 256,
    height: 256,
    decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.white, blurRadius: 5, spreadRadius: 1)
        ]),
  );

  Uint8List? image;
  Future<Uint8List> saveToImage({required List<DrawnLine> lines}) async {
    // ui.PictureRecorder recorder = ui.PictureRecorder();
    //
    // Canvas canvas = Canvas(recorder,
    //     Rect.fromPoints(const Offset(0.0, 0.0), const Offset(200, 200)));
    //
    // Paint paint = Paint()
    //   ..color = Colors.white
    //   ..strokeCap = StrokeCap.round
    //   ..strokeWidth = 2.0;
    //
    // Paint paint2 = Paint()
    //   ..style = PaintingStyle.fill
    //   ..color = Colors.black;
    //
    // canvas.drawRect(const Rect.fromLTWH(0, 0, 256, 256), paint2);
    //
    // for (int i = 0; i < lines.length; ++i) {
    //   if (lines[i] == null) continue;
    //   for (int j = 0; j < lines[i].path.length - 1; ++j) {
    //     if (lines[i].path[j] != null && lines[i].path[j + 1] != null) {
    //       paint.color = lines[i].color;
    //       paint.strokeWidth = lines[i].width;
    //       canvas.drawLine(lines[i].path[j], lines[i].path[j + 1], paint);
    //     }
    //   }
    // }
    //
    // final picture = recorder.endRecording();
    // final img = await picture.toImage(256, 256);
    // final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
    // final listBytes = Uint8List.view(pngBytes!.buffer);
    // String base64 = base64Encode(listBytes);

    ///
    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    String base64Image = base64Encode(pngBytes);
    //
    return await fetchData(base64Image: base64Image).then((value) => value);
  }

  Future<Uint8List> fetchData({required String base64Image}) async {
    Map<String, String> body = {"Image": base64Image};
    String url = 'http://10.0.2.2:5000/predict';
    Map<String, String> headers = {
      "Content-type": "application/json",
      "Accept": "application/json",
      "Connection": "Keep-Alive"
    };

    String encodedBody = json.encode(body);
    return await post(Uri.parse(url), body: encodedBody, headers: headers)
        .then((Response response) async {
      Map<String, dynamic> responseBody = json.decode(response.body);
      String outputBytes = responseBody['Image'];

      Uint8List converterBytes =
          base64Decode(outputBytes.substring(2, outputBytes.length - 1));

      return converterBytes;

      // debugPrint('output:${outputBytes.substring(2, outputBytes.length - 1)}');
      // displayResponseImage(
      //     bytes: outputBytes.substring(2, outputBytes.length - 1));
    });
  }
  //
  // Future<void> displayResponseImage({required String bytes}) async {
  //   try {
  //     Uint8List converterBytes = base64Decode(bytes);
  //     setState(() {
  //       imageOutPut = Container(
  //         width: 256,
  //         height: 256,
  //         child: Image.memory(
  //           converterBytes,
  //           fit: BoxFit.cover,
  //         ),
  //       );
  //     });
  //   } catch (e) {
  //     print('error:$e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    void onPanDown(DragDownDetails details) {
      // RenderBox box = context.findRenderObject();
      // Offset point = context.findRenderObject().globalToLocal(details.globalPosition);

      Offset point = details.localPosition;
      setState(() {
        _line = DrawnLine([point], Colors.white, 2);
      });
    }

    void onPanUpdate(DragUpdateDetails details) {
      Offset point = details.localPosition;

      List<Offset> path = List.from(_line.path)..add(point);
      setState(() {
        _line = DrawnLine(path, Colors.white, 2);
        _currentLineStreamController.add(_line);
      });
    }

    void onPanEnd(DragEndDetails details) {
      setState(() {
        _lines = List.from(_lines)..add(_line);
        _linesStreamController.add(_lines);
      });

      saveToImage(lines: _lines);
    }

    return Scaffold(
        backgroundColor: const Color(0xFFF4F7FC),
        //backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Drawing Area'),
        ),
        body: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                Color.fromRGBO(138, 35, 135, 1),
                Color.fromRGBO(233, 64, 87, 1),
                Color.fromRGBO(242, 113, 33, 1),
              ])),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: _lines.isEmpty
                    ? imageOutPut
                    : FutureBuilder(
                        future: saveToImage(lines: _lines),
                        builder: (_, AsyncSnapshot snapshot) {

                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return imageOutPut;
                            case ConnectionState.done:
                              return GeneratedImage(
                                converterBytes: snapshot.data,
                              );
                            default:
                              return imageOutPut;
                          }
                        },
                      ),
                //child: imageOutPut,
                // child: Container(
                //   margin: const EdgeInsets.fromLTRB(50, 0, 50, 20),
                //   width: 256,
                //   height: 256,
                //   alignment: Alignment.center,
                //   color: Colors.orange,
                // ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(50, 0, 50, 20),
                  width: 256,
                  height: 256,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black, blurRadius: 5, spreadRadius: 1)
                      ]),
                  child: Stack(
                    children: [
                      RepaintBoundary(
                        key: _globalKey,
                        child: Container(
                            width: 256,
                            height: 256,
                            color: Colors.transparent,
                            padding: const EdgeInsets.all(4),
                            alignment: Alignment.topLeft,
                            child: StreamBuilder<List<DrawnLine>>(
                              stream: _linesStreamController.stream,
                              builder: (_, snapshot) => CustomPaint(
                                painter:
                                    Sketcher(lines: _lines, strokeWidth: 2),
                              ),
                            )),
                      ),
                      GestureDetector(
                        onPanDown: onPanDown,
                        onPanUpdate: onPanUpdate,
                        onPanEnd: onPanEnd,
                        child: RepaintBoundary(
                          child: Container(
                            width: 256,
                            height: 256,
                            padding: const EdgeInsets.all(4.0),
                            color: Colors.transparent,
                            alignment: Alignment.topLeft,
                            child: StreamBuilder<DrawnLine>(
                              stream: _currentLineStreamController.stream,
                              builder: (context, snapshot) {
                                return CustomPaint(
                                  painter:
                                      Sketcher(lines: [_line], strokeWidth: 1),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(50, 0, 50, 10),
                    child: ElevatedButton(
                      child: const Text('Clear'),
                      onPressed: () => setState(() {
                        _lines = [];
                        _line = DrawnLine([], Colors.white, 2);
                      }),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(50, 0, 50, 10),
                    child: ElevatedButton(
                      child: const Text('Remove last'),
                      onPressed: () => setState(() {
                        _lines.removeLast();
                        _line = DrawnLine([], Colors.white, 2);
                      }),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(50, 0, 50, 10),
                      child: ElevatedButton(
                          child: const Text('Save Sketch'),
                          onPressed: () async {
                            try {
                              RenderRepaintBoundary boundary =
                                  _globalKey.currentContext!.findRenderObject()
                                      as RenderRepaintBoundary;
                              ui.Image image = await boundary.toImage();
                              ByteData? byteData = await image.toByteData(
                                  format: ui.ImageByteFormat.png);
                              Uint8List pngBytes =
                                  byteData!.buffer.asUint8List();
                              var saved = await ImageGallerySaver.saveImage(
                                pngBytes,
                                quality: 100,
                                name: DateTime.now().toIso8601String() + ".png",
                                isReturnImagePathOfIOS: true,
                              );
                              print(saved);
                            } catch (e) {
                              print(e);
                            }
                          }),
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder(
                      future: saveToImage(lines: _lines),
                      builder: (context,AsyncSnapshot snapshot) {
                        if(snapshot.hasData){
                          return Container(
                            margin: const EdgeInsets.fromLTRB(50, 0, 50, 10),
                            child: ElevatedButton(
                                child: const Text('Save Image'),
                                onPressed: () async {
                                  var saved = await ImageGallerySaver.saveImage(
                                    snapshot.data,
                                    quality: 100,
                                    name: DateTime.now().toIso8601String() + ".png",
                                    isReturnImagePathOfIOS: true,
                                  );
                                  print(saved);
                                }),
                          );
                        }
                        return  const Center();

                      }
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
