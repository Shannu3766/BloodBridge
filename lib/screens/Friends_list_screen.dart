import 'package:bloodbridge/providers/FiltersProvider.dart';
import 'package:bloodbridge/providers/friendslist_acceptedprovider.dart';
import 'package:bloodbridge/providers/friendslist_requestedprovider.dart';
import 'package:bloodbridge/providers/userdataProvider.dart';
import 'package:bloodbridge/widgets/add_design_to_label.dart';
import 'package:bloodbridge/widgets/friend_card.dart';
import 'package:bloodbridge/widgets/requested_user_card.dart';
import 'package:bloodbridge/widgets/users_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Friends_list extends ConsumerStatefulWidget {
  const Friends_list({super.key});
  @override
  ConsumerState<Friends_list> createState() => _Friends_listState();
}

class _Friends_listState extends ConsumerState<Friends_list> {
  String? user_uid;
  String? userstate;
  String? userdist;
  Widget friends_accepted = const Center(child: Text("No Friends avaliable.."));
  Widget friend_requests = const Center(child: Text("No Friend requests"));
  List<Map<String, dynamic>> friends_list = [];
  List<Map<String, dynamic>> friends_list_accepted = [];
  List<Map<String, dynamic>> friends_list_requested = [];
  @override
  void didChangeDependencies() {
    getfriends_list();
    super.didChangeDependencies();
  }

  //method to get list of friends for the first time
  void getfriends_list() async {
    List<Map<String, dynamic>> friends = [];
    final user_data = ref.read(userdataProvider);
    userstate = user_data[1];
    userdist = user_data[2];
    user_uid = user_data[0];
    final snapshot = await FirebaseFirestore.instance
        .collection(userstate!.toString().trim())
        .doc(userdist!.toString().trim())
        .collection("users")
        .doc(user_uid!.toString().trim())
        .collection("friends")
        .get();
    if (snapshot.docs.isEmpty) {
      friends_list = friends;
      return;
    }
    for (var friend in snapshot.docs) {
      Map<String, dynamic> userData = friend.data();
      if (userData['isfriend'] == "false") {
        ref.read(friendlist_requestedprovider.notifier).add_friend(friend.id);
        friends.add(userData);
        continue;
      }
      if (userData['isfriend'] == "true") {
        ref.read(friendlist_acceptedprovider.notifier).add_friend(friend.id);
        ref.read(friendlist_requestedprovider.notifier).removeFriend(friend.id);
        friends.add(userData);
        continue;
      }
    }
    setState(() {
      friends_list = friends;
    });
    get_userscard();
    return;
  }

  //todelete a friend
  void delete_friend(String friendId, String friendState, String friendDist,
      int index, String friendStatus) async {
    if (ref.read(friendlist_acceptedprovider.notifier).is_friend(friendId)) {
      ref.read(friendlist_acceptedprovider.notifier).removeFriend(friendId);
    }
    if (ref.read(friendlist_requestedprovider.notifier).is_friend(friendId)) {
      ref.read(friendlist_requestedprovider.notifier).removeFriend(friendId);
    }
    Fluttertoast.showToast(
      msg: "User deleted",
      gravity: ToastGravity.CENTER,
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
    );
    setState(() {
      if (friendStatus == "accepted") {
        friends_list
            .remove(friends_list_accepted[(index != 0) ? index - 1 : index]);
        friends_list_accepted.remove(friends_list_accepted[index]);
      } else {
        friends_list
            .remove(friends_list_requested[(index != 0) ? index - 1 : index]);
        friends_list_requested.remove(friends_list_requested[index]);
      }
      if (friends_list.isEmpty) {
        friends_accepted = const Center(child: Text("No Friends avaliable.."));
        return;
      }
    });
    get_userscard();
    await FirebaseFirestore.instance
        .collection(userstate.toString().trim())
        .doc(userdist.toString().trim())
        .collection("users")
        .doc(user_uid)
        .collection("friends")
        .doc(friendId)
        .delete();
    await FirebaseFirestore.instance
        .collection(friendState.toString().trim())
        .doc(friendDist.toString().trim())
        .collection("users")
        .doc(friendId)
        .collection("friends")
        .doc(user_uid)
        .delete();
  }

