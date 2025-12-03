import 'package:cloud_firestore/cloud_firestore.dart';

class Topic {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;

  Topic({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "createdAt": createdAt.toIso8601String(),
    };
  }

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      id: map["id"],
      name: map["name"],
      description: map["description"],
      createdAt: DateTime.parse(map["createdAt"]),
    );
  }

  factory Topic.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Topic(
      id: doc.id,
      name: data["name"],
      description: data["description"],
      createdAt: (data["createdAt"] as Timestamp).toDate(),
    );
  }
}
