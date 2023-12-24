import 'package:flutter/material.dart';

class styled_date extends StatelessWidget {
  const styled_date({super.key, required this.date});
  final String date;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onBackground,
          // color: Color.fromARGB(255, 202, 176, 176).withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3), // Shadow color
              spreadRadius: 5, // Spread radius
              blurRadius: 10, // Blur radius
              offset: const Offset(0, 3), // Offset in x and y directions
            ),
          ]),
      child: Text(
        date,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }
}
