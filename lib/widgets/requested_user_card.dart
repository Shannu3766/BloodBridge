import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class requested_user_card extends StatefulWidget {
  const requested_user_card({
    super.key,
    required this.name,
    required this.phonenumber,
    required this.url,
    required this.bloodGroup,
    required this.userid,
    required this.userdistrict,
    required this.userState,
    required this.accept_friend,
    required this.rejectfriend,
  });
  final String name;
  final String phonenumber;
  final String url;
  final String bloodGroup;
  final String userid;
  final String userdistrict;
  final String userState;
  final void Function(String friend_id, String friend_state, String friend_dist)
      accept_friend;
  final void Function(String friend_id, String friend_state, String friend_dist)
      rejectfriend;
  @override
  State<requested_user_card> createState() => _requested_user_cardState();
}

class _requested_user_cardState extends State<requested_user_card> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.black,
            foregroundImage: CachedNetworkImageProvider(widget.url),
            backgroundImage: const AssetImage("assests/images/person.png"),
          ),
          title: Text(
            widget.name[0].toUpperCase() + widget.name.substring(1),
          ),
          subtitle: Text(
            '+91${widget.phonenumber.substring(0, 3)}XXXXX${widget.phonenumber.substring(9)}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                  onPressed: () {
                    widget.accept_friend(
                        widget.userid, widget.userState, widget.userdistrict);
                  },
                  icon: const Icon(Icons.check_circle_rounded,
                      size: 30, color: Colors.greenAccent)),
              IconButton(
                icon: const Icon(Icons.cancel_rounded,
                    size: 30, color: Colors.red),
                onPressed: () {
                  widget.rejectfriend(
                      widget.userid, widget.userState, widget.userdistrict);
                },
              ),
            ],
          ),
        ),
        const Divider(height: 0),
      ],
    );
  }
}
