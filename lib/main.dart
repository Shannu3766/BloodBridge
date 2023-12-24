import 'dart:async';

import 'package:bloodbridge/firebase_options.dart';
import 'package:bloodbridge/screens/HomeScreen.dart';
import 'package:bloodbridge/screens/auth.dart';
import 'package:bloodbridge/screens/User_Registration.dart';
import 'package:bloodbridge/screens/waiting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  var user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 227, 96, 9),
        ),
      ),
      home: Scaffold(
        body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const WaitingScreen();
            }
            if (snapshot.hasData) {
              user = FirebaseAuth.instance.currentUser!;
            }
            if (user != null && user!.photoURL == null) {
              return const User_Registration();
            }
            if (snapshot.hasData && user!.photoURL != null) {
              return const HomeScreen();
            }
            return const AuthScreeen();
          },
        ),
      ),
    );
  }
}
