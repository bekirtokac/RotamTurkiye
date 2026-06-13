import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rotam_turkiye/screens/CreatePost.dart';
import 'package:rotam_turkiye/screens/LeaderboardPage.dart';
import 'package:rotam_turkiye/services/mock_data_service.dart';
import 'package:rotam_turkiye/viewmodel/my_user_model.dart';
import 'package:rotam_turkiye/widgets/Post.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  // RefreshIndicator için globalKey gereksiz; stream zaten canlı.
  // Sadece setState ile rebuild tetiklemek yeterli.
  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() {});
  }

  /// SharedPreferences'tan okunan yerel profil resmi yolu
  String? _localProfileImagePath;

  // ── Mock veri durumu (DEV ONLY) ──────────────────────────────────────────
  bool _mockSeeded = true;   // başlangıçta gizli; initState'te kontrol edilir
  bool _isMockSeeding = false;

  @override
  void initState() {
    super.initState();
    _loadLocalProfilePath();
    _checkMockSeeded();
  }

  /// Daha önce seed yapılıp yapılmadığını kontrol eder.
  Future<void> _checkMockSeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('mock_posts_seeded') ?? false;
    if (mounted) setState(() => _mockSeeded = done);
  }

  /// 25 sahte postu Firestore'a ekler (tek seferlik).
  Future<void> _seedMockData() async {
    if (_isMockSeeding) return;
    setState(() => _isMockSeeding = true);
    try {
      final count = await MockDataService.createMockPosts();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('mock_posts_seeded', true);
      if (mounted) {
        setState(() {
          _mockSeeded = true;
          _isMockSeeding = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1E1E1E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Text(
              '✅ $count sahte post Firestore\'a yüklendi!',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isMockSeeding = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[900],
            content: Text('❌ Hata: $e',
                style: const TextStyle(color: Colors.white)),
          ),
        );
      }
    }
  }

  // ── SharedPreferences'tan yerel profil resmi yolunu oku ──────────────────
  Future<void> _loadLocalProfilePath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? saved = prefs.getString('local_profile_image_path');
      if (saved != null && saved.isNotEmpty) {
        final bool exists = await File(saved).exists();
        if (exists && mounted) {
          setState(() => _localProfileImagePath = saved);
        }
      }
    } catch (e) {
      debugPrint('PostPage: SharedPreferences okuma hatası: $e');
    }
  }

  // ── Gönderi resmi URL çözümleme ──────────────────────────────────────────
  String _resolveImageUrl({
    required String postImageUrl,
    required bool isLocalImage,
  }) {
    if (postImageUrl.isEmpty) {
      return 'https://picsum.photos/seed/rotam/500/300';
    }
    if (isLocalImage) {
      final bool exists = File(postImageUrl).existsSync();
      return exists
          ? postImageUrl
          : 'https://picsum.photos/seed/rotam_local/500/300';
    }
    return postImageUrl;
  }

  // ── Profil URL çözümleme (network olmayan lokal yolları filtrele) ─────────
  String _resolveProfileUrl(String url) {
    if (url.isEmpty || (!url.startsWith('http') && !url.startsWith('https'))) {
      return ''; // Boş bırak; Post widget fallback avatar gösterir
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    // Mevcut kullanıcı ID'sini Provider'dan al (null-safe)
    final currentUserId =
        Provider.of<MyUserModel>(context, listen: false).user?.id ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Rotam Türkiye',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          // ── DEV: Mock Veri Butonu (seed yapıldıktan sonra kaybolur) ──────
          if (!_mockSeeded)
            _isMockSeeding
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.amber,
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Text('🧪',
                        style: TextStyle(fontSize: 22)),
                    tooltip: 'Test Verisi Yükle (DEV)',
                    onPressed: _seedMockData,
                  ),
          // ── Liderlik tablosu ─────────────────────────────────────────────
          IconButton(
            icon: const Icon(
              Icons.filter_hdr_rounded,
              size: 30,
              color: Colors.white,
            ),
            tooltip: 'Zirve 100',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const LeaderboardPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 40, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreatePost()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: Colors.redAccent,
        backgroundColor: const Color(0xFF1A1A1A),
        strokeWidth: 2.5,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            // ── Bağlantı bekleniyor ───────────────────────────────────────
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.redAccent),
              );
            }

            // ── Hata durumu ───────────────────────────────────────────────
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.redAccent, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Gönderiler yüklenirken hata oluştu.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              );
            }

            // ── Boş akış ──────────────────────────────────────────────────
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_album_outlined,
                        color: Colors.white24, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'Henüz gönderi yok.\nİlk gönderiyi sen paylaş! 🗺️',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38, fontSize: 15),
                    ),
                  ],
                ),
              );
            }

            // ── Gönderi listesi ───────────────────────────────────────────
            return ScrollConfiguration(
              // Glow / overscroll uzama efektini tamamen kaldır
              behavior: ScrollConfiguration.of(context).copyWith(
                overscroll: false,
              ),
              child: ListView.builder(
                physics: const ClampingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                // +1: son eleman → kapanış mührü
                itemCount: docs.length + 1,
                itemBuilder: (context, index) {
                  // ── Kapanış mührü ────────────────────────────────────
                  if (index == docs.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 32, horizontal: 24),
                      child: Column(
                        children: [
                          Divider(
                            color: Colors.white12,
                            thickness: 0.8,
                            endIndent: 40,
                            indent: 40,
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            '📍 Rotanın Sonuna Geldin!\nTüm Keşifler Listelendi. 🎉',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w400,
                              height: 1.6,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                  }

                  // ── Normal gönderi kartı ──────────────────────────────
                  final data = docs[index].data() as Map<String, dynamic>;

                  final String postUserId =
                      data['userId'] as String? ?? '';
                  final String description =
                      (data['description'] as String? ?? '').isNotEmpty
                          ? data['description'] as String
                          : 'Paylaşım';
                  final String userName =
                      data['userName'] as String? ?? 'Anonim';
                  final String userPhotoUrl =
                      data['userPhotoUrl'] as String? ?? '';
                  final String postImageUrl =
                      data['postImageUrl'] as String? ?? '';
                  final bool isLocalImage =
                      data['isLocalImage'] as bool? ?? false;

                  final String resolvedImageUrl = _resolveImageUrl(
                    postImageUrl: postImageUrl,
                    isLocalImage: isLocalImage,
                  );
                  final String resolvedProfileUrl =
                      _resolveProfileUrl(userPhotoUrl);

                  return Post(
                    postId: docs[index].id,
                    imageUrl: resolvedImageUrl,
                    profileImageUrl: resolvedProfileUrl,
                    username: userName,
                    sharedLocation: description,
                    location: data['location'] as String? ?? '',
                    // ── Lokal profil fotoğrafı eşlemesi için yeni parametreler
                    postUserId: postUserId,
                    currentUserId: currentUserId,
                    localProfileImagePath: _localProfileImagePath,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
