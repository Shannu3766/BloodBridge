// ignore: file_names
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:bloodbridge/screens/HomeScreen.dart';
import 'package:bloodbridge/screens/waiting.dart';
import 'package:bloodbridge/widgets/Image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:core';

class User_Registration extends StatefulWidget {
  const User_Registration({super.key});

  @override
  State<User_Registration> createState() => _User_RegistrationState();
}

class _User_RegistrationState extends State<User_Registration> {
  var user = FirebaseAuth.instance.currentUser;
  final setuserlocation = FirebaseDatabase.instance.ref();
  bool isloading = false;
  List<String> stateslist = [];
  List<String> distlist = [];
  String? selectedstate;
  String? selecteddistrict;
  List<String> Districts = ["sfsf", "asa"];
  final List<String> bloodgrouplist = [
    "A",
    "B",
    "O",
    "AB",
  ];
  final List<String> rhfactor = ["+", "-"];
  List<String>? states;
  String rh = "+";
  String bloodgroup = "O"; // Assign the first element to the variable
  final _formkey = GlobalKey<FormState>();
  String name = "";
  String phonenumber = "";
  File? user_image;
  void _submitdata() async {
    final isvalid = _formkey.currentState!.validate();
    if (!isvalid) {
      return;
    }
    if (user_image == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 2), content: Text("No Image Uploaded")));
      return;
    }
    if (isvalid) {
      setState(() {
        isloading = true;
      });
      _formkey.currentState!.save();
      final storageref = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${user!.uid}.jpg');
      final userdataref = user!.updateDisplayName(name);
      await setuserlocation.child("userlocation").child(user!.uid).set({
        "State": selectedstate,
        "district": selecteddistrict,
      });
      // user.updatePhoneNumber(phoneCredential)
      await storageref.putFile(user_image!);
      final userimageurl = await storageref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection(selectedstate.toString().trim())
          .doc(selecteddistrict.toString().trim())
          .collection("users")
          .doc(user!.uid.toString())
          .set({
        "Name": name,
        "Phone": phonenumber,
        "BloodGroup": bloodgroup + rh,
        "State": selectedstate,
        "district": selecteddistrict,
        "photoUrl": userimageurl,
        "number_of_donations": "0",
      });
      await user?.updatePhotoURL(userimageurl.toString());
      setState(() {
        isloading = false;
      });
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) {
        return const HomeScreen();
      }));
      await user?.reload();
    }
  }

  // functiion that return state names from user
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
          statesVals.toString().substring(1, length - 1).split(",");
      return stateslist;
    } else {
      setState(() {
        final stateslist = ["Not Avaliable", "dssg"];
        final List<String> states = stateslist;
      });
      return stateslist;
    }
  }

  void setsstates() async {
    stateslist = await readstates();
    setState(() {
      states = stateslist;
      selectedstate = states![0];
    });
    setdists();
  }

  void setdists() async {
    final List<String> dists =
        await readdistricts(selectedstate.toString().trim());
    // print(dists);
    setState(() {
      distlist = dists;
      selecteddistrict = distlist[0];
    });
  }

  @override
  void initState() {
    setsstates();
    // setdists();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (states == null) {
      return const WaitingScreen();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Blood Bridge",
          style: GoogleFonts.playfairDisplay(fontSize: 20),
        ),
        actions: [
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: (isloading)
          ? const WaitingScreen()
          : Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [
                Color.fromARGB(248, 240, 65, 65),
                Color.fromARGB(255, 236, 112, 29)
              ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                      child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Form(
                        key: _formkey,
                        child: Column(
                          children: [
                            Column(
                              children: [
                                User_image_picker(onpickimage: (image) {
                                  user_image = image;
                                }),
                                Text("Upload a Photo")
                              ],
                            ),
                            TextFormField(
                              maxLength: 30,
                              autocorrect: true,
                              keyboardType: TextInputType.name,
                              decoration:
                                  const InputDecoration(label: Text("Name")),
                              textCapitalization: TextCapitalization.words,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 5) {
                                  return "Enter a valid Name";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                name = value!.trim();
                              },
                            ),
                            TextFormField(
                              maxLength: 10,
                              autocorrect: true,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                  label: Text("Phone Number")),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 10) {
                                  return "Enter a valid phonenumber";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                phonenumber = value!;
                              },
                            ),
                            Row(
                              children: [
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                        label: Text("Blood Group")),
                                    onChanged: ((value) {
                                      setState(() {
                                        bloodgroup = value!;
                                      });
                                      // print(bloodgroup);
                                    }),
                                    value: bloodgroup,
                                    items: bloodgrouplist
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    validator: (value) {
                                      if (value == null) {
                                        return "select Bloodgrouop";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                        label: Text("Rhesus")),
                                    onChanged: ((value) {
                                      setState(() {
                                        rh = value!;
                                      });
                                      // print(bloodgroup);
                                    }),
                                    value: rh,
                                    items: rhfactor
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    validator: (value) {
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                              ],
                            ),
                            //rows containing the distsricts and states
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                        label: Text("Blood Group")),
                                    onChanged: ((value) {
                                      setState(() {
                                        selectedstate = value!;
                                        // print(selectedstate);
                                        setdists();
                                      });
                                      // print(bloodgroup);
                                    }),
                                    validator: (value) {
                                      return null;
                                    },
                                    value: selectedstate,
                                    items: states!
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                // const Spacer(),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                        label: Text("Rhesus")),
                                    onChanged: ((value) {
                                      setState(() {
                                        selecteddistrict = value!;
                                      });
                                      // print(bloodgroup);
                                    }),
                                    validator: (value) {
                                      return null;
                                    },
                                    value: selecteddistrict,
                                    items: distlist
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Text(value)),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin:
                                  const EdgeInsets.only(top: 20, bottom: 20),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _submitdata();
                                },
                                icon: const Icon(Icons.add_link),
                                label: const Text("  Add Data"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ),
                              ),
                            )
                          ],
                        )),
                  )),
                ),
              ),
            ),
    );
  }
}
