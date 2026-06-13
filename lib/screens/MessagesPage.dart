import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:rotam_turkiye/model/UserModel.dart';
import 'package:rotam_turkiye/viewmodel/my_user_model.dart';
import 'package:rotam_turkiye/screens/ChatPage.dart';
import 'package:rotam_turkiye/screens/PublicProfilePage.dart';
import 'package:rotam_turkiye/widgets/CustomInput.dart';

class MessagesPage extends StatefulWidget {
  // PublicProfilePage veya başka yerlerden sohbet başlatıldığında buraya eklenir
  static final List<UserModel> extraChats = [];

  const MessagesPage({super.key});

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<UserModel> _gezginler = []; // 25 random preseeded users
  Map<String, UserModel> _preseedUserMap = {}; // map of user details
  bool _isLoading = true;
  UserModel? _currentUser;
  bool _didFetchContacts = false;

  // Seyahat temalı mock son mesajlar
  final List<String> _mockMessages = [
    "Selam, Yalova'da kamp alanı önerin var mı?",
    "Erzurum'a giderken hangi rotayı kullanmalıyım?",
    "Kapadokya'da balon turu fiyatları hakkında bilgin var mı?",
    "Antalya Olimpos'ta kalınacak ucuz pansiyon biliyor musun?",
    "Artvin Karagöl gerçekten fotoğraflardaki kadar güzel mi?",
    "Haftaya buralardaysan bir kahve içelim mi?",
    "Gezdiğin şehirler listesine bayıldım, tebrikler!",
    "Fethiye Ölüdeniz için yamaç paraşütü önerir misin?",
    "Van Gölü Ekspresi bileti bulmak çok zormuş ya.",
    "Mardin'de o eski taş konaklarda kalmak harika bir deneyimdi.",
    "Rize yaylalarında havalar nasıl şu sıralar?",
    "İzmir'de boyoz yiyebileceğim en iyi yer neresi?",
    "Rotam Türkiye uygulamasını çok beğendim, harika olmuş.",
    "Bir sonraki seyahatin ne zaman?"
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userModel = Provider.of<MyUserModel>(context);
    final user = userModel.user;
    if (user != null && _currentUser != user) {
      _currentUser = user;
      if (!_didFetchContacts) {
        _didFetchContacts = true;
        _fetchContacts();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchContacts() async {
    final currentUser = _currentUser;
    if (currentUser == null) return;
    try {
      // Sadece 'preseed_user_' ile başlayan temiz havuzumuzu çekiyoruz
      final querySnapshot = await _firestore
          .collection('users')
          .get();

      final List<UserModel> allPreseeds = querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .where((user) => user.id.startsWith("preseed_user_"))
          .toList();

      if (allPreseeds.isNotEmpty) {
        _preseedUserMap = {for (var u in allPreseeds) u.id: u};

        // Havuzu karıştırıp rastgele 25 kişi seçiyoruz (Gezginler)
        allPreseeds.shuffle();
        final List<UserModel> selected25 = allPreseeds.take(25).toList();

        // Firestore'da bu kullanıcının aktif sohbeti var mı kontrol edelim
        final chatsSnapshot = await _firestore
            .collection('chats')
            .where('users', arrayContains: currentUser.id)
            .get();

        if (chatsSnapshot.docs.isEmpty) {
          // Hiç sohbet yoksa, random 25 gezginden 10 tanesini seçip Firestore'da sohbet ve mock mesajları oluşturalım (Preseed)
          final List<UserModel> copy25 = List.from(selected25)..shuffle();
          final List<UserModel> selected10 = copy25.take(10).toList();
          await _preseedChatsInFirestore(selected10, currentUser.id);
        }

        setState(() {
          _gezginler = selected25;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Kontaklar yuklenirken hata olustu: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _preseedChatsInFirestore(List<UserModel> selectedUsers, String currentUserId) async {
    final batch = _firestore.batch();
    final rand = math.Random();
    
    for (int i = 0; i < selectedUsers.length; i++) {
      final otherUser = selectedUsers[i];
      final chatId = currentUserId.compareTo(otherUser.id) < 0 
          ? '${currentUserId}_${otherUser.id}' 
          : '${otherUser.id}_$currentUserId';
          
      final mockMsg = _mockMessages[i % _mockMessages.length];
      
      // 1. Sohbet belgesini oluştur
      final chatDocRef = _firestore.collection('chats').doc(chatId);
      batch.set(chatDocRef, {
        'users': [currentUserId, otherUser.id],
        'user1': currentUserId.compareTo(otherUser.id) < 0 ? currentUserId : otherUser.id,
        'user2': currentUserId.compareTo(otherUser.id) < 0 ? otherUser.id : currentUserId,
        'lastMessage': mockMsg,
        'lastMessageSender': otherUser.id,
        'lastMessageTime': Timestamp.fromDate(DateTime.now().subtract(Duration(hours: i * 2, minutes: rand.nextInt(50)))),
        'isRead_$currentUserId': i % 3 == 0 ? false : true, // Bazılarını okunmamış yapalım
        'isRead_${otherUser.id}': true,
      });
      
      // 2. chats/{chatId}/messages altına mock mesaj geçmişi ekle (3 mesaj)
      final messagesCol = chatDocRef.collection('messages');
      
      // Mesaj 1
      batch.set(messagesCol.doc(), {
        'senderId': otherUser.id,
        'receiverId': currentUserId,
        'message': 'Selam! Rotam Türkiye\'de profilini gördüm.',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(Duration(hours: i * 2 + 1))),
      });
      
      // Mesaj 2
      batch.set(messagesCol.doc(), {
        'senderId': currentUserId,
        'receiverId': otherUser.id,
        'message': 'Merhaba! Evet, ben de yeni katıldım. Memnun oldum.',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(Duration(hours: i * 2, minutes: 30))),
      });
      
      // Mesaj 3 (Son mesaj)
      batch.set(messagesCol.doc(), {
        'senderId': otherUser.id,
        'receiverId': currentUserId,
        'message': mockMsg,
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(Duration(hours: i * 2, minutes: 10))),
      });
    }
    
    await batch.commit();
  }

  // Profil Fotoğrafı Fallback/Loading Widget'ı
  Widget _buildProfileImage({
    required String? photoUrl,
    required double radius,
    Color backgroundColor = Colors.white12,
    Color iconColor = Colors.white54,
  }) {
    final double size = radius * 2;
    if (photoUrl == null || photoUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.person, color: iconColor, size: radius * 1.1),
      );
    }

    return ClipOval(
      child: photoUrl.startsWith('http')
          ? Image.network(
              photoUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: iconColor, size: radius * 1.1),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                );
              },
            )
          : Image.asset(
              photoUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: iconColor, size: radius * 1.1),
                );
              },
            ),
    );
  }

  // Sohbeti Başlatma ve Mesajlar Tabına Aktarma Mantığı
  Future<void> _startChatWithUser(UserModel user) async {
    final currentUser = _currentUser;
    if (currentUser == null) return;
    
    final chatId = currentUser.id.compareTo(user.id) < 0
        ? '${currentUser.id}_${user.id}'
        : '${user.id}_${currentUser.id}';
    
    try {
      // Sohbet belgesini Firestore'da başlat
      await _firestore.collection('chats').doc(chatId).set({
        'users': [currentUser.id, user.id],
        'user1': currentUser.id.compareTo(user.id) < 0 ? currentUser.id : user.id,
        'user2': currentUser.id.compareTo(user.id) < 0 ? user.id : currentUser.id,
        'lastMessage': '',
        'lastMessageSender': currentUser.id,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'isRead_${currentUser.id}': true,
        'isRead_${user.id}': true,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Sohbet baslatilirken hata olustu: $e");
    }

    _tabController.index = 0;

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(receiverUser: user),
        ),
      );
    }
  }

  Future<void> _deleteChat(String chatId) async {
    try {
      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();
      
      final batch = _firestore.batch();
      for (var doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      batch.delete(_firestore.collection('chats').doc(chatId));
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sohbet silindi."),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint("Sohbet silinirken hata olustu: $e");
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context, String chatId) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            "Sohbeti Sil",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Bu kişiyle olan tüm sohbet geçmişini silmek istediğinize emin misiniz?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("İptal", style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Sil"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _currentUser;
    if (currentUser == null || _isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.redAccent),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Kontaktların",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          CustomInput(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            hintText: "Kontaktların içinde ara",
            leftIconName: "./assets/icons/search.png",
            rightIconName: "./assets/icons/menu.png",
            isPassword: false,
            inputType: InputType.TextField,
          ),
          const SizedBox(height: 10),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Mesajlar',
                    style: TextStyle(decoration: TextDecoration.none),
                  ),
                ),
              ),
              Tab(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Gezginler',
                    style: TextStyle(decoration: TextDecoration.none),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('chats')
                      .where('users', arrayContains: currentUser.id)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text("Sohbetler yüklenemedi.", style: TextStyle(color: Colors.white54)));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
                    }

                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(child: Text("Mesaj bulunamadı", style: TextStyle(color: Colors.white54)));
                    }

                    // In-memory sorting by lastMessageTime descending
                    final sortedDocs = List<QueryDocumentSnapshot>.from(docs);
                    sortedDocs.sort((a, b) {
                      final aData = a.data() as Map<String, dynamic>;
                      final bData = b.data() as Map<String, dynamic>;
                      final aTime = aData['lastMessageTime'] as Timestamp?;
                      final bTime = bData['lastMessageTime'] as Timestamp?;
                      if (aTime == null && bTime == null) return 0;
                      if (aTime == null) return 1;
                      if (bTime == null) return -1;
                      return bTime.compareTo(aTime); // descending
                    });

                    // Search filtering for active chats
                    final filteredDocs = sortedDocs.where((doc) {
                      if (_searchQuery.isEmpty) return true;
                      final data = doc.data() as Map<String, dynamic>;
                      final usersList = List<String>.from(data['users'] ?? []);
                      final otherUserId = usersList.firstWhere((id) => id != currentUser.id, orElse: () => '');
                      final otherUser = _preseedUserMap[otherUserId];
                      if (otherUser == null) return false;
                      final query = _searchQuery.toLowerCase();
                      return otherUser.name.toLowerCase().contains(query) ||
                             otherUser.city.toLowerCase().contains(query);
                    }).toList();

                    if (filteredDocs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.sentiment_dissatisfied_rounded, color: Colors.white24, size: 64),
                            const SizedBox(height: 12),
                            Text(
                              "Aradığınız kriterde bir sohbet bulunamadı 🏔️",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final doc = filteredDocs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final usersList = List<String>.from(data['users'] ?? []);
                        final otherUserId = usersList.firstWhere((id) => id != currentUser.id, orElse: () => '');
                        
                        final otherUser = _preseedUserMap[otherUserId] ?? UserModel(
                          id: otherUserId,
                          name: 'Gezgin',
                          email: '',
                          city: '',
                        );

                        final lastMessage = (data['lastMessage'] ?? '') as String;
                        final lastMessageTime = data['lastMessageTime'] as Timestamp?;
                        String timeStr = '';
                        if (lastMessageTime != null) {
                          final dt = lastMessageTime.toDate();
                          final now = DateTime.now();
                          final diff = now.difference(dt);
                          if (diff.inDays == 0 && now.day == dt.day) {
                            timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                          } else if (diff.inDays == 1 || (diff.inDays == 0 && now.day != dt.day)) {
                            timeStr = 'Dün';
                          } else {
                            timeStr = '${dt.day}/${dt.month}/${dt.year}';
                          }
                        }

                        final isRead = (data['isRead_${currentUser.id}'] ?? true) as bool;

                        return _buildMessageCard(
                          context,
                          otherUser,
                          lastMessage,
                          timeStr,
                          isRead,
                          doc.id,
                          currentUser.id,
                        );
                      },
                    );
                  },
                ),
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
                    : (() {
                        final filteredGezginler = _gezginler.where((user) {
                          if (_searchQuery.isEmpty) return true;
                          final query = _searchQuery.toLowerCase();
                          return user.name.toLowerCase().contains(query) ||
                                 user.city.toLowerCase().contains(query);
                        }).toList();

                        if (filteredGezginler.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.sentiment_dissatisfied_rounded, color: Colors.white24, size: 64),
                                const SizedBox(height: 12),
                                Text(
                                  "Aradığınız kriterde bir gezgin bulunamadı 🏔️",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: filteredGezginler.length,
                          itemBuilder: (context, index) {
                            return _buildAcceptedRequestItem(context, filteredGezginler[index], index);
                          },
                        );
                      })()
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptedRequestItem(BuildContext context, UserModel user, int index) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PublicProfilePage(user: user),
          ),
        );
        if (result == true) {
          _startChatWithUser(user);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildProfileImage(photoUrl: user.photoUrl, radius: 20),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                user.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              user.city.isNotEmpty ? user.city : "Belirtilmemiş",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard(
    BuildContext context,
    UserModel otherUser,
    String lastMessage,
    String timeStr,
    bool isRead,
    String chatId,
    String currentUserId,
  ) {
    return Dismissible(
      key: Key(chatId),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: Colors.redAccent,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.redAccent,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmationDialog(context, chatId);
      },
      onDismissed: (direction) {
        _deleteChat(chatId);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        color: Colors.grey[900],
        child: ListTile(
          onTap: () {
            // Sohbeti okundu olarak işaretle
            _firestore.collection('chats').doc(chatId).update({
              'isRead_$currentUserId': true,
            });

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(receiverUser: otherUser),
              ),
            );
          },
          onLongPress: () async {
            final confirm = await _showDeleteConfirmationDialog(context, chatId);
            if (confirm == true) {
              await _deleteChat(chatId);
            }
          },
          leading: _buildProfileImage(photoUrl: otherUser.photoUrl, radius: 20),
          title: Text(
            otherUser.city.isNotEmpty ? "${otherUser.name} - ${otherUser.city}" : otherUser.name,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            lastMessage.isNotEmpty ? lastMessage : "(Sohbet henüz başlatılmadı)",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeStr,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
              ),
              if (!isRead) ...[
                const SizedBox(height: 6),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
