import 'package:cloud_firestore/cloud_firestore.dart';

class Episode {
  final String id;
  final String title;
  final int number;
  final List<String> images;
  final String previewImage;

  Episode({
    required this.id,
    required this.title,
    required this.number,
    required this.images,
    required this.previewImage,
  });

  factory Episode.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Episode(
      id: doc.id,
      title: data['title'] ?? '',
      number: data['number'] ?? 0,
      images: List<String>.from(data['images'] ?? []),
      previewImage: data['previewImage'] ?? (data['images'] != null &&
          (data['images'] as List).isNotEmpty ?
      (data['images'] as List).first : ''),
    );
  }
}