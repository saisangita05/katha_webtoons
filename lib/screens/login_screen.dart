import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import 'username_screen.dart';
import 'home_screen.dart';
import '../services/auth_service.dart';
import '../widgets/google_auth_button.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  Future<void> _signInWithGoogle(BuildContext context) async {
    final User? user = await _authService.signInWithGoogle();
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UsernameScreen(user: user)),
        );
      } else {
        // Reset the navigation stack and go to MainNavigation
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainNavigation()),
              (Route<dynamic> route) => false, // Remove all routes
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFA3D749),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(flex: 3),
            Text(
              'katha',
              style: GoogleFonts.cormorantUnicase(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 0),
            Text(
              "india's #1 webtoon platform",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            Spacer(flex: 4),
            SizedBox(
              width: double.infinity,
              child: GoogleAuthButton(
                onPressed: () => _signInWithGoogle(context),
              ),
            ),
            SizedBox(height: 15),
            GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MainNavigation()),
                      (Route<dynamic> route) => false, // Remove all routes
                );
              },
              child: Text(
                'Continue as a guest',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}