import 'package:cloud_firestore/cloud_firestore.dart';

class Comic {
  final String id;
  final String title;
  final String author;
  final String coverImage;
  final String heroLandscapeImage;
  final List<String> genre;
  final bool isHero;
  final bool isRecommended;
  final bool isNew; // Added for "NEW" tag in UI

  Comic({
    required this.id,
    required this.title,
    required this.author,
    required this.coverImage,
    required this.heroLandscapeImage,
    required this.genre,
    this.isHero = false,
    this.isRecommended = false,
    this.isNew = false,
  });

  factory Comic.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comic(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      coverImage: data['coverImage'] ?? '',
      heroLandscapeImage: data['heroLandscapeImage'] ?? '',
      genre: List<String>.from(data['genre'] ?? []),
      isHero: data['isHero'] ?? false,
      isRecommended: data['isRecommended'] ?? false,
      isNew: data['isNew'] ?? false,
    );
  }
}