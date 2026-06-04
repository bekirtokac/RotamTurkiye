import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rotam_turkiye/model/UserModel.dart';
import 'package:rotam_turkiye/screens/PublicProfilePage.dart';
import 'package:rotam_turkiye/screens/MessagesPage.dart';
import 'package:rotam_turkiye/screens/ChatPage.dart';


class LeaderboardEntry {
  final UserModel user;
  final int rank;
  LeaderboardEntry({required this.user, required this.rank});
}

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  
  List<LeaderboardEntry> _allEntries = [];
  List<LeaderboardEntry> _filteredEntries = [];
  bool _isLoading = true;
  int _displayLimit = 10;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLeaderboard() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Firestore'dan tüm kullanıcıları alıp, sadece preseed_user_ olanları filtreliyoruz
      final querySnapshot = await _firestore
          .collection('users')
          .get();

      final List<UserModel> preseedUsers = querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .where((user) => user.id.startsWith("preseed_user_"))
          .toList();

      // Puanlarına göre büyükten küçüğe sıralıyoruz
      preseedUsers.sort((a, b) => b.score.compareTo(a.score));

      final List<LeaderboardEntry> loaded = [];
      int rank = 1;
      for (var user in preseedUsers) {
        loaded.add(LeaderboardEntry(
          user: user,
          rank: rank++,
        ));
      }

      setState(() {
        _allEntries = loaded;
        _filteredEntries = loaded;
        _isLoading = false;
      });
    } catch (e) {
      print("Liderlik tablosu yüklenirken hata oluştu: $e");
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Liderlik tablosu yüklenemedi. Lütfen internetinizi kontrol edin."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase().trim();
      if (_searchQuery.isEmpty) {
        _filteredEntries = _allEntries;
      } else {
        _filteredEntries = _allEntries.where((entry) {
          final nameMatch = entry.user.name.toLowerCase().contains(_searchQuery);
          final cityMatch = entry.user.city.toLowerCase().contains(_searchQuery);
          return nameMatch || cityMatch;
        }).toList();
      }
      _displayLimit = 10; // Arama yapıldığında listeyi en baştan göster
    });
  }

  void _loadMore() {
    setState(() {
      _displayLimit = (_displayLimit + 10).clamp(10, 100);
    });
  }

  Widget _buildProfileImage({
    required String? photoUrl,
    required double radius,
    required Color backgroundColor,
    required Color iconColor,
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

  @override
  Widget build(BuildContext context) {
    final displayedEntries = _filteredEntries.take(_displayLimit).toList();
    final hasMore = _filteredEntries.length > _displayLimit && _displayLimit < 100;

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
          "Zirve 100",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            // ─── Dağ Temalı Header ───
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.filter_hdr_rounded, color: Colors.redAccent, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    "Dağcılık Liderlik Tablosu",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // ─── Arama Çubuğu (Search Bar) ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Gezgin ismi veya şehir ara...",
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                    prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: 0.5)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded, color: Colors.white.withValues(alpha: 0.6)),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged("");
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ─── Kullanıcı Listesi ───
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.redAccent),
                    )
                  : _filteredEntries.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_search_rounded,
                                  color: Colors.white24, size: 64),
                              const SizedBox(height: 12),
                              Text(
                                "Kullanıcı bulunamadı",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: displayedEntries.length + (hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == displayedEntries.length) {
                              // "Devamını Göster" butonu
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                                    ),
                                  ),
                                  onPressed: _loadMore,
                                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                                  label: const Text(
                                    "Devamını Göster",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final entry = displayedEntries[index];
                            return _buildLeaderboardCard(entry);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardCard(LeaderboardEntry entry) {
    final user = entry.user;
    final rank = entry.rank;

    // Renk ve Tasarım Kuralları
    Gradient cardGradient;
    Border cardBorder;
    Color textColor;
    Color subtitleColor;
    late final Widget rankBadge;

    if (rank == 1) {
      // 1. Olan: Parlak sarı/altın gradyanı
      cardGradient = const LinearGradient(
        colors: [Color(0xFFF1C40F), Color(0xFFF39C12)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      cardBorder = Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5);
      textColor = Colors.black;
      subtitleColor = Colors.black.withValues(alpha: 0.65);
      rankBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("🚩", style: TextStyle(fontSize: 15)),
            SizedBox(width: 4),
            Text(
              "1",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );
    } else if (rank == 2 || rank == 3) {
      // 2. ve 3. Olan: Şık kırmızı tonu
      cardGradient = LinearGradient(
        colors: rank == 2
            ? [const Color(0xFFE74C3C), const Color(0xFFC0392B)]
            : [const Color(0xFFD32F2F), const Color(0xFF9E1C1C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      cardBorder = Border.all(color: Colors.white.withValues(alpha: 0.2));
      textColor = Colors.white;
      subtitleColor = Colors.white.withValues(alpha: 0.7);
      rankBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          "$rank",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
    } else if (rank <= 10) {
      // 4-10 arası: Kırmızı accent border ile beyaz cam efekti
      cardGradient = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.12),
          Colors.white.withValues(alpha: 0.06),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      cardBorder = Border.all(color: Colors.redAccent.withValues(alpha: 0.4), width: 1.2);
      textColor = Colors.white;
      subtitleColor = Colors.white.withValues(alpha: 0.6);
      rankBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          "$rank",
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    } else {
      // 11-100 arası: Standart koyu cam efekti
      cardGradient = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.06),
          Colors.white.withValues(alpha: 0.02),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      cardBorder = Border.all(color: Colors.white.withValues(alpha: 0.08));
      textColor = Colors.white;
      subtitleColor = Colors.white.withValues(alpha: 0.5);
      rankBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          "$rank",
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        gradient: cardGradient,
        borderRadius: BorderRadius.circular(18),
        border: cardBorder,
        boxShadow: rank == 1
            ? [
                BoxShadow(
                  color: const Color(0xFFF39C12).withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: ListTile(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PublicProfilePage(user: user),
            ),
          );
          if (result == true) {
            if (!MessagesPage.extraChats.any((c) => c.id == user.id)) {
              MessagesPage.extraChats.insert(0, user);
            }
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(personName: user.name),
                ),
              );
            }
          }
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            rankBadge,
            const SizedBox(width: 14),
            _buildProfileImage(
              photoUrl: user.photoUrl,
              radius: 22,
              backgroundColor: rank == 1 ? Colors.black12 : Colors.white12,
              iconColor: rank == 1 ? Colors.black54 : Colors.white54,
            ),
          ],
        ),
        title: Text(
          user.name,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              color: rank == 1 ? Colors.black54 : Colors.redAccent.withValues(alpha: 0.8),
              size: 13,
            ),
            const SizedBox(width: 4),
            Text(
              user.city.isNotEmpty ? user.city : "Belirtilmemiş",
              style: TextStyle(
                color: subtitleColor,
                fontSize: 13,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: rank == 1 ? Colors.black.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "${user.score} Puan",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
