import 'package:hive/hive.dart';
import 'package:learn_english/features/topic/models/topic.dart';

class TopicCache {
  final Box box = Hive.box('topicCache');

  void saveTopics(List<Topic> topics) {
    final data = topics.map((e) => e.toMap()).toList();
    box.put('topics', data);
  }

  List<Topic> getTopics() {
    final raw = box.get("topics");
    if(raw == null) {
      return [];
    }
    return (raw as List).map((e) => Topic.fromMap(e)).toList();
  }
}
