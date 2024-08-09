// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:gopher_eye/widgets/bottom_navigator_bar.dart';
// import 'package:gopher_eye/screens/signup_screen.dart';
// import 'package:gopher_eye/utils/validators.dart';

// final _formKey = GlobalKey<FormState>();

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<StatefulWidget> createState() => _LoginScreen();
// }

// class _LoginScreen extends State<StatefulWidget> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   bool hidden = true;
//   bool loginWarningVisible = false;

//   Future<bool> signIn(String emailAddress, String password) async {
//     try {
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: emailAddress,
//         password: password,
//       );
//       return true;
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'user-not-found') {
//         if (kDebugMode) {
//           print('No user found for that email.');
//         }
//       } else if (e.code == 'wrong-password') {
//         if (kDebugMode) {
//           print('Wrong password provided for that user.');
//         }
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print(e);
//       }
//     }
//     return false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   const SizedBox(
//                     height: 40,
//                   ),
//                   Center(
//                     child: Container(
//                       height: 60,
//                       width: 100,
//                       decoration: BoxDecoration(
//                           color: Colors.indigo[900],
//                           borderRadius: BorderRadius.circular(10.0)),
//                       child: const Center(
//                         child: Text(
//                           "LOGO",
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 30,
//                               fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 40.0),
//                   const Text(
//                     "Login to Your Account",
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(40, 20, 40, 30),
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           height: 190,
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               //* email

//                               TextFormField(
//                                 validator: emailvalidator,
//                                 controller: emailController,
//                                 style: TextStyle(
//                                     color: Colors.blue[900],
//                                     fontWeight: FontWeight.w800),
//                                 decoration: InputDecoration(
//                                     hintText: "E-Mail",
//                                     border: OutlineInputBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(05.0))),
//                               ),

//                               //* password
//                               TextFormField(
//                                 obscureText: hidden,
//                                 validator: passwordvalidator,
//                                 controller: passwordController,
//                                 style: TextStyle(
//                                     color: Colors.blue[900],
//                                     fontWeight: FontWeight.w800),
//                                 decoration: InputDecoration(
//                                     suffixIcon: IconButton(
//                                         onPressed: () {
//                                           setState(() {
//                                             hidden = !hidden;
//                                           });
//                                         },
//                                         icon: hidden
//                                             ? const Icon(
//                                                 Icons.visibility_off_rounded,
//                                                 color: Colors.blueGrey,
//                                               )
//                                             : const Icon(
//                                                 Icons.visibility_rounded,
//                                                 color: Colors.blueGrey,
//                                               )),
//                                     hintText: "Password",
//                                     border: OutlineInputBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(05.0))),
//                               ),
//                               Visibility(
//                                 visible: loginWarningVisible,
//                                 child: const Text(
//                                   "Invalid Email or Password",
//                                   style: TextStyle(
//                                       color: Colors.red, fontSize: 14),
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                         MaterialButton(
//                           onPressed: () {
//                             signIn(emailController.text,
//                                     passwordController.text)
//                                 .then((value) => {
//                                       if (value)
//                                         {
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (context) =>
//                                                   const BottomNavigationBarModel(),
//                                             ),
//                                           )
//                                         }
//                                       else
//                                         {
//                                           setState(() {
//                                             loginWarningVisible = true;
//                                           })
//                                         }
//                                     });
//                           },
//                           color: Colors.indigo[900],
//                           child: const Padding(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 80, vertical: 16),
//                             child: Center(
//                               child: Text(
//                                 "Sign-In",
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w700),
//                               ),
//                             ),
//                           ),
//                         ),
//                         // const SizedBox(height: 50.0),
//                         // Text(
//                         //   "or Sign-In with",
//                         //   style: TextStyle(
//                         //       fontWeight: FontWeight.w500,
//                         //       color: Colors.blueGrey[900]),
//                         // ),
//                         // const Padding(
//                         //   padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
//                         //   child: SizedBox(
//                         //     height: 50,
//                         //     width: 50,
//                         //     child: Card(
//                         //       child: Image(
//                         //           image: AssetImage(
//                         //               "assets/images/google_logo.png")),
//                         //     ),
//                         //   ),
//                         // ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Text("Don't have an account ?"),
//                             TextButton(
//                                 onPressed: () {
//                                   Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) =>
//                                             const SignUpScreen(),
//                                       ));
//                                 },
//                                 child: Text("Sign-Up",
//                                     style:
//                                         TextStyle(color: Colors.indigo[900])))
//                           ],
//                         )
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
