import 'package:flutter/material.dart';
import 'package:gopher_eye/widgets/bottom_navigator_bar.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome to GOPHER EYE",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 24),
            ),
            const SizedBox(height: 50),
            SizedBox(
              height: 35,
              width: 200,
              child: MaterialButton(
                color: Colors.indigo[900],
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const BottomNavigationBarModel()));
                },
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                  child: Expanded(
                      child: Row(
                    children: [
                      Text(
                        "Continue",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(width: 20),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                      )
                    ],
                  )),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}