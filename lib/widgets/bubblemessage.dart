import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class bubblemessage extends StatelessWidget {
  const bubblemessage(
      {super.key,
      required this.message,
      required this.isMe,
      required this.time});
  final bool isMe;
  final String message;
  final Timestamp time;

  String gettime(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var ist = dateTime.toUtc().add(const Duration(hours: 5, minutes: 30));
    var formatter = DateFormat('hh:mm a');
    String formattedDateTime = formatter.format(ist);
    return formattedDateTime;
  }

  @override
  Widget build(BuildContext context) {
    var ind = time.toString().indexOf(",");
    String timeString = time.toString().substring(18, ind);
    final timeInt = int.tryParse(timeString);
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isMe
                ? Colors.grey[300]
                : Theme.of(context).colorScheme.secondary.withAlpha(200),
            borderRadius: BorderRadius.only(
              topLeft: !isMe ? Radius.zero : const Radius.circular(12),
              topRight: isMe ? Radius.zero : const Radius.circular(12),
              bottomLeft: const Radius.circular(12),
              bottomRight: const Radius.circular(12),
            ),
          ),
          constraints: const BoxConstraints(maxWidth: 200, minWidth: 80),
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 14,
          ),
          margin: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 12,
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Text(
                    message,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 15,
                      color: isMe
                          ? Colors.black87
                          : Theme.of(context).colorScheme.onSecondary,
                    ),
                    softWrap: true,
                  ),
                  const SizedBox(
                    height: 15,
                  )
                ],
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Text(
                  textAlign: TextAlign.center,
                  gettime(timeInt!),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe
                        ? Colors.black87
                        : Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
