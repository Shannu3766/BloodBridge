import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Image_source_selector extends StatefulWidget {
  const Image_source_selector({
    super.key,
    required this.icon,
    required this.text,
    required this.onimagesource,
  });
  final IconData icon;
  final String text;
  final void Function(ImageSource imageSource) onimagesource;
  @override
  State<Image_source_selector> createState() => _Image_source_selectorState();
}

class _Image_source_selectorState extends State<Image_source_selector> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 3;
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        child: InkWell(
          onTap: () {
            widget.onimagesource((widget.text == "Camera")
                ? ImageSource.camera
                : ImageSource.gallery);
          },
          child: Column(children: [
            Expanded(
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  return Icon(
                    widget.icon,
                    size: width,
                  );
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextButton(
                onPressed: () {
                  // print(width.toDouble());
                },
                child: Text(widget.text))
          ]),
        ),
      ),
    );
  }
}