  void accept_friend(
    String friendId,
    String friendState,
    String friendDist,
    Map<String, dynamic> frienddata,
  ) async {
    //instance to update that the user has accepted the request in the databse of user
    await FirebaseFirestore.instance
        .collection(userstate.toString().trim())
        .doc(userdist.toString().trim())
        .collection("users")
        .doc(user_uid)
        .collection("friends")
        .doc(friendId)
        .update({"isfriend": "true"});
    //instance to update that the user has accepted the request in the databse of requester
    await FirebaseFirestore.instance
        .collection(friendState.toString().trim())
        .doc(friendDist.toString().trim())
        .collection("users")
        .doc(friendId)
        .collection("friends")
        .doc(user_uid)
        .update({"isfriend": "true"});
    setState(() {
      getfriends_list();
    });
    Fluttertoast.showToast(
      msg: "Accepted Friend Requested..",
      gravity: ToastGravity.CENTER,
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }

  //method to make the userslist to card
  void get_userscard() {
    Widget userlistcardAccepted;
    Widget userlistcardRequested;
    friends_list_accepted = [];
    friends_list_requested = [];
    for (final friend in friends_list) {
      final requested = friend['requested'].toString();
      final isfriend = friend['isfriend'].toString();
      if (requested == "false" && isfriend == "false") {
        friends_list_requested.add(friend);
        continue;
      }
      if (isfriend == "true") {
        friends_list_accepted.add(friend);
      }
    }
    if (friends_list_accepted.isEmpty) {
      userlistcardAccepted =
          const Center(child: Text("No Friends avaliable.."));
    } else {
      userlistcardAccepted = ListView.builder(
        itemCount: friends_list_accepted.length,
        itemBuilder: (context, index) {
          return Slidable(
            endActionPane: ActionPane(motion: const DrawerMotion(), children: [
              SlidableAction(
                padding: const EdgeInsets.all(2),
                label: "delete",
                borderRadius: const BorderRadius.all(Radius.circular(100)),
                backgroundColor: Colors.red,
                icon: Icons.delete,
                onPressed: (context) {
                  setState(() {
                    delete_friend(
                        friends_list[index]['userId'],
                        friends_list_accepted[index]['State'],
                        friends_list_accepted[index]['district'],
                        index,
                        "accepted");
                  });
                },
              )
            ]),
            child: Friend_card(
              name: friends_list_accepted[index]['Name'],
              phonenumber: friends_list_accepted[index]['Phone'],
              url: friends_list_accepted[index]['photoUrl'],
              bloodGroup: friends_list_accepted[index]['BloodGroup'],
              userid: friends_list_accepted[index]['userId'],
              userState: friends_list_accepted[index]['State'],
              userdistrict: friends_list_accepted[index]['district'],
              onaddfriend: (friendId, friendState, friendDist) {},
            ),
          );
        },
      );
    }
    if (friends_list_requested.isEmpty) {
      userlistcardRequested = const Center(child: Text("No Friend requests"));
    } else {
      userlistcardRequested = ListView.builder(
        itemCount: friends_list_requested.length,
        itemBuilder: (context, index) {
          return requested_user_card(
            name: friends_list_requested[index]['Name'],
            phonenumber: friends_list_requested[index]['Phone'],
            url: friends_list_requested[index]['photoUrl'],
            bloodGroup: friends_list_requested[index]['BloodGroup'],
            userid: friends_list_requested[index]['userId'],
            userState: friends_list_requested[index]['State'],
            userdistrict: friends_list_requested[index]['district'],
            accept_friend: (friendId, friendState, friendDist) => {
              accept_friend(
                friendId,
                friendState,
                friendDist,
                {
                  'isfriend': 'true',
                  'requested': friends_list_requested[index]['requested'],
                  'Name': friends_list_requested[index]['Name'],
                  'Phone': friends_list_requested[index]['Phone'],
                  'photoUrl': friends_list_requested[index]['photoUrl'],
                  'BloodGroup': friends_list_requested[index]['BloodGroup'],
                  'userId': friends_list_requested[index]['userId'],
                  'State': friends_list_requested[index]['State'],
                  'district': friends_list_requested[index]['district'],
                },
              ),
              setState(() {
                friends_list_accepted.add(friends_list_requested[index]);
                ref
                    .read(friendlist_acceptedprovider.notifier)
                    .add_friend(friends_list_accepted[index]['userId']);
                ref
                    .read(friendlist_requestedprovider.notifier)
                    .removeFriend(friends_list_requested[index]['userId']);
                friends_list_requested.remove(friends_list_requested[index]);
              })
            },
            rejectfriend: (friendId, friendState, friendDist) => {
              delete_friend(
                  friendId, friendState, friendDist, index, "requested")
            },
          );
        },
      );
    }
    setState(() {
      friends_accepted = userlistcardAccepted;
      friend_requests = userlistcardRequested;
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: friendslist,
      body: Column(
        children: [
          if (!ref.read(friendlist_requestedprovider.notifier).dohavefriends())
            add_design_to_label(label: "Bloodrequests"),
          if (!ref.read(friendlist_requestedprovider.notifier).dohavefriends())
            const SizedBox(height: 10),
          if (!ref.read(friendlist_requestedprovider.notifier).dohavefriends())
            Expanded(child: friend_requests),
          const add_design_to_label(label: "Accepted Blood Requests"),
          const SizedBox(height: 10),
          Expanded(child: friends_accepted)
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            getfriends_list();
            Fluttertoast.showToast(
              msg: "Reloaded friends",
              gravity: ToastGravity.CENTER,
              backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            );
          },
          tooltip: 'Reload friends',
          splashColor: Theme.of(context).colorScheme.onPrimaryContainer,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_rounded,
              ),
              Text(
                "Reload friends",
                style: TextStyle(fontSize: 10),
              )
            ],
          )),
    );
  }
}
