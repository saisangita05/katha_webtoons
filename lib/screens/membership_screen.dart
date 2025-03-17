import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class MembershipScreen extends StatelessWidget {
  const MembershipScreen({super.key});

  // Function to open email
  Future<void> _launchEmail() async {
    final Uri emailUri = Uri.parse("mailto:katha.webtoons@gmail.com");
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      debugPrint("Could not launch email");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Crown Image (Make sure to add crown.png in assets folder)
              Image.asset(
                'assets/crown.png',
                height: 80,
              ),
              const SizedBox(height: 10),

              // Thank You Text
              const Text(
                "Thank you so much for supporting",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 5),

              // Katha Title
              Text(
                'katha',
                style: GoogleFonts.cormorantUnicase(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFA3D749), // Changed to a visible color
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 5),

              // Description
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Hey there! 👋\n",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                      "We're students who absolutely love webnovels, webtoons, and anime. "
                          "Building ",
                    ),
                    TextSpan(
                      text: "Katha",
                      style: TextStyle(color: Color(0xFFA3D749), fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                      " is our dream, and while we know things might move a little slower for us, "
                          "we’re giving it everything we’ve got to make this platform truly special for you.\n\n"
                          "Seriously, it means the world to us!\n\n"
                          "We're working hard on creating a membership plan that not only supports amazing creators "
                          "but also gives you the best value. 🌟\n\n"
                          "Thanks for being patient and being part of this journey with us!\n\n"
                          "If you got the hint, drop us an email:",
                    ),
                  ],
                ),
                style: TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.left,
              ),

              // Email Contact
              GestureDetector(
                onTap: _launchEmail, // Fixed function call
                child: const Text(
                  "📧 katha.webtoons@gmail.com",
                  style: TextStyle(
                    color: Color(0xFFA3D749),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              // Cheers Text
              const Text(
                "Cheers!",
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
    );
  }
}