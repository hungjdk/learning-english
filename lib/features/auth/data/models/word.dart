import 'package:cloud_firestore/cloud_firestore.dart';

class Word {
  final String id;
  final String word;
  final String ipa;
  final String meaning;
  final String example;
  final List<String> tags;

  Word({
    required this.id,
    required this.word,
    required this.ipa,
    required this.meaning,
    required this.example,
    this.tags = const [],
  });

  /// Converts this Word object into a Map that can be stored in Firestore.
  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'ipa': ipa,
      'meaning': meaning,
      'example': example,
      'tags': tags,
    };
  }

  /// Creates a Word object from a Firestore DocumentSnapshot.
  factory Word.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Word(
      id: doc.id,
      word: data['word'] ?? '',
      ipa: data['ipa'] ?? '',
      meaning: data['meaning'] ?? '',
      example: data['example'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
    );
  }
}
