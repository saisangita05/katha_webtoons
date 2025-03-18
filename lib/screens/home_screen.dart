import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/hero_comic_card.dart';
import '../widgets/comic_tile.dart';
import '../widgets/coming_soon_grid.dart';
import '../models/comic_model.dart';
import 'comic_detail_screen.dart';

class ComicRepository {
  static final ComicRepository _instance = ComicRepository._internal();
  factory ComicRepository() => _instance;

  ComicRepository._internal();

  List<Comic> _comics = [];
  bool _isFetched = false;

  Future<List<Comic>> fetchComics() async {
    if (_isFetched) return _comics; // Return cached comics if already fetched

    try {
      final snapshot = await FirebaseFirestore.instance.collection('comics').get();
      _comics = snapshot.docs.map((doc) => Comic.fromFirestore(doc)).toList();
      _isFetched = true;
    } catch (e) {
      print("Error fetching comics: $e");
    }
    return _comics;
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Comic>> _comicFuture;

  @override
  void initState() {
    super.initState();
    _comicFuture = ComicRepository().fetchComics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF131313),
      body: SafeArea(
        child: FutureBuilder<List<Comic>>(
          future: _comicFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final comics = snapshot.data!;
            final heroComic = comics.firstWhere(
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

            final recommendedComic = comics.firstWhere(
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

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  ComicTile(
                    comic: recommendedComic,
                    onTap: () => _navigateToDetail(context, recommendedComic),
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
                  ComingSoonGrid(comics: comics),
                ],
              ),
            );
          },
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
