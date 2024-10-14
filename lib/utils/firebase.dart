import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

Future<bool> signIn(String emailAddress, String password) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailAddress,
      password: password,
    );
    return true;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      if (kDebugMode) {
        print('No user found for that email.');
      }
    } else if (e.code == 'wrong-password') {
      if (kDebugMode) {
        print('Wrong password provided for that user.');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }
  return false;
}