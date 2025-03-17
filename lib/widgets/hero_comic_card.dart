import 'package:flutter/material.dart';
import '../models/comic_model.dart';

class HeroComicCard extends StatelessWidget {
  final Comic comic;
  final VoidCallback onTap;

  const HeroComicCard({required this.comic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = comic.isHero && comic.heroLandscapeImage.isNotEmpty
        ? comic.heroLandscapeImage // Use landscape image if available
        : comic.coverImage; // Fallback to portrait image

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        width: double.infinity,
        // Removed the horizontal margin to make it full width
        decoration: BoxDecoration(
          // You might want to remove the border radius too for a true edge-to-edge look
          // borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            // Match the border radius with the parent (or remove both)
            // borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                comic.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFA3D749),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  "Read Now",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}