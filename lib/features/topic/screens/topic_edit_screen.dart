import 'package:flutter/material.dart';
import 'package:learn_english/features/topic/models/topic.dart';
import 'package:learn_english/features/topic/services/topic_service.dart';

class TopicEditScreen extends StatefulWidget {
  final Topic topic;

  const TopicEditScreen({super.key, required this.topic});

  @override
  State<TopicEditScreen> createState() => TopicEditScreenState();
}

class TopicEditScreenState extends State<TopicEditScreen> {
  late TextEditingController name;
  late TextEditingController description;
  final TopicService service = TopicService();

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.topic.name);
    description = TextEditingController(text: widget.topic.description);
  }

  @override
  void dispose() {
    name.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chỉnh sửa bộ từ")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(
                  labelText: "Tên bộ từ",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: description,
                decoration: const InputDecoration(
                  labelText: "Mô tả",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await service.updateTopic(
                      widget.topic.id,
                      name.text.trim(),
                      description.text.trim(),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text("Lưu thay đổi"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
