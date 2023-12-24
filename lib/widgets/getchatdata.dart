import 'package:bloodbridge/providers/userdataProvider.dart';
import 'package:bloodbridge/widgets/bloodrequest_widget.dart';
import 'package:bloodbridge/widgets/bubblemessage.dart';
import 'package:bloodbridge/widgets/styled_date.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class getchatdata extends ConsumerStatefulWidget {
  getchatdata({
    super.key,
    required this.friendid,
    required this.friendname,
    required this.friend_state,
    required this.friend_district,
    required this.phonenumber,
  });
  final String friendid;
  final String friendname;
  final String friend_state;
  final String friend_district;
  final String phonenumber;
  @override
  ConsumerState<getchatdata> createState() => _getchatdataState();
}

class _getchatdataState extends ConsumerState<getchatdata> {
  String? userid;
  String? userstate;
  String? userdist;
  bool visible_button = true;
  bool visible_requeststatus = false;
  late ScrollController _scrollController = ScrollController();
  var scrollcount = 0;
  int setstate_count = 0;
  Widget content = const Center(child: Text("No Messages found!!"));
  @override
  void initState() {
    final userdata = ref.read(userdataProvider);
    userid = userdata[0];
    userstate = userdata[1];
    userdist = userdata[2];
    checkrequest(); // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String getdate(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var ist = dateTime.toUtc().add(const Duration(hours: 5, minutes: 30));
    var formatter = DateFormat('dd-MMM-yy');
    String formattedDate = formatter.format(ist);
    return formattedDate;
  }

  void requestblood() async {
    String randomId = '${Random().nextInt(10000)}';
    await FirebaseFirestore.instance
        .collection(userstate.toString().trim())
        .doc(userdist.toString().trim())
        .collection("users")
        .doc(userid)
        .collection("friends")
        .doc(widget.friendid)
        .collection("chat")
        .doc("bloodrequest${randomId}")
        .set(
            {'issend': true, 'CreatedAt': DateTime.now(), 'isaccepted': false});
    await FirebaseFirestore.instance
        .collection(widget.friend_state.toString().trim())
        .doc(widget.friend_district.toString().trim())
        .collection("users")
        .doc(widget.friendid)
        .collection("friends")
        .doc(userid)
        .collection("chat")
        .doc("bloodrequest${randomId}")
        .set({
      'issend': false,
      'CreatedAt': DateTime.now(),
      'isaccepted': false
    });
    await FirebaseFirestore.instance
        .collection(userstate.toString().trim())
        .doc(userdist.toString().trim())
        .collection("users")
        .doc(userid)
        .collection("friends")
        .doc(widget.friendid)
        .update({
      "bloodshare.isrequested": "true",
      "bloodshare.accepted": "false",
      "bloodshare.lastrequested": Timestamp.now(),
    });
    await FirebaseFirestore.instance
        .collection(widget.friend_state.toString().trim())
        .doc(widget.friend_district.toString().trim())
        .collection("users")
        .doc(widget.friendid)
        .collection("friends")
        .doc(userid)
        .update({
      "bloodshare.isrequested": "false",
      "bloodshare.accepted": "false",
      "bloodshare.lastrequested": Timestamp.now(),
    });
  }

  void checkrequest() async {
    final data = await FirebaseFirestore.instance
        .collection(userstate.toString().trim())
        .doc(userdist.toString().trim())
        .collection("users")
        .doc(userid)
        .collection("friends")
        .doc(widget.friendid)
        .get();
    Timestamp lastrequested = data['bloodshare']['lastrequested'];
    String isrequested = data['bloodshare']['isrequested'];
    String accepted = data['bloodshare']['accepted'];
    print(
        "is requeted   ${isrequested == "true"}    accepted  :${accepted == "true"}   ${is24hoursago(lastrequested)}");
    if (accepted == "true" && is24hoursago(lastrequested)) {
      visible_button = true;
      return;
    }
    if (accepted == "true" && !is24hoursago(lastrequested)) {
      visible_button = false;
      return;
    }
    if (isrequested == "true" && !is24hoursago(lastrequested)) {
      visible_button = false;
      visible_requeststatus = true;
    }
  }

  bool is24hoursago(Timestamp time) {
    final DateTime timestampDateTime = DateTime.fromMillisecondsSinceEpoch(
        time.seconds * 1000 + time.nanoseconds ~/ 1000000);
    final DateTime currentDateTime = DateTime.now();
    final Duration difference = currentDateTime.difference(timestampDateTime);
    final bool was24HoursAgo = difference.inHours >= 24;
    return was24HoursAgo;
  }

  void accept_blood_request(String id) async {
    await FirebaseFirestore.instance
        .collection(userstate.toString().trim())
        .doc(userdist.toString().trim())
        .collection("users")
        .doc(userid)
        .collection("friends")
        .doc(widget.friendid)
        .collection("chat")
        .doc(id)
        .update({"isaccepted": true});
    await FirebaseFirestore.instance
        .collection(widget.friend_state.toString().trim())
        .doc(widget.friend_district.toString().trim())
        .collection("users")
        .doc(widget.friendid)
        .collection("friends")
        .doc(userid)
        .collection("chat")
        .doc(id)
        .update({"isaccepted": true});
    await FirebaseFirestore.instance
        .collection(userstate.toString().trim())
        .doc(userdist.toString().trim())
        .collection("users")
        .doc(userid)
        .collection("friends")
        .doc(widget.friendid)
        .update({"bloodshare.accepted": "true"});
    await FirebaseFirestore.instance
        .collection(widget.friend_state.toString().trim())
        .doc(widget.friend_district.toString().trim())
        .collection("users")
        .doc(widget.friendid)
        .collection("friends")
        .doc(userid)
        .update({"bloodshare.accepted": "true"});
  }

