import 'package:bloodbridge/providers/userdataProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewMessage extends ConsumerStatefulWidget {
  const NewMessage({
    super.key,
    required this.friend_id,
    required this.friend_state,
    required this.friend_district,
  });
  final String friend_id;
  final String friend_district;
  final String friend_state;
  @override
  ConsumerState<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends ConsumerState<NewMessage> {
  final messagecontroller = TextEditingController();
  String? userid;
  String? userstate;
  String? userdist;
  @override
  void initState() {
    final userdata = ref.read(userdataProvider);
    userid = userdata[0];
    userstate = userdata[1];
    userdist = userdata[2]; // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    messagecontroller.dispose();
    super.dispose();
  }

  void sendmessage() async {
    FocusScope.of(context).unfocus(); //closes all the opened keyboards
    if (messagecontroller.text.trim().isEmpty) {
      return;
    }
    final message = messagecontroller.text;
    setState(() {
      messagecontroller.clear();
    });
    await FirebaseFirestore.instance
        .collection(userstate.toString().trim())
        .doc(userdist.toString().trim())
        .collection("users")
        .doc(userid)
        .collection("friends")
        .doc(widget.friend_id)
        .collection("chat")
        .doc()
        .set({
      'issend': true,
      'Text': message,
      'CreatedAt': DateTime.now(),
    });
    await FirebaseFirestore.instance
        .collection(widget.friend_state.toString().trim())
        .doc(widget.friend_district.toString().trim())
        .collection("users")
        .doc(widget.friend_id)
        .collection("friends")
        .doc(userid)
        .collection("chat")
        .doc()
        .set({'issend': false, 'Text': message, 'CreatedAt': DateTime.now()});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
              child: TextField(
            controller: messagecontroller,
            textCapitalization: TextCapitalization.sentences,
            autocorrect: true,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 20),
            decoration: const InputDecoration(
                label: Text(
              "Message",
              style: TextStyle(fontSize: 20),
            )),
          )),
          IconButton(
              onPressed: () {
                sendmessage();
              },
              icon: const Icon(Icons.send))
        ],
      ),
    );
  }
}
