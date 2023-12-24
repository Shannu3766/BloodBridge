import 'package:bloodbridge/providers/FiltersProvider.dart';
import 'package:bloodbridge/providers/friendslist_acceptedprovider.dart';
import 'package:bloodbridge/providers/friendslist_requestedprovider.dart';
import 'package:bloodbridge/providers/userdataProvider.dart';
import 'package:bloodbridge/screens/FiltersScreen.dart';
import 'package:bloodbridge/screens/Friends_list_screen.dart';
import 'package:bloodbridge/widgets/users_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final userlocation = FirebaseDatabase.instance.ref();
  List<String> stateslist = ["Andhra Pradesh", "Assam", "Arunachal Pradesh"];
  List<String> distlist = [];
  String? selectedstate;
  String? selecteddistrict;
  List<String> Districts = ["sfsf", "asa"];
  final _firebase = FirebaseAuth.instance;
  List<Map<String, dynamic>>? usersdata;
  String? userstate;
  String? userdist;
  Widget? activeScreen;
  String? user_uid;
  Widget? userslist;
  String? image_link;
  User? user;
  ImageProvider? image;
  var _page_index = 0;
  var getuserscount = 0;
  var getfriendscount =
      0; //to make the setstate such that the friends get loaded after the start of the app
  var statecount = 0;
  var distcount = 0;
  List<String>? states;
  @override
  void initState() {
    User user = FirebaseAuth.instance.currentUser!;
    user_uid = user.uid; //donot make it final
    // setsstates();
    setlocation();
    super.initState();
    getuserslist("NoFilter");
    getusersdata();
    activeScreen = userslist;
    // setdists();
  }

  void setlocation() async {
    final snapshot =
        await userlocation.child("userlocation").child(user_uid!).get();
    userdist = snapshot.child("district").value as String;
    userstate = snapshot.child("State").value as String?;
    setsstates();
    selectedstate = userstate!.trim();
    setdists();
    selecteddistrict = userdist!.trim();
  }

//used for changing of tabs
  void selectpage(int index) {
    setState(() {
      _page_index = index;
      if (_page_index == 0) {
        activeScreen = userslist;
        return;
      }
      if (_page_index == 1) {
        activeScreen = const Friends_list();
        return;
      }
      if (index == 2) {
        showModalBottomSheet(
            context: context,
            builder: (ctx) {
              return Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Are you sure to logout",
                    style: GoogleFonts.montserrat(fontSize: 25),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      const Spacer(),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              _page_index = 0;
                              // selectpage(0);
                            });
                          },
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.playfairDisplay(fontSize: 20),
                          )),
                      const SizedBox(width: 30),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _firebase.signOut();
                          },
                          child: Text(
                            "Logout",
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          )),
                      const Spacer(),
                    ],
                  )
                ],
              );
            });
        // return;
      }
    });
  }

// adding filters to the data
  void addfilters(String val) {
    // getblood(val);
    getuserslist(val);
    if (_page_index == 0) {
      setState(() {
        activeScreen = userslist;
      });
    }
  }

