import 'package:bloodbridge/providers/friendslist_acceptedprovider.dart';
import 'package:bloodbridge/providers/friendslist_requestedprovider.dart';
import 'package:bloodbridge/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Friend_card extends ConsumerStatefulWidget {
  const Friend_card({
    super.key,
    required this.name,
    required this.phonenumber,
    required this.url,
    required this.bloodGroup,
    required this.userid,
    required this.onaddfriend,
    required this.userdistrict,
    required this.userState,
  });
  final String name;
  final String phonenumber;
  final String url;
  final String bloodGroup;
  final String userid;
  final String userdistrict;
  final String userState;
  final void Function(
    String friend_id,
    String friend_state,
    String friend_dist,
  ) onaddfriend;
  @override
  ConsumerState<Friend_card> createState() => _Friend_cardState();
}

class _Friend_cardState extends ConsumerState<Friend_card> {
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
              '+91${widget.phonenumber.substring(0, 3)}XXXXX${widget.phonenumber.substring(9)}'),
          // Text(
          // '+91 ${widget.phonenumber}',
          // ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.bloodGroup,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 20),
              IconButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return ChatScreen(
                      friend_district: widget.userdistrict,
                      friend_state: widget.userState,
                      friend_id: widget.userid,
                      friend_name: widget.name,
                      phonenumber: widget.phonenumber,
                    );
                  }));
                },
                icon: const Icon(Icons.chat),
              ),
            ],
          ),
        ),
        const Divider(height: 0),
      ],
    );
  }
}
