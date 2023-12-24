import 'package:bloodbridge/widgets/getchatdata.dart';
import 'package:bloodbridge/widgets/newmessage.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.friend_id,
    required this.friend_state,
    required this.friend_district,
    required this.friend_name,
    required this.phonenumber,
  });
  final String friend_id;
  final String friend_district;
  final String friend_state;
  final String friend_name;
  final String phonenumber;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: getchatdata(
              friendid: widget.friend_id,
              friendname: widget.friend_name,
              friend_district: widget.friend_district,
              friend_state: widget.friend_state,
              phonenumber: widget.phonenumber,
            ),
          ),
          NewMessage(
            friend_id: widget.friend_id,
            friend_district: widget.friend_district,
            friend_state: widget.friend_state,
          ),
        ],
      ),
    );
  }
}
