import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'controller/message_controller.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final Map<String, dynamic> otherUser;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUser,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final msgCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(messageControllerProvider.notifier).loadMessages(widget.conversationId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messageControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  NetworkImage(widget.otherUser['avatar_url'] ?? ""),
            ),
            const SizedBox(width: 10),
            Text(widget.otherUser['username'] ?? 'User'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: state.loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: state.messages.length,
                    itemBuilder: (context, i) {
                      final msg = state.messages[i];
                      final isMe = ref
                              .read(messageControllerProvider.notifier)
                              .userId ==
                          msg['sender_id'];

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            msg['content'],
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Input bar
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: msgCtrl,
                    decoration: const InputDecoration(
                      hintText: "Message",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = msgCtrl.text.trim();
                    if (text.isEmpty) return;

                    await ref
                        .read(messageControllerProvider.notifier)
                        .send(widget.conversationId, text);

                    msgCtrl.clear();
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
