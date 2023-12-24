import 'package:bloodbridge/screens/auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class start_Scren extends StatefulWidget {
  const start_Scren({super.key});

  @override
  State<start_Scren> createState() => _start_ScrenState();
}

class _start_ScrenState extends State<start_Scren> {
  @override
  Widget build(BuildContext context) {
    double width_screen = MediaQuery.of(context).size.width / 3;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Blood Bridge",
              style: GoogleFonts.playfairDisplay(fontSize: 30),
            ),
            // const SizedBox(height: 20),
            Image.asset(
              "assests/images/donate_blood.png",
              width: (width_screen * 3),
            ),
            SizedBox(
              width: (width_screen * 2),
              child: Text(
                "It feels good, It makes me Proud, I am a blood donor.",
                style: GoogleFonts.inter(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 35),
            FloatingActionButton.extended(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              onPressed: () {
                setState(() {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext ctx) {
                    return const AuthScreeen();
                  }));
                });
              },
              label: const Text(
                "Get Started",
                style: TextStyle(fontSize: 28),
              ),
              icon: const Icon(Icons.logout_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
