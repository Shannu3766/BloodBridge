import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bloodbridge/main.dart';

class AuthScreeen extends StatefulWidget {
  const AuthScreeen({
    super.key,
  });
  @override
  State<AuthScreeen> createState() => _AuthScreeenState();
}

class _AuthScreeenState extends State<AuthScreeen> {
  final _formkey = GlobalKey<FormState>();
  final _firebase = FirebaseAuth.instance;
  bool _isobscure = true;
  String _username = "";
  String _password = "";
  bool _islogin = true;
  void _submit() async {
    final valid = _formkey.currentState!.validate();
    if (valid) {
      _formkey.currentState!.save();
    }
    try {
      if (_islogin) {
        final usercred = await _firebase.signInWithEmailAndPassword(
            email: _username, password: _password);
      } else {
        final usercred = await _firebase.createUserWithEmailAndPassword(
            email: _username, password: _password);
      }
    } on FirebaseAuthException catch (error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).clearSnackBars();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            duration: const Duration(seconds: 2),
            content: Text(error.toString())),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 0.4;
    double width_screen = MediaQuery.of(context).size.width / 3;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(248, 240, 65, 65),
          actions: [
            const Spacer(),
            Text(
              "Blood Bridge",
              style: GoogleFonts.playfairDisplay(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            const Spacer()
          ],
        ),
        // backgroundColor: Theme.of(context).primaryColor,
        backgroundColor: Color.fromARGB(248, 240, 65, 65),
        body: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
            // Color.fromARGB(248, 240, 65, 65),
            // Color.fromARGB(255, 236, 112, 29)
            Color.fromARGB(255, 255, 255, 255),
            Color.fromARGB(255, 255, 255, 255)
          ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
          child: Expanded(
            child: Column(
              children: [
                Image.asset(
                  "assests/images/donate_blood.png",
                  width: (width_screen * 2),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: SingleChildScrollView(
                      child: Card(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Form(
                              key: _formkey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    maxLength: 40,
                                    initialValue:
                                        "shanmukhasriniva99@gmail.com",
                                    style: TextStyle(
                                      fontSize: 24,
                                    ),
                                    autocorrect: false,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                        label: Text("Email Address",
                                            style: TextStyle(
                                              fontSize: 24,
                                            ))),
                                    validator: (value) {
                                      if (value == null ||
                                          !value.contains("@") ||
                                          value.length < 8) {
                                        return "Enter a valid email Address";
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _username = value!;
                                    },
                                  ),
                                  TextFormField(
                                    initialValue: "shanmukha",
                                    maxLength: 20,
                                    style: const TextStyle(fontSize: 20),
                                    obscureText: _isobscure,
                                    autocorrect: false,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      label: const Text(
                                        "Password",
                                        style: TextStyle(fontSize: 24),
                                      ),
                                      suffixIcon: IconButton(
                                          icon: Icon(_isobscure
                                              ? Icons.visibility
                                              : Icons.visibility_off),
                                          onPressed: () {
                                            setState(() {
                                              _isobscure = !_isobscure;
                                            });
                                          }),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.length < 8) {
                                        return "Enter a valid email Address";
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _password = value!;
                                    },
                                  ),
                                  ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                      onPressed: () {
                                        setState(() {
                                          _submit();
                                        });
                                      },
                                      icon: Icon(
                                        (_islogin)
                                            ? Icons.add_task
                                            : Icons
                                                .admin_panel_settings_outlined,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                      label:
                                          Text((_islogin) ? " Login" : "SignUp",
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                              ))),
                                  TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _islogin = !_islogin;
                                        });
                                      },
                                      child: Text(
                                        (_islogin)
                                            ? "NewUser! SignUp"
                                            : "Login",
                                        style: const TextStyle(
                                          decoration: TextDecoration.underline,
                                        ),
                                        textAlign: TextAlign.end,
                                      ))
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
