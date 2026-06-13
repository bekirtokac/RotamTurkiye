import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rotam_turkiye/model/UserModel.dart';
import 'package:rotam_turkiye/viewmodel/my_user_model.dart';
import 'package:rotam_turkiye/screens/ChatPage.dart';
import 'dart:math' as math;


class PublicProfilePage extends StatefulWidget {
  final UserModel user;

  const PublicProfilePage({super.key, required this.user});

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _pastTrips = [];
  bool _isLoadingTrips = true;
  int? _userRank;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      // 1. Kullanıcının Zirve 100 Sıralamasını Çek
      final countSnapshot = await _firestore
          .collection('users')
          .where('score', isGreaterThan: widget.user.score)
          .count()
          .get();
      
      if (mounted) {
        setState(() {
          _userRank = (countSnapshot.count ?? 0) + 1;
        });
      }

      // 2. Seyahat Geçmişini Çek / Auto-Seed Çalıştır
      final CollectionReference visitedCitiesRef = _firestore
          .collection("users")
          .doc(widget.user.id)
          .collection("visited_cities");

      final snapshot = await visitedCitiesRef.get();
      List<Map<String, dynamic>> trips = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'docId': doc.id,
        };
      }).toList();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      List<Map<String, dynamic>> past = [];

      for (var trip in trips) {
        final dateStr = (trip['date'] ?? '') as String;
        final parsedDate = _parseDate(dateStr);
        if (parsedDate == null || !parsedDate.isAfter(today)) {
          past.add(trip);
        }
      }

      // Eğer Firestore alt seyahat geçmişi boşsa ve puanı > 0 ise, puanla tutarlı sahte veriler oluşturup kaydet (Auto-Seed)
      if (past.isEmpty && widget.user.score > 0 && widget.user.id.startsWith("preseed_user_")) {
        final rand = math.Random();
        final List<String> citiesList = [
          "İstanbul", "Ankara", "İzmir", "Bursa", "Antalya", "Adana", "Konya", "Gaziantep", "Trabzon", "Eskişehir",
          "Samsun", "Denizli", "Muğla", "Kayseri", "Mersin", "Çanakkale", "Yalova", "Rize", "Sivas", "Van"
        ];

        int remainingDays = widget.user.score ~/ 10;
        final WriteBatch batch = _firestore.batch();

        while (remainingDays > 0) {
          int duration = rand.nextInt(10) + 3; // 3 - 12 gün arası
          if (duration > remainingDays || remainingDays - duration < 3) {
            duration = remainingDays;
          }
          remainingDays -= duration;

          final monthsAgo = rand.nextInt(12) + 1;
          final day = rand.nextInt(28) + 1;
          final dateStr = "$day/$monthsAgo/2025"; // Geçmiş tarih

          final city = citiesList[rand.nextInt(citiesList.length)];
          final docRef = visitedCitiesRef.doc();

          final tripData = {
            'city': city,
            'spent_day': duration,
            'date': dateStr,
          };
          batch.set(docRef, tripData);
          past.add(tripData);
        }

        await batch.commit();
      }

      if (mounted) {
        setState(() {
          _pastTrips = past;
          _isLoadingTrips = false;
        });
      }
    } catch (e) {
      debugPrint("Gezgin profili yuklenirken hata olustu: $e");
      if (mounted) {
        setState(() {
          _isLoadingTrips = false;
        });
      }
    }
  }

  DateTime? _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]), // year
          int.parse(parts[1]), // month
          int.parse(parts[0]), // day
        );
      }
    } catch (_) {}
    return null;
  }

  // Profil Fotoğrafı Korumalı Widget
  Widget _buildProfileImage({
    required String? photoUrl,
    required double radius,
  }) {
    final double size = radius * 2;
    if (photoUrl == null || photoUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white12,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.person, color: Colors.white54, size: radius * 1.1),
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
                  decoration: const BoxDecoration(
                    color: Colors.white12,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: Colors.white54, size: radius * 1.1),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: size,
                  height: size,
                  decoration: const BoxDecoration(
                    color: Colors.white12,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
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
                  decoration: const BoxDecoration(
                    color: Colors.white12,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: Colors.white54, size: radius * 1.1),
                );
              },
            ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.redAccent, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Set<String> uniqueCities = {};
    for (var trip in _pastTrips) {
      final city = (trip['city'] ?? '') as String;
      if (city.isNotEmpty) {
        uniqueCities.add(city);
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Gezgin Profili",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            // Büyük Avatar
            _buildProfileImage(photoUrl: widget.user.photoUrl, radius: 64),
            const SizedBox(height: 20),

            // İsim
            Text(
              widget.user.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Şehir
            Text(
              widget.user.city.isNotEmpty ? widget.user.city : "Şehir belirtilmemiş",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            if (_userRank != null) ...[
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF1C40F), Color(0xFFF39C12)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF39C12).withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.emoji_events_rounded,
                          color: Colors.black, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        "Zirve #$_userRank",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),
            if (widget.user.id != Provider.of<MyUserModel>(context, listen: false).user?.id) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      final userModel = Provider.of<MyUserModel>(context, listen: false);
                      final currentUser = userModel.user;
                      if (currentUser != null) {
                        final chatId = currentUser.id.compareTo(widget.user.id) < 0
                            ? '${currentUser.id}_${widget.user.id}'
                            : '${widget.user.id}_${currentUser.id}';

                        await FirebaseFirestore.instance
                            .collection('chats')
                            .doc(chatId)
                            .set({
                          'users': [currentUser.id, widget.user.id],
                          'user1': currentUser.id.compareTo(widget.user.id) < 0
                              ? currentUser.id
                              : widget.user.id,
                          'user2': currentUser.id.compareTo(widget.user.id) < 0
                              ? widget.user.id
                              : currentUser.id,
                          'lastMessage': '',
                          'lastMessageSender': currentUser.id,
                          'lastMessageTime': FieldValue.serverTimestamp(),
                          'isRead_${currentUser.id}': true,
                          'isRead_${widget.user.id}': true,
                        }, SetOptions(merge: true));
                      }

                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(receiverUser: widget.user),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.send_rounded),
                    label: const Text(
                      "Mesaj Gönder",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // İstatistik Kartları (Puanlar ve Gezilen Şehir)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildStatCard("Puanlar", "${widget.user.score}", Icons.star_rounded),
                  _buildStatCard("Gezilen Şehir", "${uniqueCities.length}", Icons.location_city_rounded),
                ],
              ),
            ),

            const SizedBox(height: 24),
            // Gezdiğim Yerler Başlığı
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.explore_rounded, color: Colors.redAccent, size: 22),
                  SizedBox(width: 8),
                  Text(
                    "Gezdiği Yerler",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Gezdiği Yerler Listesi
            _isLoadingTrips
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator(color: Colors.redAccent)),
                  )
                : _pastTrips.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.flight_takeoff_rounded, color: Colors.white24, size: 48),
                              const SizedBox(height: 8),
                              Text(
                                "Henüz gezilen yer eklenmemiş",
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.38), fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _pastTrips.length,
                        itemBuilder: (context, index) {
                          final place = _pastTrips[index];
                          final cityName = (place['city'] ?? 'Bilinmeyen') as String;
                          final days = (place['spent_day'] ?? place['days'] ?? 0) as int;
                          final date = (place['date'] ?? '') as String;

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 24),
                              ),
                              title: Text(
                                cityName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    '$days gün • $date',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
