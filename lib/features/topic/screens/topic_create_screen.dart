import 'package:flutter/material.dart';
import 'package:learn_english/features/topic/services/topic_service.dart';

class TopicCreateScreen extends StatefulWidget {
  const TopicCreateScreen({super.key});

  @override
  State<TopicCreateScreen> createState() => TopicCreateScreenState();
}

class TopicCreateScreenState extends State<TopicCreateScreen> {
  final TextEditingController name = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TopicService service = TopicService();

  @override
  void dispose() {
    name.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tạo bộ từ mới")),
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
                    if (name.text.trim().isEmpty) return;

                    await service.createTopic(
                      name.text.trim(),
                      description.text.trim(),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text("Tạo bộ từ"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
