import 'package:bloodbridge/widgets/Image_data_selection.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class User_image_picker extends StatefulWidget {
  const User_image_picker({
    super.key,
    required this.onpickimage,
  });
  final void Function(File _pickedImage) onpickimage;
  @override
  State<User_image_picker> createState() => _User_image_pickerState();
}

class _User_image_pickerState extends State<User_image_picker> {
  ImageSource? imagesource;
  var imageuploaded = false;
  File? _pickedImagefile;
  void pickImage(ImageSource imgscr) async {
    final pickedImage = await ImagePicker().pickImage(
      source: imgscr,
      imageQuality: 100,
    );
    if (pickedImage == null) {
      return;
    }
    setState(() {
      _pickedImagefile = File(pickedImage.path);
      imageuploaded = true;
    });
    widget.onpickimage(_pickedImagefile!);
  }

  void _uploadimage() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext ctx) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Row(
                children: [
                  Image_source_selector(
                    icon: Icons.photo_camera_outlined,
                    text: "Camera",
                    onimagesource: (value) {
                      setState(() {
                        pickImage(value);
                        // print(value);
                      });
                      Navigator.pop(context);
                    },
                  ),
                  Image_source_selector(
                    icon: Icons.photo_library_outlined,
                    text: "Gallery",
                    onimagesource: (value) {
                      pickImage(value);
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            ),
          );
        });
    // pickImage(imagesource!);
    // print(imagesource);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      // width: 100,
      child: Column(
        children: [
          InkWell(
            onTap: _uploadimage,
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              radius: 60,
              foregroundImage:
                  (imageuploaded) ? FileImage(_pickedImagefile!) : null,
              child: (!imageuploaded)
                  ? IconButton(
                      onPressed: () {
                        _uploadimage();
                      },
                      icon: Icon(
                        Icons.add_a_photo,
                        size: 50,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    )
                  : null,
            ),
          )
        ],
      ),
    );
  }
}
