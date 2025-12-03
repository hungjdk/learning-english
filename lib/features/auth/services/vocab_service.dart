import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/word.dart';

/// Service class to manage vocabulary CRUD operations with Firestore.
class VocabService {
  // A reference to the 'words' collection in Firestore.
  final CollectionReference _wordsCollection = FirebaseFirestore.instance
      .collection('words');

  /// CREATE: Adds a new [word] to the Firestore collection.
  Future<void> addWord(Word word) {
    // Converts the Word object to a Map (JSON) and adds it as a new document.
    return _wordsCollection.add(word.toJson());
  }

  /// READ: Retrieves a real-time stream of words from Firestore.
  /// The UI will automatically update when the data changes.
  Stream<List<Word>> getWords() {
    return _wordsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Creates a Word object from each Firestore document.
        return Word.fromFirestore(doc);
      }).toList();
    });
  }

  /// UPDATE: Updates an existing word document in Firestore.
  Future<void> updateWord(Word word) {
    // Uses the word's ID to find the document and update it.
    return _wordsCollection.doc(word.id).update(word.toJson());
  }

  /// DELETE: Deletes a word document from Firestore using its ID.
  Future<void> deleteWord(String wordId) {
    return _wordsCollection.doc(wordId).delete();
  }
}
