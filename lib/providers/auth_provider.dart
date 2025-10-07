// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class AuthProvider with ChangeNotifier {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   User? _user;
//
//   AuthProvider() {
//     _auth.authStateChanges().listen((user) {
//       _user = user;
//       notifyListeners();
//     });
//   }
//
//   User? get user => _user;
//
//   bool get isAuthenticated => _user != null;
//
//   Future<void> signIn(String email, String password) async {
//     try {
//       await _auth.signInWithEmailAndPassword(email: email, password: password);
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   Future<void> signUp(String email, String password, String username) async {
//     try {
//       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       await userCredential.user?.updateDisplayName(username);
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   Future<void> signOut() async {
//     await _auth.signOut();
//   }
// }