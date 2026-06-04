import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rotam_turkiye/model/UserModel.dart';
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
  List<UserModel> _messagesContacts = []; // 10 random preseeded users from the 25 + extraChats
  bool _isLoading = true;

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

  // Uydurma mesaj saatleri
  final List<String> _mockTimes = [
    "14:32", "Dün", "10:15", "18:45", "Salı", "09:05", "Dün", "16:20", "Pazartesi", "12:00"
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchContacts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchContacts() async {
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
        // Havuzu karıştırıp rastgele 25 kişi seçiyoruz (Gezginler)
        allPreseeds.shuffle();
        final List<UserModel> selected25 = allPreseeds.take(25).toList();

        // Bu 25 kişi içerisinden rastgele 10 kişi seçiyoruz (Mesajlar)
        final List<UserModel> copy25 = List.from(selected25)..shuffle();
        final List<UserModel> selected10 = copy25.take(10).toList();

        // MessagesPage.extraChats elemanlarını en başa ekleyip, selected10 ile birleştiriyoruz (mükerrer olmayacak şekilde)
        final List<UserModel> mergedChats = [];
        mergedChats.addAll(MessagesPage.extraChats);
        for (var user in selected10) {
          if (!mergedChats.any((c) => c.id == user.id)) {
            mergedChats.add(user);
          }
        }

        setState(() {
          _gezginler = selected25;
          _messagesContacts = mergedChats;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Kontaklar yüklenirken hata oluştu: $e");
      setState(() {
        _isLoading = false;
      });
    }
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
  void _startChatWithUser(UserModel user) {
    // 1. extraChats havuzuna ekle
    if (!MessagesPage.extraChats.any((c) => c.id == user.id)) {
      MessagesPage.extraChats.insert(0, user);
    }

    // 2. Aktif sohbetler listesinde yoksa en başa ekle ve state güncelle
    if (!_messagesContacts.any((c) => c.id == user.id)) {
      setState(() {
        _messagesContacts.insert(0, user);
      });
    }

    // 3. TabController'ı Mesajlar (index 0) sekmesine geçir
    _tabController.index = 0;

    // 4. Sohbet sayfasını aç
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(personName: user.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Kontaktların",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black, // AppBar arka planını siyah yap
      ),
      backgroundColor: Colors.black, // Sayfa arka planını siyah yap
      body: Column(
        children: [
          CustomInput(
            hintText: "Kontaktların içinde ara",
            leftIconName: "./assets/icons/search.png",
            rightIconName: "./assets/icons/menu.png",
            isPassword: false,
            inputType: InputType.TextField,
          ),
          const SizedBox(height: 10), // Aralarına bir boşluk ekleyelim
          TabBar(
            controller: _tabController,
            tabs: [
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

          const SizedBox(height: 10), // Aralarına bir boşluk ekleyelim
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
                    : _messagesContacts.isEmpty
                        ? const Center(child: Text("Mesaj bulunamadı", style: TextStyle(color: Colors.white54)))
                        : ListView.builder(
                            itemCount: _messagesContacts.length,
                            itemBuilder: (context, index) {
                              return _buildMessageCard(context, _messagesContacts[index], index);
                            },
                          ),
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
                    : _gezginler.isEmpty
                        ? const Center(child: Text("Gezgin bulunamadı", style: TextStyle(color: Colors.white54)))
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // Yatayda 3 öğe göster
                              crossAxisSpacing: 10, // Yatayda öğeler arasındaki boşluk
                              mainAxisSpacing: 10, // Dikeyde öğeler arasındaki boşluk
                            ),
                            itemCount: _gezginler.length,
                            itemBuilder: (context, index) {
                              return _buildAcceptedRequestItem(context, _gezginler[index], index);
                            },
                          )
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
          color: Colors.grey[900], // Kart arka planını gri tonlarında yap
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

  Widget _buildMessageCard(BuildContext context, UserModel user, int index) {
    final personName = user.name;
    final lastMessage = _mockMessages[index % _mockMessages.length];
    final messageTime = _mockTimes[index % _mockTimes.length];
    final newMessageCount = index % 3 == 0 ? 1 : 0; // Uydurma yeni mesaj sayısı

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      color: Colors.grey[900], // Kart arka planını gri tonlarında yap
      child: ListTile(
        leading: _buildProfileImage(photoUrl: user.photoUrl, radius: 20),
        title: Text(
          user.city.isNotEmpty ? "$personName - ${user.city}" : personName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Başlık rengini beyaz yap
        ),
        subtitle: Text(
          lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              messageTime,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
            ),
            if (newMessageCount > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$newMessageCount',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(personName: personName),
            ),
          );
        },
      ),
    );
  }
}
