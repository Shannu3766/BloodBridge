import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:slide_to_act/slide_to_act.dart';

class bloodrequest extends StatefulWidget {
  const bloodrequest({
    super.key,
    required this.isrequested,
    required this.on_accept,
    required this.on_reject,
    required this.isaccepted,
    required this.phonenumber,
  });
  final bool isrequested;
  final bool isaccepted;
  final String phonenumber;
  final void Function() on_accept;
  final void Function() on_reject;
  @override
  State<bloodrequest> createState() => _bloodrequestState();
}

class _bloodrequestState extends State<bloodrequest> {
  @override
  Widget build(BuildContext context) {
    if (widget.isrequested) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Spacer(),
                Container(
                    decoration: const BoxDecoration(
                      // color: Colors.amber,
                      color: Color.fromARGB(216, 248, 114, 112),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          "Blood Request",
                          style: TextStyle(fontSize: 40),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: (widget.isaccepted)
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.check,
                                        color: Colors.green,
                                      ),
                                      label: const Text("Accept"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade100,
                                        shape: BeveledRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                  ],
                                )
                              : Container(
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.all(15),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.smiley,
                                        size: 25,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Request Accepted",
                                        style: TextStyle(fontSize: 18),
                                      )
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    )),
                const Spacer()
              ],
            ),
          ],
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(216, 248, 114, 112),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      "Blood Request Sent",
                      style: TextStyle(fontSize: 30),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(15),
                      child: (widget.isaccepted)
                          ? const Row(children: [
                              Icon(
                                CupertinoIcons.exclamationmark_circle,
                                size: 25,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Request is in progress",
                                style: TextStyle(fontSize: 18),
                              )
                            ])
                          : Column(
                              children: [
                                const Row(children: [
                                  Icon(
                                    CupertinoIcons.smiley,
                                    size: 25,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Request Acecpted",
                                    style: TextStyle(fontSize: 18),
                                  )
                                ]),
                                Text("Phone number :${widget.phonenumber}")
                              ],
                            ),
                    )
                  ],
                ),
              ),
              const Spacer()
            ],
          ),
        ],
      ),
    );
  }
}