//get users data
  void getusersdata() async {
    List<Map<String, dynamic>> userListData = [];
    final snapshot = await FirebaseFirestore.instance
        .collection(selectedstate.toString().trim())
        .doc(selecteddistrict.toString().trim())
        .collection("users")
        .get();
    if (snapshot.docs.isEmpty) {
      usersdata = userListData;
      getfriendslist(userstate!, userdist!, user_uid!);
      return;
    }
    for (var userdocument in snapshot.docs) {
      Map<String, dynamic> userData = userdocument.data();
      if (userdocument.id == user_uid) {
        userstate = userData['State'];
        userdist = userData['district'];
        String username = userData['Name'];
        String phone = userData['Phone'];
        String photourl = userData['photoUrl'];
        String BloodGroup = userData['BloodGroup'];
        String number_of_donations = userData['number_of_donations'];
        ref.read(userdataProvider.notifier).addstate_dist(
            user_uid!,
            userstate!,
            userdist!,
            username,
            phone,
            photourl,
            BloodGroup,
            number_of_donations);
        continue;
      }
      userListData.add({
        'Name': userData['Name'],
        'BloodGroup': userData['BloodGroup'],
        'Phone': userData['Phone'],
        'photoUrl': userData['photoUrl'],
        'userId': userdocument.id,
        'State': userData['State'],
        'district': userData['district'],
      });
    }
    setState(() {
      usersdata = userListData;
    });
    if (userdist != null) getfriendslist(userstate!, userdist!, user_uid!);
  }

  //gets the userslist
  void getuserslist(String requiredblood) {
    final myData = ref.read(userdataProvider);
    if (usersdata == null) {
      userslist = const Center(
        child: Text(""),
      );
      return;
    }
    if (usersdata!.isEmpty) {
      userslist = Center(
        child: Text("No Users Avaliable...  $selecteddistrict"),
      );
      return;
    }
    List<Map<String, dynamic>> Filterlistdata = usersdata!;
    if (requiredblood != "NoFilter") {
      Filterlistdata = [];
      for (int i = 0; i < usersdata!.length; i++) {
        if (usersdata![i]['BloodGroup'] == requiredblood) {
          Filterlistdata.add(usersdata![i]);
        }
      }
    }
    userslist = (Filterlistdata.length != 0)
        ? ListView.builder(
            itemCount: Filterlistdata.length,
            itemBuilder: (context, index) {
              return User_card(
                name: Filterlistdata[index]['Name'],
                bloodGroup: Filterlistdata[index]['BloodGroup'],
                phonenumber: Filterlistdata[index]['Phone'],
                url: Filterlistdata[index]['photoUrl'],
                userid: Filterlistdata[index]['userId'],
                userState: Filterlistdata[index]['State'],
                userdistrict: Filterlistdata[index]['district'],
                onaddfriend: (friendId, friendState, friendDist) {
                  add_user_asfriend(
                    friendId,
                    Filterlistdata[index]['State'],
                    Filterlistdata[index]['district'],
                    {
                      'isfriend': 'false',
                      'requested': 'true',
                      'Name': Filterlistdata[index]['Name'],
                      'BloodGroup': Filterlistdata[index]['BloodGroup'],
                      'Phone': Filterlistdata[index]['Phone'],
                      'photoUrl': Filterlistdata[index]['photoUrl'],
                      'userId': Filterlistdata[index]['userId'],
                      'State': Filterlistdata[index]['State'],
                      'district': Filterlistdata[index]['district'],
                      'bloodshare': {
                        'isrequested': "null",
                        'accepted': "null",
                        'lastrequested': Timestamp.now(),
                      }
                    },
                    {
                      'isfriend': 'false',
                      'requested': 'false',
                      'Name': myData[3],
                      'BloodGroup': myData[6],
                      'Phone': myData[4],
                      'photoUrl': myData[5],
                      'userId': myData[0],
                      'State': myData[1],
                      'district': myData[2],
                      'bloodshare': {
                        'isrequested': "null",
                        'accepted': "null",
                        'lastrequested': Timestamp.now()
                      }
                    },
                    friendState,
                    friendDist,
                  );
                },
              );
            })
        : Center(
            child: Text(
            "No Donors found with ${requiredblood}",
            style: TextStyle(
                fontSize: 20, fontFamily: GoogleFonts.inter().fontFamily),
          ));
  }

  //method to add user as friend
  void add_user_asfriend(
      String friendId,
      String friendstate,
      String frienddist,
      Map<String, dynamic> dataOffriendInuser,
      Map<String, dynamic> dataOfUserInFriend,
      String friendState,
      String friendDist) async {
    setState(() {
      if (ref.read(friendlist_acceptedprovider.notifier).is_friend(friendId)) {
        ref.read(friendlist_acceptedprovider.notifier).add_friend(friendId);
        ref.read(friendlist_requestedprovider.notifier).removeFriend(friendId);
      }
      if (ref.read(friendlist_requestedprovider.notifier).is_friend(friendId)) {
        ref.read(friendlist_requestedprovider.notifier).add_friend(friendId);
      }
    });
    Fluttertoast.showToast(
      msg: "Friend request sent",
      gravity: ToastGravity.CENTER,
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
    );
    final userdataProfile = ref.read(userdataProvider);
    setState(() {
      getfriendslist(
          userdataProfile[1], userdataProfile[2], userdataProfile[0]);
    });
    final result = await FirebaseFirestore.instance
        .collection(userstate.toString().trim())
        .doc(userdist.toString().trim())
        .collection("users")
        .doc(user_uid)
        .collection("friends")
        .doc(friendId)
        .set(dataOffriendInuser);
    //adds a new friend request to the donor in his account
    await FirebaseFirestore.instance
        .collection(friendState.toString().trim())
        .doc(frienddist.toString().trim())
        .collection("users")
        .doc(friendId)
        .collection("friends")
        .doc(user_uid)
        .set(dataOfUserInFriend);
    ref.read(FiltersProvider.notifier).reloaddata();
  }

  //get friends list
  void getfriendslist(String state, String dist, String userid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(state.toString().trim())
        .doc(dist.toString().trim())
        .collection("users")
        .doc(userid.toString().trim())
        .collection("friends")
        .get();
    if (snapshot.docs.isEmpty) {
      return;
    }
    for (var friend in snapshot.docs) {
      Map<String, dynamic> userData = friend.data();
      if (userData['isfriend'] == "true") {
        ref.read(friendlist_acceptedprovider.notifier).add_friend(friend.id);
      }
      if (userData['isfriend'] == "false") {
        ref.read(friendlist_requestedprovider.notifier).add_friend(friend.id);
      }
    }
    final userdataProfile = ref.read(userdataProvider);
    if (userdataProfile.isNotEmpty && getfriendscount == 0) {
      setState(() {
        getfriendslist(
            userdataProfile[1], userdataProfile[2], userdataProfile[0]);
      });
      getfriendscount++;
    }
  }

  Future<List<String>> readstates() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('State').get();
    if (snapshot.exists) {
      var statesVals = snapshot.value;
      final length = snapshot.value.toString().length;
      final stateslist =
          statesVals.toString().substring(1, length - 1).split(",");
      return stateslist;
    } else {
      setState(() {
        final stateslist = ["Not Avaliable", "dssg"];
        final List<String> states = stateslist;
        print(states);
      });
      return stateslist;
    }
  }

  //function that returns district names from user
  Future<List<String>> readdistricts(String state) async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child(state).get();
    if (snapshot.exists) {
      var statesVals = snapshot.value;
      final length = snapshot.value.toString().length;
      final stateslist =
          statesVals.toString().substring(1, length - 1).trim().split(",");
      for (int i = 0; i < stateslist.length; i++) {
        stateslist[i] = stateslist[i].trim();
      }
      return stateslist;
    } else {
      // Return a default value if snapshot doesn't exist
      return ["Not Available", "dssg"];
    }
  }

  void setsstates() async {
    setState(() {
      states = stateslist;
      if (statecount == 0) {
        selectedstate = states![0].trim();
        statecount++;
      }
      states = stateslist;
    });
    // setdists();
  }

  void setdists() async {
    final List<String> dists = await readdistricts(selectedstate!.trim());
    setState(() {
      distlist = dists;
      // print(distlist);
      if (distcount == 0) {
        selecteddistrict = userdist;
        distcount++;
        return;
      }
      for (int i = 0; i < distlist.length; i++) {
        if (distlist[i] == userdist) {
          selecteddistrict = userdist;
          return;
        }
      }
      selecteddistrict = distlist[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (getuserscount < 3) {
      getusersdata();
      getuserscount++;
    }
    final data = ref.watch(FiltersProvider);
    addfilters(data[0]);
    User user = FirebaseAuth.instance.currentUser!;
    final imageurl = user.photoURL.toString();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 171, 145),
        actions: [
          const SizedBox(
            width: 20,
          ),
          CircleAvatar(
              backgroundImage: const AssetImage("assests/images/person.png"),
              foregroundImage: CachedNetworkImageProvider(imageurl)),
          const SizedBox(
            width: 10,
          ),
          (user.displayName!.length < 8)
              ? Text(
                  user.displayName![0].toUpperCase() +
                      user.displayName!.substring(1),
                  style: GoogleFonts.playfairDisplay(fontSize: 23))
              : Text(
                  "${user.displayName![0].toUpperCase()}${user.displayName!.substring(1, 8)}...",
                  style: GoogleFonts.playfairDisplay(fontSize: 23)),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext ctx) {
                return const FiltersScreen();
              }));
            },
            icon: const Icon(
              Icons.filter_list,
              size: 30,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          if (_page_index == 0)
            if (states != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField(
                        menuMaxHeight: 500,
                        decoration: InputDecoration(
                            label: Text(
                          "State",
                          style: GoogleFonts.notoSans(fontSize: 18),
                        )),
                        onChanged: ((value) {
                          setState(() {
                            selectedstate = value!.trim();
                            setdists();
                          });
                          setState(() {
                            getfriendslist(
                                selectedstate!, selecteddistrict!, user_uid!);
                          });
                        }),
                        value: selectedstate!.trim(),
                        items: states!
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                            label: Text("District",
                                style: GoogleFonts.notoSans(fontSize: 18))),
                        menuMaxHeight: 300,
                        onChanged: ((value) {
                          setState(() {
                            selecteddistrict = value!;
                            getusersdata();
                          });
                          setState(() {});
                        }),
                        value: selecteddistrict!.trim(),
                        items: distlist
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
          Expanded(child: activeScreen!),
        ],
      ),
      floatingActionButton: (_page_index != 1)
          ? FloatingActionButton(
              onPressed: () {
                ref.read(FiltersProvider.notifier).clearFilter();
                Fluttertoast.showToast(
                    msg: "Filters cleared",
                    gravity: ToastGravity.CENTER,
                    backgroundColor:
                        // Theme.of(context).colorScheme.onPrimaryContainer,
                        const Color.fromARGB(255, 255, 171, 145));
              },
              tooltip: 'Reset Filter',
              splashColor: const Color.fromARGB(255, 255, 171, 145),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.settings_backup_restore,
                  ),
                  Text(
                    "Reset Filters",
                    style: TextStyle(fontSize: 10),
                  )
                ],
              ))
          : null,
      bottomNavigationBar: GNav(
          backgroundColor: const Color.fromARGB(255, 255, 171, 145),
          tabBackgroundColor: const Color.fromARGB(255, 248, 246, 246),
          tabMargin: const EdgeInsets.all(15),
          gap: 8,
          onTabChange: selectpage,
          tabs: const [
            GButton(
              padding: EdgeInsets.all(10),
              gap: 10,
              icon: Icons.person,
              text: 'Donors',
              iconColor: Color.fromARGB(255, 0, 0, 0),
            ),
            GButton(
              padding: EdgeInsets.all(10),
              gap: 10,
              icon: Icons.favorite,
              text: 'Friends',
              iconColor: Color.fromARGB(255, 0, 0, 0),
            ),
            GButton(
              padding: EdgeInsets.all(10),
              gap: 10,
              icon: Icons.logout,
              text: 'Logout',
              iconColor: Color.fromARGB(255, 2, 2, 2),
            )
          ]),
    );
  }
}
