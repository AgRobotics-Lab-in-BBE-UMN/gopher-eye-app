import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gopher_eye/screens/welcome_screen.dart';
import 'package:gopher_eye/utils/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _formKey = GlobalKey<FormState>();

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SignUpScreen();
}

class _SignUpScreen extends State<StatefulWidget> {
  bool hidden = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Future<bool> signUp(String emailAddress, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        if (kDebugMode) {
          print('The password provided is too weak.');
        }
      } else if (e.code == 'email-already-in-use') {
        if (kDebugMode) {
          print('The account already exists for that email.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return false;
  }

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
                    const SizedBox(height: 50.0),
                    const Center(
                      child: Text(
                        "Create Your Account",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 20, 40, 30),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 270,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextFormField(
                                  validator: emailvalidator,
                                  controller: emailController,
                                  style: const TextStyle(
                                      color: Color(0xFF009444),
                                      fontWeight: FontWeight.w800),
                                  decoration: InputDecoration(
                                      hintText: "E-Mail",
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(05.0))),
                                ),
                                TextFormField(
                                  obscureText: true,
                                  validator: passwordvalidator,
                                  controller: passwordController,
                                  style: const TextStyle(
                                      color: Color(0xFF009444),
                                      fontWeight: FontWeight.w800),
                                  decoration: InputDecoration(
                                      hintText: "Password",
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(05.0))),
                                ),
                                TextFormField(
                                  obscureText: hidden,
                                  validator: passwordvalidator,
                                  controller: confirmPasswordController,
                                  style: const TextStyle(
                                      color: Color(0xFF009444),
                                      fontWeight: FontWeight.w800),
                                  decoration: InputDecoration(
                                      hintText: "Confirm Password",
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
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(05.0))),
                                )
                              ],
                            ),
                          ),
                          MaterialButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                if (passwordController.text ==
                                    confirmPasswordController.text) {
                                  signUp(emailController.text,
                                          passwordController.text)
                                      .then((value) {
                                    if (value) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const WelcomeScreen(),
                                          ));
                                    }
                                  });
                                }
                              }
                            },
                            color: const Color(0xFF009444),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 80, vertical: 16),
                              child: Center(
                                child: Text(
                                  "Sign-Up",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
