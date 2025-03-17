import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/hero_comic_card.dart';
import '../widgets/comic_tile.dart';
import '../widgets/coming_soon_grid.dart';
import '../models/comic_model.dart';
import 'comic_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Comic> _comics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchComics();
  }

  Future<void> _fetchComics() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('comics').get();
      final comics = snapshot.docs.map((doc) => Comic.fromFirestore(doc)).toList();
      setState(() {
        _comics = comics;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching comics: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final heroComic = _comics.firstWhere(
          (comic) => comic.isHero,
      orElse: () => Comic(
        id: 'default',
        title: 'No Hero Comic',
        author: 'Unknown',
        coverImage: 'https://via.placeholder.com/150',
        heroLandscapeImage: 'https://via.placeholder.com/150',
        genre: [],
      ),
    );

    final recommendedComic = _comics.firstWhere(
          (comic) => comic.isRecommended,
      orElse: () => Comic(
        id: 'default',
        title: 'No Recommended Comic',
        author: 'Unknown',
        coverImage: 'https://via.placeholder.com/150',
        heroLandscapeImage: 'https://via.placeholder.com/150',
        genre: [],
      ),
    );

    return Scaffold(
      backgroundColor: Color(0xFF131313),
      body: SafeArea(
        child: _isLoading
            ? Center()
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Comic Section
              HeroComicCard(
                comic: heroComic,
                onTap: () => _navigateToDetail(context, heroComic),
              ),
              SizedBox(height: 20),

              // Recommended Comics Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'For You ✨',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Remove padding to make the tile go till the edges
              Container(
                padding: EdgeInsets.zero, // No padding
                child: ComicTile(
                  comic: recommendedComic,
                  onTap: () => _navigateToDetail(context, recommendedComic),
                ),
              ),
              SizedBox(height: 20),

          // Coming Soon Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Coming Soon 🥳',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 10),
          ComingSoonGrid(comics: _comics),
          ]
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Comic comic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComicDetailScreen(comic: comic),
      ),
    );
  }
}