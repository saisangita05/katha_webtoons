import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if the user is already logged in
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          return user; // New user, redirect to username screen
        }
      }
      return user;
    } catch (e) {
      print("Error during Google Sign-In: $e");
      return null;
    }
  }

  // Save username to Firestore
  Future<void> saveUsername(String uid, String username) async {
    await _firestore.collection('users').doc(uid).set({
      'email': _auth.currentUser!.email,
      'username': username,
    });
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
  // Add this method to handle guest users
  Future<void> signInAsGuest() async {
    // No authentication is required for guest users
    // We can simply navigate to the main navigation screen
  }
}