  void reject_blood_request(String id) async {
    await FirebaseFirestore.instance
        .collection(userstate.toString().trim())
        .doc(userdist.toString().trim())
        .collection("users")
        .doc(userid)
        .collection("friends")
        .doc(widget.friendid)
        .collection("chat")
        .doc(id)
        .update({"isaccepted": false});
    await FirebaseFirestore.instance
        .collection(widget.friend_state.toString().trim())
        .doc(widget.friend_district.toString().trim())
        .collection("users")
        .doc(widget.friendid)
        .collection("friends")
        .doc(userid)
        .collection("chat")
        .doc(id)
        .update({"isaccepted": false});
    await FirebaseFirestore.instance
        .collection(userstate.toString().trim())
        .doc(userdist.toString().trim())
        .collection("users")
        .doc(userid)
        .collection("friends")
        .doc(widget.friendid)
        .update({"bloodshare.accepted": "false"});
    await FirebaseFirestore.instance
        .collection(widget.friend_state.toString().trim())
        .doc(widget.friend_district.toString().trim())
        .collection("users")
        .doc(widget.friendid)
        .collection("friends")
        .doc(userid)
        .update({"bloodshare.accepted": "false"});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 171, 145),
        title: Text(widget.friendname),
        actions: [
          ElevatedButton(
            onPressed: () {
              requestblood();
              setState(() {
                visible_button = false;
                visible_requeststatus = true;
              });
            },
            child: const Text("Request Blood"),
          )
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(userstate.toString().trim())
            .doc(userdist.toString().trim())
            .collection("users")
            .doc(userid)
            .collection("friends")
            .doc(widget.friendid)
            .collection("chat")
            .orderBy('CreatedAt', descending: false)
            .snapshots(),
        builder: (context, chatsnapshopts) {
          if (!chatsnapshopts.hasData) {
            return const Center(child: Text("No message found"));
          }
          if (chatsnapshopts.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (chatsnapshopts.hasError) {
            return const Center(child: Text("Something Went Wrong"));
          }
          if (chatsnapshopts.hasData) {
            final loadedmessages = chatsnapshopts.data!.docs;
            if (loadedmessages.isEmpty) {
              return const Center(
                child: Text("No Messages Found"),
              );
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Scroll to the bottom of the list after the frame is rendered
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
              );
            });
            return ListView.builder(
              controller: _scrollController,
              itemCount: loadedmessages.length,
              itemBuilder: (context, index) {
                var ind =
                    loadedmessages[index]['CreatedAt'].toString().indexOf(",");
                String time_string = loadedmessages[index]['CreatedAt']
                    .toString()
                    .substring(18, ind);
                final time_int = int.tryParse(time_string);
                if (loadedmessages[index].id.contains("bloodrequest")) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 30),
                    child: bloodrequest(
                      isrequested: loadedmessages[index]['issend'],
                      isaccepted: !loadedmessages[index]['isaccepted'],
                      phonenumber: widget.phonenumber,
                      on_accept: () {
                        accept_blood_request(loadedmessages[index].id);
                      },
                      on_reject: () {
                        reject_blood_request(loadedmessages[index].id);
                      },
                    ),
                  );
                }
                if (index == 0) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 50,
                        child: Center(
                          child: styled_date(date: getdate(time_int!)),
                        ),
                      ),
                      bubblemessage(
                        message: loadedmessages[index]['Text'],
                        isMe: loadedmessages[index]['issend'],
                        time: loadedmessages[index]['CreatedAt'],
                      )
                    ],
                  );
                }
                if (index + 1 < loadedmessages.length) {
                  var ind_1 = loadedmessages[index + 1]['CreatedAt']
                      .toString()
                      .indexOf(",");
                  String time_string_1 = loadedmessages[index + 1]['CreatedAt']
                      .toString()
                      .substring(18, ind_1);
                  final time_int_1 = int.tryParse(time_string_1);
                  if (getdate(time_int_1!) != getdate(time_int!)) {
                    return Column(children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: styled_date(date: getdate(time_int_1)),
                      ),
                      bubblemessage(
                        message: loadedmessages[index]['Text'],
                        isMe: loadedmessages[index]['issend'],
                        time: loadedmessages[index]['CreatedAt'],
                      )
                    ]);
                  }
                }
                return bubblemessage(
                  message: loadedmessages[index]['Text'],
                  isMe: loadedmessages[index]['issend'],
                  time: loadedmessages[index]['CreatedAt'],
                );
              },
            );
          }
          return const Text("nothing");
        },
      ),
      floatingActionButton: IconButton(
          onPressed: () {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          },
          icon: const Icon(Icons.arrow_drop_down_outlined)),
    );
  }
}
