import 'dart:math';

import 'package:flutter/material.dart';
import 'package:interstellar/src/screens/create_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:path/path.dart';

class ImageSelector extends StatefulWidget {

  const ImageSelector(this.onSelected, {super.key});

  final void Function(File?) onSelected;

  @override
  State<ImageSelector> createState() => _ImageSelectorState();
}

class _ImageSelectorState extends State<ImageSelector> {

  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: _selectedImage == null ?
        Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            child: IconButton(
              onPressed: () async {
                XFile? image = await _imagePicker.pickImage(
                    source: ImageSource.gallery
                );
                if (image != null) {
                  setState(() {
                    _selectedImage = File(image.path);
                    widget.onSelected(_selectedImage);
                  });
                }
              },
              tooltip: 'Upload from gallery',
              iconSize: 35,
              icon: const Icon(Icons.image),
            ),
          ),
          if (Platform.isAndroid || Platform.isIOS)
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
              child: IconButton(
                onPressed: () async {
                  XFile? image = await _imagePicker.pickImage(
                      source: ImageSource.camera
                  );
                  if (image != null) {
                    setState(() {
                      _selectedImage = File(image.path);
                      widget.onSelected(_selectedImage);
                    });
                  }
                },
                tooltip: 'Upload from camera',
                iconSize: 35,
                icon: const Icon(Icons.camera),
              ),
            )
        ],
      ) :
      Row(
        children: [
          Text(basename(_selectedImage!.path)),
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _selectedImage = null;
                  widget.onSelected(null);
                });
              },
              icon: const Icon(Icons.close)
            )
          )
        ],
      )
    );
  }
}
