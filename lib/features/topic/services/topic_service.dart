import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_english/features/topic/models/topic.dart';

class TopicService {
  final CollectionReference topicsRef = FirebaseFirestore.instance.collection(
    'topics',
  );

  Future<String> createTopic(String name, String description) async {
    final doc = await topicsRef.add({
      'name': name,
      'description': description,
      'createdAt': DateTime.now(),
    });
    return doc.id;
  }

  Future<void> updateTopic(
    String topicId,
    String name,
    String description,
  ) async {
    await topicsRef.doc(topicId).update({
      'name': name,
      'description': description,
    });
  }

  Future<void> deleteTopic(String topicId) async {
    await topicsRef.doc(topicId).delete();
  }

  Stream<List<Topic>> getTopics() {
    return topicsRef.orderBy("createdAt", descending: false).snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) => Topic.fromFirestore(doc)).toList();
      },
    );
  }
}
