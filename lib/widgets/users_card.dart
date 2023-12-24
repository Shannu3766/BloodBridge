import 'package:bloodbridge/providers/friendslist_acceptedprovider.dart';
import 'package:bloodbridge/providers/friendslist_requestedprovider.dart';
import 'package:bloodbridge/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class User_card extends ConsumerStatefulWidget {
  const User_card({
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
  ConsumerState<User_card> createState() => _User_cardState();
}

class _User_cardState extends ConsumerState<User_card> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Color.fromARGB(255, 201, 102, 72), // Specify your desired border color here
                width: 3, // Specify the border width
              ),
            ),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.black,
              foregroundImage: CachedNetworkImageProvider(widget.url),
              backgroundImage: const AssetImage("assests/images/person.png"),
            ),
          ),
          title: Text(
            widget.name[0].toUpperCase() + widget.name.substring(1),
            style: TextStyle(
                fontSize: 18, fontFamily: GoogleFonts.openSans().fontFamily),
          ),
          subtitle: Text(
            (ref
                    .read(friendlist_acceptedprovider.notifier)
                    .is_friend(widget.userid))
                ? '+91 ${widget.phonenumber}'
                : '+91${widget.phonenumber.substring(0, 3)}XXXXX${widget.phonenumber.substring(9)}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.bloodGroup,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 20),
              if (ref
                  .read(friendlist_acceptedprovider.notifier)
                  .is_friend(widget.userid))
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
              if (ref
                  .read(friendlist_requestedprovider.notifier)
                  .is_friend(widget.userid))
                IconButton(
                    onPressed: () {}, icon: const Icon(Icons.question_mark)),
              if (!ref
                      .read(friendlist_acceptedprovider.notifier)
                      .is_friend(widget.userid) &&
                  (!ref
                      .read(friendlist_requestedprovider.notifier)
                      .is_friend(widget.userid)))
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: () {
                    widget.onaddfriend(
                      widget.userid,
                      widget.userState,
                      widget.userdistrict,
                    );
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
