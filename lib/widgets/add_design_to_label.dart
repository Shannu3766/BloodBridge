import 'package:flutter/material.dart';

class add_design_to_label extends StatelessWidget {
  const add_design_to_label({
    super.key,
    required this.label,
  });
  final String label;
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Container(
      // margin: EdgeInsets.symmetric(horizontal: width * 0.1),
      width: width,
      height: height * 0.04,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            width: 2.0,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          gradient: LinearGradient(colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primaryContainer
          ])),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(),
      ),
    );
  }
}
