import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:learn_english/features/auth/services/auth_service.dart';
import 'package:learn_english/features/topic/models/topic.dart';
import 'package:learn_english/features/topic/screens/topic_create_screen.dart';
import 'package:learn_english/features/topic/screens/topic_edit_screen.dart';
import 'package:learn_english/features/topic/services/topic_cache.dart';
import 'package:learn_english/features/topic/services/topic_service.dart';

class TopicListScreen extends StatefulWidget {
  const TopicListScreen({super.key});

  @override
  State<TopicListScreen> createState() => TopicListScreenState();
}

class TopicListScreenState extends State<TopicListScreen> {
  final TopicService service = TopicService();
  final TopicCache cache = TopicCache();

  String search = "";
  bool gridView = false;

  @override
  Widget build(BuildContext context) {
    // NOTE: Lấy role từ AuthService để phân biệt admin / user
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        final role = authService.currentUserData?.role ?? 'user';
        final bool isAdmin = role == 'admin';

        return Scaffold(
          appBar: AppBar(
            title: Text(isAdmin ? "Quản lý bộ từ" : "Bộ từ của bạn"),
            actions: [
              IconButton(
                icon: Icon(gridView ? Icons.view_list : Icons.grid_view),
                onPressed: () {
                  setState(() {
                    gridView = !gridView;
                  });
                },
              ),
            ],
          ),

          // NOTE: Chỉ admin mới có nút thêm bộ từ
          floatingActionButton: isAdmin
              ? FloatingActionButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TopicCreateScreen(),
                    ),
                  ),
                  child: const Icon(Icons.add),
                )
              : null,

          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: "Tìm bộ từ...",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => search = v),
                ),
              ),
              Expanded(
                child: StreamBuilder<List<Topic>>(
                  stream: service.getTopics(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final filtered = snapshot.data!
                          .where(
                            (t) => t.name.toLowerCase().contains(
                              search.toLowerCase(),
                            ),
                          )
                          .toList();

                      cache.saveTopics(snapshot.data!);

                      return gridView
                          ? buildGrid(filtered, isAdmin)
                          : buildList(filtered, isAdmin);
                    }

                    // Nếu mất mạng -> lấy từ cache
                    final cached = cache.getTopics();
                    return gridView
                        ? buildGrid(cached, isAdmin)
                        : buildList(cached, isAdmin);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // NOTE: isAdmin quyết định có hiện menu Sửa/Xóa hay không
  Widget buildList(List<Topic> topics, bool isAdmin) {
    return ListView.builder(
      itemCount: topics.length,
      itemBuilder: (_, i) {
        final t = topics[i];
        return ListTile(
          title: Text(t.name),
          subtitle: Text(t.description),
          // TODO: onTap -> chuyển sang màn danh sách từ trong bộ (cho cả admin & user)
          onTap: () {
            // Navigator.push(context, MaterialPageRoute(
            //   builder: (_) => WordListScreen(topic: t),
            // ));
          },
          trailing: isAdmin
              ? PopupMenuButton(
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: "edit", child: Text("Sửa")),
                    PopupMenuItem(
                      value: "delete",
                      child: Text("Xóa", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                  onSelected: (v) {
                    if (v == "edit") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TopicEditScreen(topic: t),
                        ),
                      );
                    } else if (v == "delete") {
                      confirmDelete(t);
                    }
                  },
                )
              : null,
        );
      },
    );
  }

  Widget buildGrid(List<Topic> topics, bool isAdmin) {
    return GridView.count(
      crossAxisCount: 2,
      children: topics.map((t) {
        return Card(
          child: InkWell(
            // TODO: onTap -> chuyển sang màn danh sách từ trong bộ
            onTap: () {
              // Navigator.push(context, MaterialPageRoute(
              //   builder: (_) => WordListScreen(topic: t),
              // ));
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    t.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  if (isAdmin)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: PopupMenuButton(
                        icon: const Icon(Icons.more_vert, size: 20),
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: "edit", child: Text("Sửa")),
                          PopupMenuItem(
                            value: "delete",
                            child: Text(
                              "Xóa",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                        onSelected: (v) {
                          if (v == "edit") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TopicEditScreen(topic: t),
                              ),
                            );
                          } else if (v == "delete") {
                            confirmDelete(t);
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void confirmDelete(Topic t) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xóa bộ từ?"),
        content: Text("Bạn có chắc muốn xóa '${t.name}' không?"),
        actions: [
          TextButton(
            child: const Text("Hủy"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              await service.deleteTopic(t.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
