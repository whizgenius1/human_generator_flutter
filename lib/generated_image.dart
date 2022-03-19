import 'dart:typed_data';

import 'package:flutter/material.dart';

class GeneratedImage extends StatelessWidget {
  final Uint8List converterBytes;
  const GeneratedImage({Key? key, required this.converterBytes})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      width: 256,
      height: 256,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(color: Colors.white, blurRadius: 5, spreadRadius: 1)
          ]),
      child: Image.memory(
        converterBytes,
        fit: BoxFit.cover,
      ),
    );
  }
}
