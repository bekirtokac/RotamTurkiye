import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rotam_turkiye/model/UserModel.dart';
import 'package:rotam_turkiye/viewmodel/my_user_model.dart';

class ChatPage extends StatefulWidget {
  final UserModel receiverUser;

  const ChatPage({super.key, required this.receiverUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String? _chatId;
  UserModel? _currentUser;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userModel = Provider.of<MyUserModel>(context);
    final user = userModel.user;
    if (user != null && !_isInitialized) {
      _currentUser = user;
      _chatId = user.id.compareTo(widget.receiverUser.id) < 0
          ? '${user.id}_${widget.receiverUser.id}'
          : '${widget.receiverUser.id}_${user.id}';
      _isInitialized = true;
      _markAsRead();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _markAsRead() async {
    final chatId = _chatId;
    final currentUser = _currentUser;
    if (chatId == null || currentUser == null) return;
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'isRead_${currentUser.id}': true,
      });
    } catch (_) {
      // Sohbet belgesi henüz oluşmamış olabilir, hata yutulur
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final currentUser = _currentUser;
    final chatId = _chatId;
    if (currentUser == null || chatId == null) return;

    _messageController.clear();
    final timestamp = FieldValue.serverTimestamp();

    final messageData = {
      'senderId': currentUser.id,
      'receiverId': widget.receiverUser.id,
      'message': text,
      'timestamp': timestamp,
    };

    final chatData = {
      'users': [currentUser.id, widget.receiverUser.id],
      'user1': currentUser.id.compareTo(widget.receiverUser.id) < 0 ? currentUser.id : widget.receiverUser.id,
      'user2': currentUser.id.compareTo(widget.receiverUser.id) < 0 ? widget.receiverUser.id : currentUser.id,
      'lastMessage': text,
      'lastMessageSender': currentUser.id,
      'lastMessageTime': timestamp,
      'isRead_${currentUser.id}': true,
      'isRead_${widget.receiverUser.id}': false,
    };

    try {
      final chatRef = _firestore.collection('chats').doc(chatId);
      await chatRef.collection('messages').add(messageData);
      await chatRef.set(chatData, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Mesaj gonderilirken hata olustu: $e");
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildMessageBubble(String message, bool fromMe, String time) {
    return Align(
      alignment: fromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: fromMe ? Colors.blue : Colors.grey[800],
          borderRadius: BorderRadius.only(
            topRight: fromMe ? const Radius.circular(0) : const Radius.circular(20),
            topLeft: fromMe ? const Radius.circular(20) : const Radius.circular(0),
            bottomRight: const Radius.circular(20),
            bottomLeft: const Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              fromMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInputField() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              onSubmitted: (_) => _sendMessage(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Mesaj yazın...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                filled: true,
                fillColor: Colors.grey[800],
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _currentUser;
    final chatId = _chatId;

    if (currentUser == null || chatId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.receiverUser.name,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.redAccent),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.receiverUser.name,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "Mesajlar yuklenirken hata olustu.",
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.redAccent),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.forum_rounded, color: Colors.white24, size: 64),
                        const SizedBox(height: 12),
                        Text(
                          "Henuz mesaj yok. Ilk mesaji siz gonderin!",
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index].data() as Map<String, dynamic>;
                    final messageText = (doc['message'] ?? '') as String;
                    final senderId = (doc['senderId'] ?? '') as String;
                    final fromMe = senderId == currentUser.id;

                    DateTime dateTime = DateTime.now();
                    if (doc['timestamp'] != null) {
                      dateTime = (doc['timestamp'] as Timestamp).toDate();
                    }
                    final timeStr = _formatTime(dateTime);

                    return _buildMessageBubble(messageText, fromMe, timeStr);
                  },
                );
              },
            ),
          ),
          _buildMessageInputField(),
        ],
      ),
    );
  }
}
