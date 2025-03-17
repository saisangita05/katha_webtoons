import 'package:flutter/material.dart';
import '../models/comic_model.dart';

class ComingSoonGrid extends StatelessWidget {
  final List<Comic> comics;

  const ComingSoonGrid({required this.comics});

  // Helper method to build a comic item
  Widget _buildBookItem(String imageUrl, {String title = "", bool isHero = false, bool isSquare = false}) {
    return Container(
      width: isHero ? double.infinity : (isSquare ? 150 : 120),
      height: isHero ? 150 : (isSquare ? 100 : 120),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter out hero and recommended comics
    final comingSoonComics = comics.where((comic) => !comic.isHero && !comic.isRecommended).toList();

    // Sort the comics (custom logic based on your requirements)
    comingSoonComics.sort((a, b) {
      if (a.title == "Solo Leveling") return -1;
      if (b.title == "Solo Leveling") return 1;
      if (a.title == "Eleceed" && b.title == "Omniscient Reader") return -1;
      if (b.title == "Eleceed" && a.title == "Omniscient Reader") return 1;
      return 0;
    });

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Comic (Solo Leveling)
          if (comingSoonComics.isNotEmpty)
            _buildBookItem(
              comingSoonComics[0].coverImage,
              title: "Solo Leveling",
              isHero: true,
            ),
          SizedBox(height: 20), // Increased spacing

          // Row for Eleceed and Omniscient Reader
          if (comingSoonComics.length > 2)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Evenly space items
              children: [
                _buildBookItem(
                  comingSoonComics[1].coverImage,
                  title: "Eleceed",
                  isSquare: true,
                ),
                _buildBookItem(
                  comingSoonComics[2].coverImage,
                  title: "Omniscient Reader",
                  isSquare: true,
                ),
              ],
            ),
        ],
      ),
    );
  }
}