import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gopher_eye/screens/home_screen.dart';
import 'package:gopher_eye/utils/firebase.dart';
import 'package:gopher_eye/widgets/bottom_navigator_bar.dart';
import 'package:gopher_eye/screens/signup_screen.dart';
import 'package:gopher_eye/utils/validators.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _formKey = GlobalKey<FormState>();

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreen();
}

class _LoginScreen extends State<StatefulWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool hidden = true;
  bool loginWarningVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: const DecorationImage(
                          image: AssetImage('assets/icons/app_store_2.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  const Center(
                    child: Text(
                      "Login to Your Account",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 20, 40, 30),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 190,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              //* email

                              TextFormField(
                                validator: emailvalidator,
                                controller: emailController,
                                style: const TextStyle(
                                    color: Color(0xFF000000),
                                    fontWeight: FontWeight.w800),
                                decoration: InputDecoration(
                                    hintText: "E-Mail",
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(05.0))),
                              ),

                              //* password
                              TextFormField(
                                obscureText: hidden,
                                validator: passwordvalidator,
                                controller: passwordController,
                                style: TextStyle(
                                    color: Colors.blue[900],
                                    fontWeight: FontWeight.w800),
                                decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            hidden = !hidden;
                                          });
                                        },
                                        icon: hidden
                                            ? const Icon(
                                                Icons.visibility_off_rounded,
                                                color: Colors.blueGrey,
                                              )
                                            : const Icon(
                                                Icons.visibility_rounded,
                                                color: Colors.blueGrey,
                                              )),
                                    hintText: "Password",
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(05.0))),
                              ),
                              Visibility(
                                visible: loginWarningVisible,
                                child: const Text(
                                  "Invalid Email or Password",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 14),
                                ),
                              )
                            ],
                          ),
                        ),
                        MaterialButton(
                          onPressed: () {
                            signIn(emailController.text,
                                    passwordController.text)
                                .then((value) => {
                                      if (value)
                                        {
                                          SharedPreferences.getInstance()
                                              .then((prefs) {
                                            prefs.setString('username',
                                                emailController.text);
                                            prefs.setString('password',
                                                passwordController.text);
                                          }),
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const HomeScreen(),
                                              // const BottomNavigationBarModel(),
                                            ),
                                          )
                                        }
                                      else
                                        {
                                          setState(() {
                                            loginWarningVisible = true;
                                          })
                                        }
                                    });
                          },
                          color: const Color(0xFF009444),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 80, vertical: 16),
                            child: Center(
                              child: Text(
                                "Sign-In",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                        // const SizedBox(height: 50.0),
                        // Text(
                        //   "or Sign-In with",
                        //   style: TextStyle(
                        //       fontWeight: FontWeight.w500,
                        //       color: Colors.blueGrey[900]),
                        // ),
                        // const Padding(
                        //   padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
                        //   child: SizedBox(
                        //     height: 50,
                        //     width: 50,
                        //     child: Card(
                        //       child: Image(
                        //           image: AssetImage(
                        //               "assets/images/google_logo.png")),
                        //     ),
                        //   ),
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account ?"),
                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SignUpScreen(),
                                      ));
                                },
                                child: Text("Sign-Up",
                                    style:
                                        TextStyle(color: Colors.indigo[900])))
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
