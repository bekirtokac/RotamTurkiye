import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rotam_turkiye/model/UserModel.dart';
import 'package:rotam_turkiye/screens/PublicProfilePage.dart';
import 'package:rotam_turkiye/viewmodel/my_user_model.dart';

class TravelCompanionsPage extends StatefulWidget {
  const TravelCompanionsPage({super.key});

  @override
  State<TravelCompanionsPage> createState() => _TravelCompanionsPageState();
}

class _TravelCompanionsPageState extends State<TravelCompanionsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initCompanionsData();
  }

  Future<void> _initCompanionsData() async {
    try {
      final companionsCollection = _firestore.collection('co_travelers');
      final snapshot = await companionsCollection.get();

      if (snapshot.docs.isEmpty) {
        // Preseed users so they exist in 'users' collection
        final List<Map<String, dynamic>> mockUsers = [
          {
            'id': 'preseed_user_ali',
            'name': 'Ali',
            'email': 'ali@rotam.com',
            'city': 'İstanbul',
            'score': 150,
            'photoUrl': '',
            'ticket': 5,
          },
          {
            'id': 'preseed_user_eren',
            'name': 'Eren',
            'email': 'eren@rotam.com',
            'city': 'İzmir',
            'score': 120,
            'photoUrl': '',
            'ticket': 3,
          },
          {
            'id': 'preseed_user_serif',
            'name': 'Şerif',
            'email': 'serif@rotam.com',
            'city': 'Ankara',
            'score': 90,
            'photoUrl': '',
            'ticket': 2,
          },
        ];

        final batch = _firestore.batch();
        for (var user in mockUsers) {
          final userRef = _firestore.collection('users').doc(user['id']);
          batch.set(userRef, user, SetOptions(merge: true));
        }

        // Preseed 3 co-travelers ads
        final List<Map<String, dynamic>> mockCompanions = [
          {
            'userId': 'preseed_user_ali',
            'userName': 'Ali',
            'fromLocation': 'İstanbul',
            'toLocation': 'Bolu Yedigöller',
            'description': 'Hafta sonu doğa kaçamağı için 2 gece kamp yapmaya gidiyorum. Altımda SUV araç var, masrafları bölüşecek kafa dengi yol arkadaşı arıyorum.',
            'date': '15-17 Haziran 2026',
            'createdAt': FieldValue.serverTimestamp(),
          },
          {
            'userId': 'preseed_user_eren',
            'userName': 'Eren',
            'fromLocation': 'İzmir',
            'toLocation': 'Fethiye Kabak Koyu',
            'description': 'Motosikletle Ege turuna çıkıyorum. Fethiye\'de çadır kurup kafa dinleyeceğiz, eşlik etmek isteyen lokaller yazsın.',
            'date': '20-25 Haziran 2026',
            'createdAt': FieldValue.serverTimestamp(),
          },
          {
            'userId': 'preseed_user_serif',
            'userName': 'Şerif',
            'fromLocation': 'Ankara',
            'toLocation': 'Kapadokya',
            'description': 'Fotoğraf çekimi ve balon festivali için gidiyorum. Arabada 2 kişilik yerim var, muhabbeti saran yol arkadaşları mesaj atsın.',
            'date': '28-30 Haziran 2026',
            'createdAt': FieldValue.serverTimestamp(),
          },
        ];

        for (var companion in mockCompanions) {
          final docRef = companionsCollection.doc();
          batch.set(docRef, companion);
        }

        await batch.commit();
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Yol arkadaşı ilanları ilklendirilirken hata oluştu: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToProfile(BuildContext context, String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && context.mounted) {
        final user = UserModel.fromMap(doc.data()!, doc.id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PublicProfilePage(user: user),
          ),
        );
      } else {
        debugPrint("Kullanıcı bulunamadı: $userId");
      }
    } catch (e) {
      debugPrint("Profil sayfasına gidilirken hata: $e");
    }
  }

  void _showAddListingSheet(BuildContext context) {
    final fromController = TextEditingController();
    final toController = TextEditingController();
    final dateController = TextEditingController();
    final descController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    // Başlık
                    const Text(
                      '✈️ Yeni Yol Arkadaşı İlanı',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Gezini paylaş, birlikte keşfet.',
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    // Nereden
                    _buildSheetField(
                      controller: fromController,
                      hint: 'Nereden?  (Örn: İstanbul)',
                      icon: Icons.flight_takeoff_rounded,
                    ),
                    const SizedBox(height: 12),
                    // Nereye
                    _buildSheetField(
                      controller: toController,
                      hint: 'Nereye?  (Örn: Yedigöller)',
                      icon: Icons.flight_land_rounded,
                    ),
                    const SizedBox(height: 12),
                    // Tarih
                    _buildSheetField(
                      controller: dateController,
                      hint: 'Gezi Tarihi?  (Örn: 20-22 Haziran)',
                      icon: Icons.calendar_month_rounded,
                    ),
                    const SizedBox(height: 12),
                    // Açıklama (multi-line)
                    _buildSheetField(
                      controller: descController,
                      hint: 'İlan Açıklaması  (Örn: Masrafları bölüşecek arkadaş arıyorum...)',
                      icon: Icons.notes_rounded,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    // Yayınla Butonu
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final from = fromController.text.trim();
                                final to = toController.text.trim();
                                final date = dateController.text.trim();
                                final desc = descController.text.trim();

                                if (from.isEmpty || to.isEmpty || date.isEmpty || desc.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Row(
                                        children: [
                                          Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                                          SizedBox(width: 10),
                                          Expanded(child: Text('Lütfen tüm alanları doldurun.')),
                                        ],
                                      ),
                                      backgroundColor: Colors.orange.shade800,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      margin: const EdgeInsets.all(16),
                                    ),
                                  );
                                  return;
                                }

                                setSheetState(() => isSubmitting = true);

                                try {
                                  final userModel = Provider.of<MyUserModel>(context, listen: false);
                                  final currentUser = userModel.user;

                                  await _firestore.collection('co_travelers').add({
                                    'userId': currentUser?.id ?? '',
                                    'userName': currentUser?.name ?? 'Gezgin',
                                    'fromLocation': from,
                                    'toLocation': to,
                                    'date': date,
                                    'description': desc,
                                    'createdAt': FieldValue.serverTimestamp(),
                                  });

                                  if (context.mounted) {
                                    Navigator.pop(sheetContext);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Row(
                                          children: [
                                            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                'Yol arkadaşı ilanınız başarıyla yayınlandı! 🎉',
                                                style: TextStyle(fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: Colors.green.shade700,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        margin: const EdgeInsets.all(16),
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  setSheetState(() => isSubmitting = false);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('İlan yayınlanırken hata oluştu: $e'),
                                        backgroundColor: Colors.redAccent,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        margin: const EdgeInsets.all(16),
                                      ),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          disabledBackgroundColor: Colors.redAccent.withValues(alpha: 0.4),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        icon: isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded, size: 20),
                        label: Text(
                          isSubmitting ? 'Yayınlanıyor...' : 'İlanı Yayınla',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSheetField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 10.0 : 0),
            child: Icon(icon, color: Colors.redAccent, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              minLines: 1,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddListingSheet(context),
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tooltip: 'Yeni İlan Ekle',
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "🤝 Yol Arkadaşı Bul",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('co_travelers')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.redAccent),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Bir hata oluştu: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white54),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aktif bir gezi ilanı bulunmuyor.',
                      style: TextStyle(color: Colors.white54, fontSize: 15),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final String userId = data['userId'] as String? ?? '';
                    final String userName = data['userName'] as String? ?? 'Gezgin';
                    final String fromLocation = data['fromLocation'] as String? ?? '';
                    final String toLocation = data['toLocation'] as String? ?? '';
                    final String description = data['description'] as String? ?? '';
                    final String date = data['date'] as String? ?? '';
                    final String initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

                    return GestureDetector(
                      onTap: () => _navigateToProfile(context, userId),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                                  child: Text(
                                    initial,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const Spacer(),
                                // Route visual
                                Text(
                                  fromLocation,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.redAccent,
                                    size: 16,
                                  ),
                                ),
                                Text(
                                  toLocation,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              description,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month_rounded,
                                  color: Colors.white30,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  date,
                                  style: const TextStyle(
                                    color: Colors.white30,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
